//
//  FilterViewModel.swift
//  Satender Task
//
//  Created by Satender Dagar on 01/12/24.
//

import Foundation
import Combine

class FilterViewModel: ObservableObject {
    
    @Published var filters: [FilterData] {
        didSet {
            selectedFilters.send(getSelectedFilters())
        }
    }
    
    var selectedFilters = PassthroughSubject<[Filter], Never>()

    init() {
        filters = Filter.allCases.map{FilterData(filterType: $0)}
    }
    
    func toggleSelection(for filter: FilterData) {
        if let index = filters.firstIndex(where: { $0.id == filter.id }) {
            filters[index].isSelected.toggle()
        }
    }
    
    func getSelectedFilters() -> [Filter] {
        return filters.filter { $0.isSelected }.map { $0.filterType }
    }
}
