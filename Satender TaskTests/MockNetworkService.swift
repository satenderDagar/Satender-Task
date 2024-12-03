//
//  MockNetworkService.swift
//  Satender TaskTests
//
//  Created by Satender Dagar on 03/12/24.
//

import Foundation
import Combine
@testable import Satender_Task

class MockNetworkService: NetworkServiceProtocol {
    var shouldFail = false
    var mockCoins: [Decodable] = []
    
    func fetchData<T>(from endPoint: Endpoint) -> AnyPublisher<T, any Error> where T : Decodable {
        if shouldFail {
            return Fail(error: NSError(domain: "NetworkError", code: 0, userInfo: nil))
                .eraseToAnyPublisher()
        } else {
            return Just(mockCoins as! T)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
