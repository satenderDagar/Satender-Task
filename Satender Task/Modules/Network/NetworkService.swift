//
//  NetworkService.swift
//  Satender Task
//
//  Created by Satender Dagar on 01/12/24.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func fetchData<T: Decodable>(from endPoint: Endpoint) -> AnyPublisher<T, Error>
}

final class NetworkService: NetworkServiceProtocol {
    
    static let shared = NetworkService()
    private init() {}
    
    func fetchData<T>(from endPoint: Endpoint) -> AnyPublisher<T, any Error> where T : Decodable {
        guard let urlString = endPoint.completeUrlString, let url = URL(string: urlString) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                // Extract data and response from the tuple
                let data = output.data
                let response = output.response as? HTTPURLResponse
                
                // Check the status code
                guard response?.statusCode == 200 else {
                    throw NetworkError.invalidURL
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in

                if let apiError = error as? NetworkError {
                    return apiError
                } else if let _ = error as? DecodingError {
                    return NetworkError.decodingError
                } else {
                    return NetworkError.unknown
                }
            }
            .eraseToAnyPublisher()
    }
}

enum NetworkError: Error {
    case invalidURL
    case decodingError
    case unknown
}
