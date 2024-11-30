//
//  CryptoCoinViewModelTests.swift
//  BajrangTaskTests
//
//  Created by Bajrang Sinha on 30/11/24.
//

import XCTest
@testable import BajrangTask

final class CryptoCoinViewModelTests: XCTestCase {
    
    private var viewModel: CryptoCoinViewModel!
    private var mockNetworkManager: MockNetworkManager!

    override func setUpWithError() throws {
        mockNetworkManager = MockNetworkManager()
        viewModel = CryptoCoinViewModel(networkManager: mockNetworkManager)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockNetworkManager = nil
        try super.tearDownWithError()
    }

    func test_fetchCryptoCoin_Success() async {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.url(forResource: "mockCryptoCoin", withExtension: "json") else {
            XCTFail("Expected Mock JSON file but not found")
            return
        }
        
        if let data = try? Data(contentsOf: path) {
            
            mockNetworkManager.mockData = data
            
            //When
            await viewModel.fetchCryptoCoins()
            
            //Then
            XCTAssertNil(viewModel.errorMessage)
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertEqual(viewModel.cryptoCoins.count, 26)
        }
    }

    func test_searchQuery() async {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.url(forResource: "mockCryptoCoin", withExtension: "json") else {
            XCTFail("Expected Mock JSON file but not found")
            return
        }
        
        if let data = try? Data(contentsOf: path) {
            
            mockNetworkManager.mockData = data
            
            //When
            await viewModel.fetchCryptoCoins()
            
            viewModel.applySearch(query: "bit")
            
            XCTAssertEqual(viewModel.filteredCryptoCoins.count, 2)
        }
    }
    
    func test_filterItems() {
        XCTAssertEqual(viewModel.filterItems.count, 5)
    }
    
    func test_filter() async {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.url(forResource: "mockCryptoCoin", withExtension: "json") else {
            XCTFail("Expected Mock JSON file but not found")
            return
        }
        
        if let data = try? Data(contentsOf: path) {
            
            mockNetworkManager.mockData = data
            
            //When
            await viewModel.fetchCryptoCoins()
            
            viewModel.updateSelectedFilter(at: viewModel.filterItems.last?.index ?? viewModel.filterItems.count-1)
            
            XCTAssertEqual(viewModel.filteredCryptoCoins.count, 8)
        }
    }
}
