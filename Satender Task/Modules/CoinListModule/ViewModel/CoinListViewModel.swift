//
//  CoinListViewModel.swift
//  Satender Task
//
//  Created by Satender Dagar on 01/12/24.
//

import Foundation
import Combine

protocol CoinListViewModelProtocol {
    var filteredCoins: [CoinData] { get }
    var searchQuery: String { get set }
    var reloadTableView: PassthroughSubject<Void, Never> { get }
    var errorSubject: PassthroughSubject<String, Never> { get }
    
    func updateFilters(filters: [Filter])
    func fetchCoins()
}

class CoinListViewModel: CoinListViewModelProtocol {
    
    private var networkService: NetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var coins: [CoinData] = []
    var filteredCoins: [CoinData] = []
    var appliedFilters: [Filter] = []
    
    var reloadTableView = PassthroughSubject<Void, Never>()
    var errorSubject = PassthroughSubject<String, Never>()
    
    lazy var searchQuery: String = "" {
        didSet {
            // Whenever the search query changes, apply search filtering
            applySearchAndFilters()
        }
    }
        
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchCoins() {
        networkService.fetchData(from: Endpoint.coin)
             .receive(on: DispatchQueue.main)
             .sink(receiveCompletion: { [weak self] completion in
                 switch completion {
                 case .failure(let error):
                     self?.errorSubject.send(error.localizedDescription)
                 case .finished:
                     break
                 }
             }, receiveValue: { [weak self] (coinsReceived: [CoinData]) in
                 self?.coins = coinsReceived
                 self?.filteredCoins = coinsReceived
                 self?.reloadTableView.send(())
             })
             .store(in: &cancellables)
     }
    
    func filteredCoins(after newFilters: [Filter]? ) -> [CoinData] {
        let filters: [Filter] = newFilters ?? appliedFilters
        var filteredCoins = coins
        
        filters.forEach { filter in
            switch filter {
            case .active:
                filteredCoins = filteredCoins.filter { $0.isActive }
            case .inactive:
                filteredCoins = filteredCoins.filter { !$0.isActive }
            case .cryptoTypeToken:
                filteredCoins = filteredCoins.filter { $0.type == .token }
            case .crptoTypeCoin:
                filteredCoins = filteredCoins.filter { $0.type == .coin }
            case .isNew:
                filteredCoins = filteredCoins.filter { $0.isNew }
            }
        }
        
        return filteredCoins
    }
    
    func updateFilters(filters: [Filter]) {
        appliedFilters = filters
        filteredCoins = filteredCoins(after: filters)
        filteredCoins = applySearchQuery(searchQuery, on: filteredCoins)
        
        reloadTableView.send(())
    }
    
    func applySearchAndFilters() {
        let currentfilteredCoins = filteredCoins(after: nil)
        filteredCoins = applySearchQuery(searchQuery, on: currentfilteredCoins)
        
        reloadTableView.send(())
    }
    
    @discardableResult
    func applySearchQuery(_ searchQuery: String, on coins: [CoinData]) -> [CoinData] {
        var searchQueryFilteredCoins: [CoinData] = coins
        if !searchQuery.isEmpty {
            searchQueryFilteredCoins = coins.filter { coin in
                coin.name.lowercased().contains(searchQuery.lowercased()) ||
                coin.symbol.lowercased().contains(searchQuery.lowercased())
            }
        }
        
        return searchQueryFilteredCoins
    }
}
