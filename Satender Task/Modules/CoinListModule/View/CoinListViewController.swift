//
//  ViewController.swift
//  Satender Task
//
//  Created by Satender Dagar on 29/11/24.
//

import UIKit
import Combine

protocol CoinListViewProtocol {
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showError(message: String)
}

class CoinListViewController: UIViewController, CoinListViewProtocol {
    
    private var coinListViewModel: CoinListViewModelProtocol?
    private var tableView: UITableView!
    private var searchController: UISearchController!
    private var filterCollectionView: FilterCollectionViewController!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coinListViewModel = CoinListViewModel()
        
        setupUI()
        bindViewModel()
        bindUI()
        coinListViewModel?.fetchCoins()
    }
    
    private func setupUI() {
        self.title = "COIN"
        
        // 1. Initialize the UISearchController
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false

        navigationItem.searchController = searchController
        definesPresentationContext = true

        // 2. Setup TableView
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CoinCell.self, forCellReuseIdentifier: CoinCell.reuseIdentifier)
        view.addSubview(tableView)
        
        // 3. Initialize the CollectionView (Filter CollectionView)
        filterCollectionView = FilterCollectionViewController(collectionViewLayout: FilterCustomLayout())
        filterCollectionView.filterUpdaterDelegate = self
        filterCollectionView.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(filterCollectionView)
        view.addSubview(filterCollectionView.view)
        filterCollectionView.didMove(toParent: self)
        
        // 4. Set up constraints
        NSLayoutConstraint.activate([
            // TableView Constraints
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            // CollectionView Constraints (this will take up 11% of the height)
            filterCollectionView.view.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            filterCollectionView.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            filterCollectionView.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            filterCollectionView.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            filterCollectionView.view.heightAnchor.constraint(equalToConstant: view.frame.height * 0.11)
        ])
    }
    
    private func bindViewModel() {
        coinListViewModel?.reloadTableView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        coinListViewModel?.errorSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(message: error)
            }
            .store(in: &cancellables)
    }
    
    private func bindUI() {
        searchController.searchBar.searchTextField
            .publisher(for: \.text)
            .map{ $0 ?? "" }
            .sink(receiveValue: { [weak self] text in
                self?.coinListViewModel?.searchQuery = text
            }).store(in: &cancellables)
    }
        
    func showLoadingIndicator() {
        // Implement loading indicator logic
    }
    
    func hideLoadingIndicator() {
        // Hide loading indicator
    }
    
    func showError(message: String) {
        // Show error alert
    }
}

extension CoinListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinListViewModel?.filteredCoins.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CoinCell.reuseIdentifier, for: indexPath) as? CoinCell else {
            return UITableViewCell()
        }
        let coin = coinListViewModel?.filteredCoins[indexPath.row]
        cell.configure(with: coin)
        return cell
    }
}

extension CoinListViewController: FilterUpdaterDelegate {
    func didChangeSelectedFilters(filters: [Filter]) {
        coinListViewModel?.updateFilters(filters: filters)
    }
}

