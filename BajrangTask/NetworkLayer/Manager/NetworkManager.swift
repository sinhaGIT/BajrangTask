//
//  NetworkManager.swift
//  BajrangTask
//
//  Created by Bajrang Sinha on 27/11/24.
//

import Foundation

// Define a protocol to make it mockable and testable
protocol NetworkManagerProtocol {
    func request<T: Decodable>(request: RequestProtocol) async throws -> T
}

// Enum to define different types of network errors
enum NetworkError: Error {
    case badURL
    case requestFailed
    case badResponse
    case decodingError
    case clientError
    case serverError
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .badURL: return "Url seems to be incorrect"
        case .requestFailed: return "Unable to make request"
        case .badResponse: return "response in not in correct format"
        case .decodingError: return "Unable to parse in model"
        case .clientError: return "Something went wrong from app side"
        case .serverError: return "Server unable to compute data"
        case .unknownError: return "Unknown error"
        }
    }
}

// The concrete network manager implementation
class NetworkManager: NetworkManagerProtocol {
    
    private let session: URLSession
    private let responseParser: ResponseParserProtocol
    
    // Dependency injection for URLSession (for testability)
    init(session: URLSession = .shared, responseParser: ResponseParserProtocol = ResponseParser()) {
        self.session = session
        self.responseParser = responseParser
    }
    
    // This is the method that will perform the network request
    func request<T: Decodable>(request: RequestProtocol) async throws -> T {
        
        var components = URLComponents()
        components.scheme = request.scheme
        components.host = request.host
        
        guard let strUrl = components.url?.absoluteString.removingPercentEncoding, let url = URL(string:strUrl) else {
            throw NetworkError.badURL
        }
                
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.timeoutInterval = request.timeOutInterval

        
        do {
            let (data, _) = try await session.data(for: urlRequest)
            
            let result: Result<T, NetworkError> = self.responseParser.parse(data: data)
            switch result {
            case .success(let decodedResponse):
                return decodedResponse
            case .failure:
                throw NetworkError.decodingError
            }
        }catch  let error {
            throw error
        }
    }
}
