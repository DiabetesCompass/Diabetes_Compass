//
//  TrendsAlgorithmModelTests.swift
//  BGCompass
//
//  Created by Steve Baker on 12/18/16.
//  Copyright © 2016 Clif Alferness. All rights reserved.
//

import XCTest
@testable import BGCompass

class TrendsAlgorithmModelTests: XCTestCase {

    func testHA1cFromBloodGlucose() {
        //https://en.wikipedia.org/wiki/Glycated_hemoglobin
        XCTAssertEqualWithAccuracy(TrendsAlgorithmModel.hA1cFromBloodGlucose(97.0),
                                   5.0, accuracy: 0.02)
        XCTAssertEqualWithAccuracy(TrendsAlgorithmModel.hA1cFromBloodGlucose(240.0),
                                   10.0, accuracy: 0.02)
        XCTAssertEqualWithAccuracy(TrendsAlgorithmModel.hA1cFromBloodGlucose(499.0),
                                   19.0, accuracy: 0.02)
    }

    // MARK: - testWeightLinearDecay

    func testWeightLinearDecayFirstDateSecondDateSame() {
        let firstDate = Date()
        let secondDate = firstDate
        // use arbitrary value for test
        let decayLifeSeconds = 42.0

        let weight = TrendsAlgorithmModel.weightLinearDecayFirstDate(firstDate,
                                                                     secondDate: secondDate,decayLifeSeconds: decayLifeSeconds)
        XCTAssertEqualWithAccuracy(weight, 1.0, accuracy: 0.01)
    }

    func testWeightLinearDecayFirstDateLifetimeBeforeSecondDate() {
        let firstDate = Date()
        let secondDate = firstDate.addingTimeInterval(TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let weight = TrendsAlgorithmModel.weightLinearDecayFirstDate(firstDate,
                                                                     secondDate: secondDate,decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        XCTAssertEqualWithAccuracy(weight, 0.0, accuracy: 0.01)
    }

    func testWeightLinearDecayFirstDateBeforeSecondDateByOneTenthDecayLife() {
        let firstDate = Date()
        let secondDate = firstDate.addingTimeInterval(0.1 * TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let weight = TrendsAlgorithmModel.weightLinearDecayFirstDate(firstDate,
                                                                     secondDate: secondDate,decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        // weight will be close to 1.0
        XCTAssertEqualWithAccuracy(weight, 0.90, accuracy: 0.01)
    }

    func testWeightLinearDecayFirstDateBeforeSecondDateByNineTenthsDecayLife() {
        let firstDate = Date()
        // use arbitrary value for test, one hour
        let decayLifeSeconds = 3600.0
        let secondDate = firstDate.addingTimeInterval(0.9 * decayLifeSeconds)
        let weight = TrendsAlgorithmModel.weightLinearDecayFirstDate(firstDate,
                                                                     secondDate: secondDate,decayLifeSeconds: decayLifeSeconds)
        // weight will be close to 0.0
        XCTAssertEqualWithAccuracy(weight, 0.10, accuracy: 0.01)
    }

    func testWeightLinearDecayFirstDateDistantPast() {
        let firstDate = Date.distantPast
        let secondDate = Date()

        let weight = TrendsAlgorithmModel.weightLinearDecayFirstDate(firstDate,
                                                                     secondDate: secondDate,decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        XCTAssertEqualWithAccuracy(weight, 0.0, accuracy: 0.01)
    }

    func testWeightLinearDecayFirstDateAfterSecondDate() {

        let firstDate = Date.distantFuture
        let secondDate = Date()

        let weight = TrendsAlgorithmModel.weightLinearDecayFirstDate(firstDate,
                                                                     secondDate: secondDate,decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        XCTAssertEqualWithAccuracy(weight, 1.0, accuracy: 0.01)
    }

    // MARK: test averageDecayedBGReadingQuantity

    func testAverageDecayedBGReadingQuantity135() {

        let endDate = Date()
        let bgReadings = BGReadingTestHelper.bgReadings135(endDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadings,
                                                                          date: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 135.0
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    func testAverageDecayedBGReadingQuantityAlternating135and170() {

        let endDate = Date()
        let bgReadings = BGReadingTestHelper.bgReadingsAlternating135and170(endDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadings,
                                                                          date: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 152.327
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    func testAverageDecayedBGReadingQuantity150then50() {

        let endDate = Date()
        let bgReadings = BGReadingTestHelper.bgReadings150then50(endDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadings,
                                                                          date: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 100.792
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }
    
}
