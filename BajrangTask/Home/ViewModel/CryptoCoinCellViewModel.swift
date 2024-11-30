//
//  CyrptoCoinCellViewModel.swift
//  BajrangTask
//
//  Created by Bajrang Sinha on 28/11/24.
//

import Foundation
import UIKit

final class CryptoCoinCellViewModel {
    
    private var coinModel: CoinModel!
    
    init(coinModel: CoinModel) {
        self.coinModel = coinModel
    }
    
    @inlinable
    func getCryptoCoinName() -> String {
        return coinModel.name
    }
    
    @inlinable
    func getCryptoCoinSymbol() -> String {
        return coinModel.symbol
    }
    
    @inlinable
    func getCryptoCoinTypeImage() -> UIImage? {
        if isActiveCoin() {
            coinModel.type.image
        }else {
            UIImage(named: "coin_inactive")
        }
    }
    
    @inlinable
    func getCryptoCoinNewTagImage() -> UIImage? {
        if coinModel.isNew {
            return UIImage(named: "new_tag")
        }
        
        return nil
    }
    
    @inlinable
    func isActiveCoin() -> Bool {
        return coinModel.isActive
    }
}
