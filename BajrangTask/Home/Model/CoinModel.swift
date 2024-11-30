//
//  CoinModel.swift
//  BajrangTask
//
//  Created by Bajrang Sinha on 27/11/24.
//

import Foundation
import UIKit

enum CoinType: String, Decodable {
    case coin = "coin"
    case token = "token"
    
    var image: UIImage? {
        switch self {
        case .coin:
            UIImage(named: "coin_active")
        case .token:
            UIImage(named: "token")
        }
    }
}

struct CoinModel: Decodable {
    let name:       String
    let symbol:     String
    let isNew:      Bool
    let isActive:   Bool
    let type:       CoinType
}
