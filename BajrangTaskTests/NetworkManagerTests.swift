//
//  NetworkServiceTests.swift
//  BajrangTaskTests
//
//  Created by Bajrang Sinha on 30/11/24.
//

import XCTest
@testable import BajrangTask

final class NetworkManagerTests: XCTestCase {
    
    var mockNetworkManager: MockNetworkManager!
    var mockRequest: MockRequest!

    override func setUpWithError() throws {
        mockNetworkManager = MockNetworkManager()
        mockRequest = MockRequest()
    }

    override func tearDownWithError() throws {
        mockNetworkManager = nil
        mockRequest = nil
        try super.tearDownWithError()
    }

    func test_fetchData_decodedSuccessResponse() async {
        // Given
        
        let mockResponse = """
                [
                        {
                            "name": "Bitcoin",
                            "symbol": "BTC",
                            "is_new": false,
                            "is_active": true,
                            "type": "coin"
                        },
                        {
                            "name": "Ethereum",
                            "symbol": "ETH",
                            "is_new": false,
                            "is_active": true,
                            "type": "token"
                        }
                ]
                """
        
        let mockResponseData = mockResponse.data(using: .utf8)!
        mockNetworkManager.mockData = mockResponseData
        
        
        // When
        do {
            let coinList: [CoinModel] = try await mockNetworkManager.request(request: mockRequest)
            
            // Then
            XCTAssertEqual(coinList.count, 2)
            XCTAssertEqual(coinList.first?.name, "Bitcoin")
            XCTAssertEqual(coinList[1].name, "Ethereum")
            XCTAssertEqual(coinList[1].isActive, true)
        } catch {
            XCTFail("Expected success, but got error: \(error)")
        }
    }

    func test_fetchData_inavlidJsonThrowsError() async {
        let mockResponse = """
                [
                        {
                            "name": "Bitcoin",
                            "symbol": "BTC",
                            "is_new": false,
                            "is_active": "true",
                            "type": "coin"
                        }
                ]
                """
        
        let invalidData = mockResponse.data(using: .utf8)
        mockNetworkManager.mockData = invalidData
        
        do {
            let _: [CoinModel] = try await mockNetworkManager.request(request: mockRequest)
            XCTFail("Expected failure due to invalid json but succeeded")
        } catch let error as NetworkError {
            switch error {
            case .decodingError:
                XCTAssertTrue(true) // Test passes becuase decoding error is thrown as expected
            default:
                XCTFail("Expected Decoding error but got \(error)")
            }
        }catch {
            XCTFail("Expected Decoding error but got \(error)")
        }
    }
}


class MockNetworkManager: NetworkManagerProtocol {
    var mockData: Data?
    var mockError: Error?
    var responseParser: MockResponseParser!
    
    func request<T: Decodable>(request: any BajrangTask.RequestProtocol) async throws -> T {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData else {
            throw NSError(domain: "Mock Error", code: -1, userInfo: nil)
        }
                
        responseParser = MockResponseParser()
        
        let result: Result<T, NetworkError> = responseParser.parse(data: data)
        switch result {
        case .success(let decodedResponse):
            return decodedResponse
        case .failure:
            throw NetworkError.decodingError
        }
    }
}

class MockResponseParser: ResponseParserProtocol {
    func parse<T>(data: Data) -> Result<T, BajrangTask.NetworkError> where T : Decodable {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedResponse = try decoder.decode(T.self, from: data)
            return .success(decodedResponse)
        } catch {
            return .failure(.decodingError)
        }
    }
}

class MockRequest: RequestProtocol {
    var scheme: String = "https"
    
    var host: String = "api.example.com"
    
    var httpMethod: BajrangTask.HTTPMethod = .GET
    
    var timeOutInterval: TimeInterval = 60.0
    
    
}
