//
//  Filter.swift
//  Satender Task
//
//  Created by Satender Dagar on 01/12/24.
//

import Foundation

struct FilterData: Identifiable {
    var id = UUID()
    var name: String
    var filterType: Filter
    var isSelected: Bool = false
    
    init (filterType: Filter) {
        self.filterType = filterType
        self.name = filterType.rawValue
    }
}

enum Filter: String, CaseIterable {
    case active = "Active Coins"
    case inactive = "Inactive Coins"
    case cryptoTypeToken = "Only Tokens"
    case cryptoTypeCoin = "Only Coins"
    case isNew = "New Coins"
    
    static var allFilterNames: [String] {
        return Filter.allCases.map{$0.rawValue}
    }
}
