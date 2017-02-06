//
//  BGReadingLightsHelper.swift
//  BGCompass
//
//  Created by Steve Baker on 2/5/17.
//  Copyright © 2017 Clif Alferness. All rights reserved.
//

import Foundation

/** This class returns [BGReadingLight] for use by Swift unit tests.
 */
class BGReadingLightsHelper: NSObject {

    /**
     - returns: an array of BGReadingLight
     readings are one day apart, ending on endDate
     Method name describes mg/dL, method converts units to mmol/L for BGReading.quantity
     */
    class func bgReadingLights135(endDate: Date) -> [BGReadingLight] {
        var bgReadingLights: [BGReadingLight] = []

        let date = Date()
        let numberOfReadings = 101;
        for i in 0..<numberOfReadings {

            // start with earliest reading
            let timeInterval = -Double(Int(SECONDS_PER_DAY) * ((numberOfReadings - 1) - i))
            let timeStamp = date.addingTimeInterval(timeInterval)
            let quantity = Float(135.0) / MG_PER_DL_PER_MMOL_PER_L
            let bgReadingLight = BGReadingLight(timeStamp: timeStamp, quantity: quantity)

            bgReadingLights.append(bgReadingLight)
        }
        return bgReadingLights
    }

    /** Method name describes mg/dL, method converts units to mmol/L for BGReading.quantity
     - returns: an array of BGReadingLight
     readings are one day apart, ending on endDate
     */
    class func bgReadingsLightsAlternating135and170(endDate: Date) -> [BGReadingLight] {
        var bgReadingLights: [BGReadingLight] = []

        let date = Date()
        let numberOfReadings = 101;
        for i in 0..<numberOfReadings {

            // start with earliest reading
            let timeInterval = -Double(Int(SECONDS_PER_DAY) * ((numberOfReadings - 1) - i))
            let timeStamp = date.addingTimeInterval(timeInterval)

            var quantity: Float = 0.0
            // use modulo operator %
            if (i % 2 == 0) {
                // i is even
                quantity = 135.0 / MG_PER_DL_PER_MMOL_PER_L
            } else {
                quantity = 170.0 / MG_PER_DL_PER_MMOL_PER_L
            }

            let bgReadingLight = BGReadingLight(timeStamp: timeStamp, quantity: quantity)

            bgReadingLights.append(bgReadingLight)
        }
        return bgReadingLights
    }

    /// Method name describes mg/dL, method converts units to mmol/L for BGReading.quantity
    class func bgReadingLights30at150then70at50(endDate: Date) -> [BGReadingLight] {
        return []
    }

    /// Method name describes mg/dL, method converts units to mmol/L for BGReading.quantity
    class func bgReadingLights50at150then50at50(endDate: Date) -> [BGReadingLight] {
        return []
    }

    /// Method name describes mg/dL, method converts units to mmol/L for BGReading.quantity
    class func bgReadingLights50at50then50at150(endDate: Date) -> [BGReadingLight] {
        return []
    }

}
