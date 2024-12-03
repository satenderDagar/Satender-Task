//
//  FilterViewModelTest.swift
//  Satender TaskTests
//
//  Created by Satender Dagar on 03/12/24.
//

import XCTest
import Combine
@testable import Satender_Task

class FilterViewModelTests: XCTestCase {
    
    var viewModel: FilterViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = FilterViewModel()
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
        
    func test_initialization() {
        XCTAssertEqual(viewModel.filters.count, Filter.allCases.count)
        for filterData in viewModel.filters {
            XCTAssertFalse(filterData.isSelected, "Filter should be unselected initially.")
        }
    }
        
    func testToggleSelectionforExistingFilter() {
        // Assuming the first filter is not selected initially.
        let filterData = viewModel.filters[0]
        
        // Ensure the filter is initially not selected.
        XCTAssertFalse(filterData.isSelected)
        
        // Toggle selection.
        viewModel.toggleSelection(for: filterData)
        
        // Ensure the filter is selected after toggle.
        XCTAssertTrue(viewModel.filters[0].isSelected)
        
        // Toggle again.
        viewModel.toggleSelection(for: filterData)
        
        // Ensure the filter is deselected.
        XCTAssertFalse(viewModel.filters[0].isSelected)
    }
    
    func testToggleSelectionForMultipleFilters() {
        // Toggle the selection for the first and second filters
        let filterData1 = viewModel.filters[0]
        let filterData2 = viewModel.filters[1]
        
        viewModel.toggleSelection(for: filterData1)
        viewModel.toggleSelection(for: filterData2)
        
        // Ensure both filters are selected
        XCTAssertTrue(viewModel.filters[0].isSelected)
        XCTAssertTrue(viewModel.filters[1].isSelected)
        
        // Toggle the first filter again
        viewModel.toggleSelection(for: filterData1)
        
        // Ensure the first filter is deselected and second filter remains selected
        XCTAssertFalse(viewModel.filters[0].isSelected)
        XCTAssertTrue(viewModel.filters[1].isSelected)
    }
        
    func testGetSelectedFilters() {
        // Initially no filters are selected.
        let selectedFilters = viewModel.getSelectedFilters()
        XCTAssertTrue(selectedFilters.isEmpty, "Initially, no filters should be selected.")
        
        // Select a filter.
        viewModel.toggleSelection(for: viewModel.filters[0])
        
        // Get the selected filters.
        let selectedAfterToggle = viewModel.getSelectedFilters()
        
        // Ensure the correct filter is selected.
        XCTAssertEqual(selectedAfterToggle.count, 1)
        XCTAssertEqual(selectedAfterToggle.first, viewModel.filters[0].filterType)
        
        // Select another filter.
        viewModel.toggleSelection(for: viewModel.filters[1])
        
        // Ensure both filters are selected now.
        let selectedAfterSecondToggle = viewModel.getSelectedFilters()
        XCTAssertEqual(selectedAfterSecondToggle.count, 2)
        XCTAssertTrue(selectedAfterSecondToggle.contains(viewModel.filters[0].filterType))
        XCTAssertTrue(selectedAfterSecondToggle.contains(viewModel.filters[1].filterType))
    }
        
    func testSelectedFiltersPublisherEmitsUpdatedValues() {
        // Set up a subscriber to the `selectedFilters` publisher.
        let expectation = self.expectation(description: "selectedFilters publisher emits updated values")
        expectation.expectedFulfillmentCount = 2
        var emittedFilters: [Filter] = []
        
        viewModel.selectedFilters
            .sink(receiveValue: { filters in
                emittedFilters = filters
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        // Toggle two filters.
        viewModel.toggleSelection(for: viewModel.filters[0])
        viewModel.toggleSelection(for: viewModel.filters[1])
        
        waitForExpectations(timeout: 1, handler: nil)
        
        // Ensure the publisher emits the correct updated list of selected filters.
        XCTAssertEqual(emittedFilters.count, 2)
        XCTAssertTrue(emittedFilters.contains(viewModel.filters[0].filterType))
        XCTAssertTrue(emittedFilters.contains(viewModel.filters[1].filterType))
    }
}
