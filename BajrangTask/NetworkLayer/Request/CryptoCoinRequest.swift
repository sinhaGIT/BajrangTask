//
//  Endpoint.swift
//  BajrangTask
//
//  Created by Bajrang Sinha on 27/11/24.
//

import Foundation

protocol RequestProtocol {
    var scheme: String { get }
    var host: String { get }
    var httpMethod: HTTPMethod { get }
    var timeOutInterval: TimeInterval { get }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

// Endpoint struct to hold the URL, and possibly headers or other configurations
struct CryptoCoinRequest: RequestProtocol {
    var timeOutInterval: TimeInterval = 60.0
    
    var scheme: String = "https"
    
    var host: String = "37656be98b8f42ae8348e4da3ee3193f.api.mockbin.io"
        
    var httpMethod: HTTPMethod = .GET
    
    
}
