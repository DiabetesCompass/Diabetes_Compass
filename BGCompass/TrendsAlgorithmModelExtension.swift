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

}
