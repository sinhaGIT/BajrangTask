//
//  CryptoCoinListViewController.swift
//  BajrangTask
//
//  Created by Bajrang Sinha on 27/11/24.
//

import UIKit
import Combine

class CryptoCoinListViewController: UIViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchDebounceWorkItem: DispatchWorkItem?
    private let debounceDelay: TimeInterval = 0.3
    private var filterTableViewBottomConstraint: NSLayoutConstraint!
    private var loadingView: UIView!
    private var activityIndicator: UIActivityIndicatorView!
    private var cancellables = Set<AnyCancellable>()
    
    private var networkMonitor = ConnectivityMonitor()
    private var viewModel: CryptoCoinViewModelProtocol!
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
        tableView.registerCell(ofType: CryptoCoinTableViewCell.self)
        tableView.separatorInset = UIEdgeInsets.zero
        
        return tableView
    }()
    
    private let filterItemTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "filterCell")
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.backgroundColor = UIColor.lightGray
        
        return tableView
    }()
    
    // Create a label to display when the table is empty
    private let emptyMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "No coins fetched"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // Dependency injection via initializer or property injection
    init(viewModel: CryptoCoinViewModelProtocol = CryptoCoinViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeNavigationBar()
        setupLoadingView()
        tableView.dataSource = self
        view.addSubview(tableView)
        setupConstraint()
        
        setupFilterItemTableView()
        addSubscriber()
        getCryptoCoins()
        
        networkMonitor = ConnectivityMonitor()
        networkMonitor.connectivityPublisher.sink {[weak self] isConnected in
            guard let strongifySelf = self else { return }
            if isConnected && strongifySelf.viewModel.cryptoCoins.isEmpty {
                strongifySelf.getCryptoCoins()
            }
        }.store(in: &cancellables)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateFilterItemTableViewHeight()
    }
    
    deinit {
        networkMonitor.stopMonitoring()
    }
    
    private func getCryptoCoins() {
        // Trigger the ViewModel to fetch crypto coins
        Task {
            await viewModel.fetchCryptoCoins()
            updateEmptyState()
        }
    }
    
    private func addSubscriber() {
        guard let cryptoViewModel = viewModel as? CryptoCoinViewModel else {
            return
        }
        cryptoViewModel.$isLoading
            .sink { [weak self] isLoading in
                DispatchQueue.main.async {
                    if isLoading {
                        self?.showLoader()
                    } else {
                        self?.hideLoader()
                    }
                }
            }
            .store(in: &cancellables)
        
        cryptoViewModel.$cryptoCoins.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }.store(in: &cancellables)
        
        cryptoViewModel.$filteredCryptoCoins.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }.store(in: &cancellables)
        
        cryptoViewModel.$errorMessage.sink { [weak self] errorMsg in
            guard let msg = errorMsg else { return }
            DispatchQueue.main.async {
                self?.showAlert(msg: msg)
            }
        }.store(in: &cancellables)
    }
    
    private func updateEmptyState() {
        if viewModel.cryptoCoins.isEmpty {
            emptyMessageLabel.isHidden = false
            tableView.backgroundView = emptyMessageLabel
        } else {
            emptyMessageLabel.isHidden = true
            tableView.backgroundView = nil
        }
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            // Pin to top safe area
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            // Pin to left and right edges
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Pin to bottom edge, but this will be adjusted by the contentInset
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func customizeNavigationBar() {
        // Set the Navigation Bar's background color
        if let navigationController = self.navigationController {
            navigationController.navigationBar.backgroundColor = UIColor(hex: 0x6200ED)
            navigationController.navigationBar.barTintColor = UIColor(hex: 0x6200ED)
            navigationController.navigationBar.tintColor = .white
            navigationController.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
            navigationController.navigationBar.isTranslucent = false
        }
        
        // Set the title of the navigation bar
        navigationItem.title = "COINS"
                
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
        
        let filterButton = UIButton(type: .system)
        filterButton.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        filterButton.setImage(UIImage(named: "filter"), for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Wrap the button in a UIBarButtonItem
        let filterBarButtonItem = UIBarButtonItem(customView: filterButton)
        navigationItem.rightBarButtonItems = [searchButton, filterBarButtonItem, flexibleSpace]
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @objc func searchButtonTapped() {
        if navigationItem.searchController == nil {
            addSearchController()
        }else {
            navigationItem.searchController = nil
        }
    }
    
    @objc func filterButtonTapped() {
        addFilterItemTableView(isAnimated: true)
    }
    
    private func addSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search items"
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        configureSearchBarAppearance()
    }
    
    private func configureSearchBarAppearance() {
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.tintColor = UIColor.white
        
        // Change the placeholder text color (inside the search bar)
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = UIColor.black
            textField.tintColor = UIColor.black
            textField.backgroundColor = .white
        }
    }
    
    private func setupFilterItemTableView() {
        filterItemTableView.dataSource = self
        filterItemTableView.delegate = self
        view.insertSubview(filterItemTableView, aboveSubview: tableView)
        
        filterTableViewBottomConstraint = filterItemTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: self.view.frame.size.height)
        
        NSLayoutConstraint.activate([
            filterTableViewBottomConstraint,
            filterItemTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            filterItemTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            filterItemTableView.heightAnchor.constraint(equalToConstant: 0)
        ])
        updateFilterItemTableViewHeight()
    }
    
    private func updateFilterItemTableViewHeight() {
        // Update the height of the table view based on its content size
        let height = min(filterItemTableView.contentSize.height, 360)
        if let heightConstraint = filterItemTableView.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = height
        } else {
            // If the height constraint doesn't exist, add a new one
            let heightConstraint = filterItemTableView.heightAnchor.constraint(equalToConstant: height)
            heightConstraint.isActive = true
        }
    }
    
    private func addFilterItemTableView(isAnimated animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {[weak self] in
                self?.updateBottomConstraint()
            })
        }else {
            updateBottomConstraint()
        }
    }
    
    private func updateBottomConstraint() {
        let contentHeight = min(filterItemTableView.contentSize.height, 360)
        if filterTableViewBottomConstraint.constant == 0 {
            filterTableViewBottomConstraint.constant = contentHeight
            tableView.contentInset.bottom = 0
        }else {
            filterTableViewBottomConstraint.constant = 0
            tableView.contentInset.bottom = contentHeight
        }
        view.layoutIfNeeded()
    }
}

extension CryptoCoinListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == filterItemTableView {
            return viewModel.filterItems.count
        }
        return viewModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == filterItemTableView {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "filterCell")
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.lightGray
            cell.backgroundView = backgroundView
            cell.selectionStyle = .none
            cell.textLabel?.text = viewModel.filterItems[indexPath.row].name
            return cell
        }else {
            let cell: CryptoCoinTableViewCell = tableView.dequeueCell()
            let cellVM = self.viewModel.getCellViewModel(at: indexPath)
            cell.bind(to: cellVM)
            return cell
        }
    }
}

extension CryptoCoinListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == filterItemTableView {
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            
            if viewModel.filterItems[indexPath.row].isSelected {
                cell.accessoryType = .none
            }else {
                cell.accessoryType = .checkmark
            }
            viewModel.updateSelectedFilter(at: indexPath.row)
        }
    }
}

extension CryptoCoinListViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let query = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if query.isEmpty && !viewModel.isSearchStarted() {
            return
        }
        
        searchDebounceWorkItem?.cancel()
        searchDebounceWorkItem = DispatchWorkItem(block: {[weak self] in
            self?.viewModel.applySearch(query: query)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceDelay, execute: searchDebounceWorkItem!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.applySearch(query: "")
    }
}

extension CryptoCoinListViewController {
    fileprivate func setupLoadingView() {
        loadingView = UIView(frame: self.view.bounds)
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.center = loadingView.center
        loadingView.addSubview(activityIndicator)
        
        loadingView.isHidden = true
        loadingView.layer.zPosition = 1
        
        self.view.addSubview(loadingView)
    }
    
    // Show the loader with dimmed background
    fileprivate func showLoader() {
        loadingView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    // Hide the loader and remove the dimmed background
    fileprivate func hideLoader() {
        activityIndicator.stopAnimating()
        loadingView.isHidden = true
    }
}

extension CryptoCoinListViewController {
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "Alert",
                                      message: msg,
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
        }
        
        alert.addAction(okAction)
        
        // Present the alert controller
        self.present(alert, animated: true, completion: nil)
    }
}
