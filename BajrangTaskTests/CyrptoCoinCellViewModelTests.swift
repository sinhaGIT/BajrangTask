//
//  CyrptoCoinCellViewModelTests.swift
//  BajrangTaskTests
//
//  Created by Bajrang Sinha on 30/11/24.
//

import XCTest
@testable import BajrangTask

final class CyrptoCoinCellViewModelTests: XCTestCase {
    
    var cellViewModel: CryptoCoinCellViewModel!

    override func setUpWithError() throws {
        let coinModel = CoinModel(name: "Bitcoin", symbol: "BTC", isNew: false, isActive: true, type: .coin)
        cellViewModel = CryptoCoinCellViewModel(coinModel: coinModel)
    }

    override func tearDownWithError() throws {
        cellViewModel = nil
        try super.tearDownWithError()
    }

    func test_cryptoName() {
        XCTAssertEqual(cellViewModel.getCryptoCoinName(), "Bitcoin", "Expected Bitcoin but got something else")
    }

    func test_cryptoSymbol() {
        XCTAssertEqual(cellViewModel.getCryptoCoinSymbol(), "BTC", "Expected BTC but got something else")
    }
    
    func test_isActiveCoin() {
        XCTAssertTrue(cellViewModel.isActiveCoin())
    }
}
