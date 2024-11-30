//
//  CryptoCoinViewModel.swift
//  BajrangTask
//
//  Created by Bajrang Sinha on 27/11/24.
//

import Foundation
import Combine

protocol CryptoCoinViewModelProtocol: CryptoSearchProtocol, CryptoFilterProtocol {
    var cryptoCoins: [CoinModel] { get }
    var isLoading: Bool { get set }
    var errorMessage: String? { get }
    func fetchCryptoCoins() async
    
    func numberOfRows(in section: Int) -> Int
    func getCellViewModel(at indexPath: IndexPath) -> CryptoCoinCellViewModel
}

protocol CryptoSearchProtocol {
    var searchQuery: String { get set }
    func updateSearchQuery(query: String)
    func isSearchStarted() -> Bool
    func applySearch(query: String)
}

protocol CryptoFilterProtocol {
    var filteredCryptoCoins: [CoinModel] { get set }
    var filterItems: [FilterItem] { get set }
    func updateSelectedFilter(at index: Int)
}

struct FilterItem {
    var name: String
    var index: Int
    var isSelected = false
}

class CryptoCoinViewModel: CryptoCoinViewModelProtocol {
    
    private var networkManager: NetworkManagerProtocol
    private var cachedCellVMs = [IndexPath : CryptoCoinCellViewModel]()
    
    var filterItems: [FilterItem] = [FilterItem(name: "Active Coin", index: 0),
                                     FilterItem(name: "Inactive Coin", index: 1),
                                     FilterItem(name: "Only Token", index: 2), 
                                     FilterItem(name: "Only Coin", index: 3),
                                     FilterItem(name: "Latest", index: 4)]
    
    // Observable data that the view will listen to
    
    @Published var isLoading: Bool = false
    @Published var filteredCryptoCoins: [CoinModel] = []
    @Published var cryptoCoins: [CoinModel] = []
    @Published var errorMessage: String?
    
    var searchQuery: String = ""
    
    // Dependency injection of the network manager
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func fetchCryptoCoins() async {
        self.isLoading = true
        
        do {
            let request = CryptoCoinRequest()
            let decodedResponse: [CoinModel] = try await networkManager.request(request: request)
            self.cryptoCoins = decodedResponse
        }catch let error where error is NetworkError {
            print("Error fetching posts: \(error)")
            self.errorMessage = (error as? NetworkError)?.localizedDescription
        }catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
}

extension CryptoCoinViewModel {
    func numberOfRows(in section: Int) -> Int {
        // since we have only one section that's why section check in not imeplemneted here
        let isFilterApplied = !(filterItems.filter{$0.isSelected}.isEmpty)
        if isSearchStarted() || isFilterApplied {
            return filteredCryptoCoins.count
        }else {
            return self.cryptoCoins.count
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> CryptoCoinCellViewModel {
        let isFilterApplied = !(filterItems.filter{$0.isSelected}.isEmpty)
        if isSearchStarted() || isFilterApplied {
            let cellVM = CryptoCoinCellViewModel(coinModel: self.filteredCryptoCoins[indexPath.row])
            return cellVM
        }else {
            if let cellVM = cachedCellVMs[indexPath] {
                return cellVM
            }else {
                let cellVM = CryptoCoinCellViewModel(coinModel: self.cryptoCoins[indexPath.row])
                cachedCellVMs[indexPath] = cellVM
                return cellVM
            }
        }
    }
}

// For Seraching
extension CryptoCoinViewModel {
    func applySearch(query: String) {
        updateSearchQuery(query: query)
        let isFilterApplied = !(filterItems.filter{$0.isSelected}.isEmpty)
        var allCoins = cryptoCoins
        if isFilterApplied {
            allCoins = filterCryptoCoin()
        }
        
        if !query.isEmpty {
            filteredCryptoCoins = filterUsingSearchQuery(allCoins: allCoins)
        }else {
            filteredCryptoCoins = allCoins
        }
    }
    
    func filterUsingSearchQuery(allCoins: [CoinModel]) -> [CoinModel] {
        let query = getSearchQuery()
        return allCoins.filter({ cryptoCoin in
            return cryptoCoin.name.lowercased().contains(query.lowercased()) || cryptoCoin.symbol.lowercased().contains(query.lowercased())
        })
    }
    
    func updateSearchQuery(query: String) {
        searchQuery = query
    }
    
    func isSearchStarted() -> Bool {
        return !searchQuery.isEmpty
    }
    
    func getSearchQuery() -> String {
        return searchQuery
    }
}

// For Filter
extension CryptoCoinViewModel {
    
    func updateSelectedFilter(at index: Int) {
        filterItems[index].isSelected.toggle()
        filteredCryptoCoins = filterCryptoCoin()
    }
    
    fileprivate func filterCryptoCoin() -> [CoinModel] {
        
        var filters: [(CoinModel) -> Bool] = []
        
        // Adding filter which user was selected
        for filterItem in filterItems {
            if filterItem.isSelected {
                switch filterItem.index {
                case 0:
                    filters.append({$0.isActive})
                case 1:
                    filters.append({ !$0.isActive})
                case 2:
                    filters.append({ $0.type == .token })
                case 3:
                    filters.append({ $0.type == .coin })
                case 4:
                    filters.append({ $0.isNew })
                default:
                    break
                }
            }
        }
        
        // Applying Filter
        var coinToBeFiltered = cryptoCoins
        if isSearchStarted() {
            coinToBeFiltered = filterUsingSearchQuery(allCoins: cryptoCoins)
        }
        
        if filters.isEmpty {
            return coinToBeFiltered
        }
        return coinToBeFiltered.filter { cryptoCoin in
            //To Filter who satisfy any one from selected filters
            filters.contains(where: { filter in
                filter(cryptoCoin)
            })
            
            //To Filter who satisfy all from selected filters
//            filters.allSatisfy { filter in
//                filter(cryptoCoin)
//            }
            
            //Since i am assuming this is a one category filter so i applied above one. To Apply filter from multiple category we need to combine multiple filter result with AND Operator.
        }
    }
}
