//
//  Endpoint.swift
//  Satender Task
//
//  Created by Satender Dagar on 01/12/24.
//

import Foundation

struct AppConfigurations {
    static var apiBaseURL = Bundle.main.object(forInfoDictionaryKey: NetworkApi.baseURL) as? String
}

enum Endpoint: String {
    case coin = ""
    
    var completeUrlString: String? {
        guard let apiBaseUrl = AppConfigurations.apiBaseURL else {
            return nil
        }
        
        switch self {
        case .coin:
            return apiBaseUrl + self.rawValue
        }
    }
}
