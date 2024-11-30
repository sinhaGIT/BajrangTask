//
//  ResponseParser.swift
//  BajrangTask
//
//  Created by Bajrang Sinha on 27/11/24.
//

import Foundation

// A protocol to ensure we have a consistent parsing strategy
protocol ResponseParserProtocol {
    func parse<T: Decodable>(data: Data) -> Result<T, NetworkError>
}

// The concrete response parser
class ResponseParser: ResponseParserProtocol {
    
    func parse<T: Decodable>(data: Data) -> Result<T, NetworkError> {
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
