//
//  TrendsViewControllerTests.swift
//  BGCompass
//
//  Created by Steve Baker on 12/10/16.
//  Copyright © 2016 Clif Alferness. All rights reserved.
//

import XCTest
@testable import BGCompass

class TrendsViewControllerTests: XCTestCase {

    func testArithmeticExample() {
        XCTAssertEqual(5, 2 + 3)
}

    func testBloodGlucoseTextReadingNil() {

        XCTAssertEqual(5, 2 + 3)
        // TODO: fix me
        // Undefined symbols for architecture x86_64:
        // "type metadata accessor for BGCompass.TrendsViewController", referenced from:
        // BGCompassTests.TrendsViewControllerTests.(testBloodGlucoseTextReadingNil () -> ()).(implicit closure #1) in TrendsViewControllerTests.o
        // ld: symbol(s) not found for architecture x86_64
        // XCTAssertEqual(TrendsViewController.bloodGlucoseText(reading: nil), "No data")
    }
        
}
