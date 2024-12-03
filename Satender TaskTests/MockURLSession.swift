//
//  MockURLSession.swift
//  Satender TaskTests
//
//  Created by Satender Dagar on 02/12/24.
//

import Foundation
import Combine

typealias mockResponseCompletion = (data: Data?, response: URLResponse?, error: Error?)

class URLProtocolMock: URLProtocol {
    // this dictionary maps URLs to test data
    static var mockResponses = [URL: mockResponseCompletion]()

    // say we want to handle all types of request
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    // ignore this method; just send back what we were given
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let url = request.url, let mockResponse = URLProtocolMock.mockResponses[url] {
            if let error = mockResponse.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                if let response = mockResponse.response {
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = mockResponse.data {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            }
        }
    }
    
    // this method is required but doesn't need to do anything
    override func stopLoading() { }
}


