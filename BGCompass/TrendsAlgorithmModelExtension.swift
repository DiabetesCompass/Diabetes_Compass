//
//  TrendsAlgorithmModelExtension.swift
//  BGCompass
//
//  Created by Steve Baker on 12/11/16.
//  Copyright © 2016 Clif Alferness. All rights reserved.
//

import Foundation

/** Swift extension can extend a Swift class or an Objective C class
 http://ctarda.com/2016/05/swift-extensions-can-be-applied-to-objective-c-types/
 If this was a class would add @objc, but apparently
 for an extension this annotation is not needed or allowed
 */
extension TrendsAlgorithmModel {

    /**
    - returns: first reading in blood glucose array, else nil
    */
    func bgArrayReadingFirst() -> BGReading? {
        return self.getFromBGArray(0)
    }

    /**
    - returns: last reading in blood glucose array, else nil
    */
    func bgArrayReadingLast() -> BGReading? {
        if self.bgArrayCount() == 0 {
            return nil
        } else {
            let index = UInt(self.bgArrayCount()) - 1
            return self.getFromBGArray(index)
        }
    }

    /**
     - returns: first reading in HA1c array, else nil
     */
    func ha1cArrayReadingFirst() -> Ha1cReading? {
        return self.getFromHa1cArray(0)
    }

    /**
     - returns: last reading in HA1c array, else nil
    */
    func ha1cArrayReadingLast() -> Ha1cReading? {
        if self.ha1cArrayCount() == 0 {
            return nil
        } else {
            let index = UInt(self.ha1cArrayCount()) - 1
            return self.getFromHa1cArray(index)
        }
    }

    /**
     - returns: readings within hemoglobin lifespan before current reading, excluding current reading
     */
    func bloodGlucoseRecentReadings(currentReading: BGReading,
                                    readings: [BGReading],
                                    hemoglobinLifespanSeconds: TimeInterval) -> [BGReading] {
        
        // readingsWithinHemoglobinLifespan includes all readings that meet the filter criterium
        let readingsWithinHemoglobinLifespan = readings
            .filter( {
                isFirstDateBeforeSecondDateByLessThanTimeInterval( firstDate: $0.timeStamp,
                                                                   secondDate: currentReading.timeStamp,
                                                                   timeInterval: hemoglobinLifespanSeconds)
            } )
        return readingsWithinHemoglobinLifespan
    }

    /**
     - returns: true if firstDate is before secondDate by timeInterval or less.
     returns false if firstDate is at or after secondDate
     Note might possibly give incorrect result for very tiny differences due to Double inaccuracy
     */
    func isFirstDateBeforeSecondDateByLessThanTimeInterval(firstDate: Date,
                                                           secondDate: Date,
                                                           timeInterval: TimeInterval) -> Bool {

        let intervalFromFirstToSecond = secondDate.timeIntervalSince(firstDate)
        if intervalFromFirstToSecond <= 0.0 {
            // secondDate is before or at firstDate.
            return false
        } else {
            return intervalFromFirstToSecond < timeInterval
        }
    }


    // TODO: implement this, call from Objective C?
    func ha1cValueForBgReadings(_ bgReadings: [BGReading]) -> NSNumber? {
        return 0
    }


}
