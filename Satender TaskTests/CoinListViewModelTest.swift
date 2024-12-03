//
//  CoinListViewModelTest.swift
//  Satender TaskTests
//
//  Created by Satender Dagar on 04/12/24.
//

import XCTest
import Combine
@testable import Satender_Task

class CoinListViewModelTests: XCTestCase {
    
    var viewModel: CoinListViewModel!
    var mockNetworkService: MockNetworkService!
    var cancellables: Set<AnyCancellable>!
    
  
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = CoinListViewModel(networkService: mockNetworkService)
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }

    func createCoinData(name: String, symbol: String, isActive: Bool, isNew: Bool, type: CryptoType) -> CoinData {
        let coinStr =
        """
        {
            "name": "\(name)",
            "symbol": "\(symbol)",
            "is_new": \(isNew),
            "is_active": \(isActive),
            "type": "\(type.rawValue)"
        }
        """
        let coinData = coinStr.data(using: .utf8)
        return try! JSONDecoder().decode(CoinData.self, from: coinData!)
    }

    // MARK: - Tests
    func test_initialValues() {
        XCTAssertEqual(viewModel.filteredCoins, [])
        XCTAssertEqual(viewModel.searchQuery, "")
        XCTAssertNotNil(viewModel.reloadTableView)
        XCTAssertNotNil(viewModel.errorSubject)
    }

    func test_fetchCoins_success() {
        let expectation = XCTestExpectation(description: "Coins are fetched and ReloadTableView is called")

        let mockCoinData = [
            createCoinData(name: "Bitcoin", symbol: "BTC", isActive: true, isNew: false, type: .coin),
            createCoinData(name: "Ethereum", symbol: "ETH", isActive: true, isNew: true, type: .coin)
        ]
        mockNetworkService.mockCoins = mockCoinData
        
        viewModel.reloadTableView
            .sink { _ in
                expectation.fulfill()
                XCTAssertEqual(self.viewModel.coins.count, 2)
                XCTAssertEqual(self.viewModel.filteredCoins.count, 2)
            }
            .store(in: &cancellables)
    
        viewModel.fetchCoins()
        
        wait(for: [expectation], timeout: 1)
    }

    func test_fetchCoins_failure() {
        mockNetworkService.shouldFail = true
        let expectation = XCTestExpectation(description: "Error is received")
        
        viewModel.errorSubject
            .sink { error in
                XCTAssertEqual(error, "The operation couldn’t be completed. (NetworkError error 0.)")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchCoins()
        wait(for: [expectation], timeout: 1)
    }

    func test_updateFilters() {
        let mockCoinData = [
            createCoinData(name: "Bitcoin", symbol: "BTC", isActive: true, isNew: false, type: .coin),
            createCoinData(name: "Ethereum", symbol: "ETH", isActive: false, isNew: true, type: .coin)
        ]
        viewModel.coins = mockCoinData
            
        let expectation = XCTestExpectation(description: "Filters are applied and reloadTableView is called")
                
        viewModel.reloadTableView
            .sink { _ in
                XCTAssertEqual(self.viewModel.filteredCoins.count, 1)
                XCTAssertEqual(self.viewModel.filteredCoins.first?.name, "Bitcoin")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateFilters(filters: [.active])
        wait(for: [expectation], timeout: 1)
    }

    func test_applySearchQuery() {
        let mockCoinData = [
            createCoinData( name: "Bitcoin", symbol: "BTC", isActive: true, isNew: false, type: .coin),
            createCoinData(name: "Ethereum", symbol: "ETH", isActive: true, isNew: true, type: .coin)
        ]
        viewModel.coins = mockCoinData

        let searchQuery = "Bitcoin"
        
        let expectation = XCTestExpectation(description: "Search filter is applied and reloadTableView is called")
        
        viewModel.reloadTableView
            .sink { _ in
                XCTAssertEqual(self.viewModel.filteredCoins.count, 1)
                XCTAssertEqual(self.viewModel.filteredCoins.first?.name, "Bitcoin")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchQuery = searchQuery
        wait(for: [expectation], timeout: 1)
    }

    func test_applyFiltersAndSearch() {
        let mockCoinData = [
            createCoinData(name: "Bitcoin", symbol: "BTC", isActive: true, isNew: false, type: .coin),
            createCoinData(name: "Ethereum", symbol: "ETH", isActive: true, isNew: true, type: .coin)
        ]
        viewModel.coins = mockCoinData
        
        viewModel.updateFilters(filters: [.active])
        
        let searchQuery = "Bitcoin"
        
        let expectation = XCTestExpectation(description: "Filters and search are applied")
        
        viewModel.reloadTableView
            .sink { _ in
                XCTAssertEqual(self.viewModel.filteredCoins.count, 1)
                XCTAssertEqual(self.viewModel.filteredCoins.first?.name, "Bitcoin")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchQuery = searchQuery
        wait(for: [expectation], timeout: 1)
    }
}

extension CoinListViewModelTests {
    
    func testFilterCoins() {
        
        let coins = [
            createCoinData(name: "Coin1", symbol: "C1",  isActive: true, isNew: true, type: .coin),
            createCoinData(name: "Coin2", symbol: "C2",  isActive: true, isNew: false, type: .token),
            createCoinData(name: "Coin3", symbol: "C3", isActive: false, isNew: true, type: .coin),
            createCoinData(name: "Coin4", symbol: "C4", isActive: false, isNew: false, type: .token)
        ]
        
        viewModel.coins = coins
        // Test all individual filter cases
        let testCases: [(filters: [Filter], expectedCount: Int)] = [
            // Active Filter
            ([.active], 2),  // active, type doesn't matter
            
            // Inactive Filter
            ([.inactive], 2), // inactive, type doesn't matter
            
            // CryptoTypeToken Filter
            ([.cryptoTypeToken], 2), // type token, active doesn't matter
            
            // CryptoTypeCoin Filter
            ([.cryptoTypeCoin], 2), // type coin, active doesn't matter
            
            // IsNew Filter
            ([.isNew], 2), // isNew true, active doesn't matter
            
            // Multiple Filters (Active + New)
            ([.active, .isNew], 1), // active and new
            
            // No Filters (should return all coins)
            ([], 4), // all coins
            
            // No Matching Coins (active and token)
            ([.active, .cryptoTypeToken], 1) // active and token, no matches
        ]
        
        // Run through all test cases
        for (filters, expectedCount) in testCases {
            let result = viewModel.filteredCoins(after: filters)
            
            // Assert correct number of filtered coins
            XCTAssertEqual(result.count, expectedCount)
        }
    }
}

    
