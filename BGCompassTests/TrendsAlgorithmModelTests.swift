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
        // BGReading.quantity units mmol/L
        XCTAssertEqualWithAccuracy(TrendsAlgorithmModel.hA1cFromBloodGlucose(97.0 / MG_PER_DL_PER_MMOL_PER_L),
                                   5.0, accuracy: 0.02)
        XCTAssertEqualWithAccuracy(TrendsAlgorithmModel.hA1cFromBloodGlucose(240.0 / MG_PER_DL_PER_MMOL_PER_L),
                                   10.0, accuracy: 0.02)
        XCTAssertEqualWithAccuracy(TrendsAlgorithmModel.hA1cFromBloodGlucose(499.0 / MG_PER_DL_PER_MMOL_PER_L),
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

    // MARK: - test averageDecayedBGReadingQuantity

    // MARK: blood glucose 135

    func testAverageDecayedBGReadingQuantity135() {

        let endDate = Date()
        let bgReadings = BGReadingTestHelper.bgReadings135(endDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadings,
                                                                          endDate: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 135.0 / MG_PER_DL_PER_MMOL_PER_L
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    func testAverageDecayedBGReadingQuantityEndDateDistantPast() {

        let bgReadingsLastDate = Date()
        let bgReadings = BGReadingTestHelper.bgReadings135(bgReadingsLastDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadings,
                                                                          endDate: Date.distantPast,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        // all readings are after end date and were ignored
        let expected: Float = 0.0
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    func testAverageDecayedBGReadingQuantityEndDateDistantFuture() {

        let bgReadingsLastDate = Date()
        let bgReadings = BGReadingTestHelper.bgReadings135(bgReadingsLastDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadings,
                                                                          endDate: Date.distantFuture,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        // all readings are long before end date. hemoglobin has decayed and their weights are 0.
        let expected: Float = 0.0
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    // MARK: blood glucose 135 and 170

    func testAverageDecayedBGReadingQuantityAlternating135and170() {

        let endDate = Date()
        let bgReadings = BGReadingTestHelper.bgReadingsAlternating135and170(endDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadings,
                                                                          endDate: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 152.327 / MG_PER_DL_PER_MMOL_PER_L
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    // MARK: blood glucose 150 and 50

    func testAverageDecayedBGReadingQuantityBgReadings50at150then50at50() {

        let endDate = Date()
        let bgReadings = BGReadingTestHelper.bgReadings50at150then50at50(endDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadings,
                                                                          endDate: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 75.25 / MG_PER_DL_PER_MMOL_PER_L
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    // MARK: blood glucose 50 and 150

    func testAverageDecayedBGReadingQuantityBgReadings50at50then50at150() {

        let endDate = Date()
        let bgReadings = BGReadingTestHelper.bgReadings50at50then50at150(endDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadings,
                                                                          endDate: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 124.752 / MG_PER_DL_PER_MMOL_PER_L
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    // MARK: 30 at 150 then 70 at 50

    func testAverageDecayedBGReadingQuantityBgReadings30at150then70at50() {

        let endDate = Date()
        let bgReadings = BGReadingTestHelper.bgReadings30at150then70at50(endDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadings,
                                                                          endDate: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        
        let expected: Float = 99.2079 / MG_PER_DL_PER_MMOL_PER_L
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    func testAverageDecayedBGReadingQuantityBgReadings30at150then70at50_20DaysAgo() {

        let bgReadingsLastDate = Date()
        let endDate = bgReadingsLastDate.addingTimeInterval(-20.0 * Double(SECONDS_PER_DAY))
        
        let bgReadings = BGReadingTestHelper.bgReadings30at150then70at50(bgReadingsLastDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadings,
                                                                          endDate: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 130.269 / MG_PER_DL_PER_MMOL_PER_L
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    func testAverageDecayedBGReadingQuantityBgReadings30at150then70at50_29DaysAgo() {

        let bgReadingsLastDate = Date()
        let endDate = bgReadingsLastDate.addingTimeInterval(-29.0 * Double(SECONDS_PER_DAY))

        let bgReadings = BGReadingTestHelper.bgReadings30at150then70at50(bgReadingsLastDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadings,
                                                                          endDate: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 147.833 / MG_PER_DL_PER_MMOL_PER_L
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    // MARK: - testHa1cValueForBgReadings

    func testHa1cValueForBgReadings() {

        let endDate = Date()
        let bgReadings = BGReadingTestHelper.bgReadings135(endDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.ha1cValueForBgReadings(bgReadings,
                                                                 endDate: endDate,
                                                                 decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 6.331
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)

    }

}
