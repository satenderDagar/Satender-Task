//
//  NetworkServiceTest.swift
//  Satender TaskTests
//
//  Created by Satender Dagar on 03/12/24.
//

import XCTest
import Combine
@testable import Satender_Task

final class NetworkServiceTest: XCTestCase {

    var sut: NetworkService?
    var cancellables: Set<AnyCancellable>? = Set<AnyCancellable>()
    var url: URL!
    let sampleData =
    """
     [{
        "name": "Aave",
        "symbol": "AAVE",
        "is_new": true,
        "is_active": true,
        "type": "token"
      }]
    """.data(using: .utf8)!
    
    var sampleCoinData: [CoinData]!


    override func setUpWithError() throws {
        let urlString = try XCTUnwrap(Endpoint.coin.completeUrlString)
        url = try XCTUnwrap(URL(string: urlString))
        cancellables = Set<AnyCancellable>()
        sampleCoinData = try XCTUnwrap(JSONDecoder().decode([CoinData].self, from: sampleData))
    }

    override func tearDownWithError() throws {
        url = nil
        sut = nil
        cancellables = nil
        sampleCoinData = nil
    }
    
    func setupMockResponse(with url: URL, statusCode: Int = 200, sampleData: Data?, error: Error?) -> mockResponseCompletion {
        let mockResponse: mockResponseCompletion = {
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
            return (sampleData, response, error)
        }()
        return mockResponse
    }
    
    func setupMockUrlSession(for url:URL, response: mockResponseCompletion) -> URLSession {
        URLProtocolMock.mockResponses = [url: response]
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        
        return URLSession(configuration: config)
    }

    func testSuccess() throws {
        let expectation = self.expectation(description: "FetchedData")
    
        let mockResponse = setupMockResponse(with: url, sampleData: sampleData, error: nil)
        let mockedSession = setupMockUrlSession(for: url, response: mockResponse)
        sut = NetworkService(urlSession: mockedSession)
        sut?.fetchData(from: Endpoint.coin)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(_):
                    XCTFail("test should not fail")
                case .finished:
                    break
                }
            }, receiveValue: {[weak self] (coinsReceived: [CoinData]) in
                XCTAssertEqual(coinsReceived, self?.sampleCoinData)
                expectation.fulfill()
                
            })
            .store(in: &(cancellables!))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFailureWhenStatusCodeIsNot200() {
        let expectation = self.expectation(description: "Fail with invalid url")
        
        let mockResponse = setupMockResponse(with: url, statusCode: 400, sampleData: sampleData, error: nil)
        let mockedSession = setupMockUrlSession(for: url, response: mockResponse)
        sut = NetworkService(urlSession: mockedSession)
        sut?.fetchData(from: Endpoint.coin)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error as NetworkError):
                    XCTAssertTrue(error  == .serviceNotFound)
                    expectation.fulfill()
                case .finished:
                    break
                case .failure(_):
                    XCTFail("Failed with wrong error type")
                }            }, receiveValue: { (coinsReceived: [CoinData]) in
                XCTFail("test should not receive coindata")
            })
            .store(in: &(cancellables!))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFailureWhenReceivedErrorFromServer() {
        let expectation = self.expectation(description: "Fail with invalid url")
        
        let mockResponse = setupMockResponse(with: url, sampleData: Data(), error: NSError(domain: "some error", code: -1))
        let mockedSession = setupMockUrlSession(for: url, response: mockResponse)
        sut = NetworkService(urlSession: mockedSession)
        sut?.fetchData(from: Endpoint.coin)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error as NetworkError):
                    XCTAssertTrue(error  == .unknown)
                    expectation.fulfill()
                case .finished:
                    break
                case .failure(_):
                    XCTFail("Failed with wrong error type")
                }            }, receiveValue: { (coinsReceived: [CoinData]) in
                XCTFail("test should not receive coindata")
            })
            .store(in: &(cancellables!))
        
        wait(for: [expectation], timeout: 1.0)
    }


    func testFailureWhenDecodingErrorHappened() {
        let expectation = self.expectation(description: "Fail with invalid url")
        
        let mockResponse = setupMockResponse(with: url, sampleData: Data(), error: nil)
        let mockedSession = setupMockUrlSession(for: url, response: mockResponse)
        sut = NetworkService(urlSession: mockedSession)
        sut?.fetchData(from: Endpoint.coin)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error as NetworkError):
                    XCTAssertTrue(error  == .decodingError)
                    expectation.fulfill()
                case .finished:
                    break
                case .failure(_):
                    XCTFail("Failed with wrong error type")
                }            }, receiveValue: { (coinsReceived: [CoinData]) in
                XCTFail("test should not receive coindata")
            })
            .store(in: &(cancellables!))
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testFailureWhenPointIsNotCorrect() {
        let expectation = self.expectation(description: "Fail with invalid url")
        
        // mock the baseurl
        let initialBaseUrl = AppConfigurations.apiBaseURL
        AppConfigurations.apiBaseURL = nil
        
        let mockedSession = setupMockUrlSession(for: URL(string: "www.sampleurl.com")!, response: (nil, nil, nil))
        sut = NetworkService(urlSession: mockedSession)
        
        sut?.fetchData(from: Endpoint.coin)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error as NetworkError):
                    XCTAssertTrue(error  == .invalidURL)
                    expectation.fulfill()
                case .finished:
                    break
                case .failure(_):
                    XCTFail("Failed with wrong error type")
                }
            }, receiveValue: { (coinsReceived: [CoinData]) in
                XCTFail("test should not receive coindata")
            })
            .store(in: &(cancellables!))
        
        wait(for: [expectation], timeout: 1.0)
        
        //set bac
        AppConfigurations.apiBaseURL = initialBaseUrl
    }
}
