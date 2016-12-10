//
//  TrendsViewController.swift
//  BGCompass
//
//  Created by Steve Baker on 12/9/16.
//  Copyright © 2016 Clif Alferness. All rights reserved.
//

import UIKit

class TrendsViewController: UIViewController {

    // http://stackoverflow.com/questions/25918628/how-to-define-static-constant-in-a-class-in-swift#27339577
    struct Constants {
        // concentration units
        static let milligramsPerDeciliter = "mg/dL"
    }
 
    @IBOutlet var bloodGlucoseValueLabel: UILabel!
    @IBOutlet var ha1cValueLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Trends"

        // reference TrendsContainerViewController
        let trendsAlgorithmModel = TrendsAlgorithmModel.sharedInstance() as! TrendsAlgorithmModel

        let lastBGReading = trendsAlgorithmModel.bgArray.last as? BGReading
        bloodGlucoseValueLabel.text = TrendsViewController.bloodGlucoseText(reading: lastBGReading)

        let lastHa1cReading = trendsAlgorithmModel.ha1cArray.last as? Ha1cReading
        ha1cValueLabel.text = TrendsViewController.ha1cText(reading: lastHa1cReading)
    }

    class func bloodGlucoseText(reading: BGReading?) -> String {
        if reading == nil {
            return "No data"
        } else {
            return BGReading.displayString(reading!.quantity,
                                           withConversion: true)
                + " "
                + Constants.milligramsPerDeciliter
        }
    }

    class func ha1cText(reading: Ha1cReading?) -> String {
        if reading == nil {
            return "No data"
        } else {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            return numberFormatter.string(from: reading!.quantity)!
                + " "
                + Constants.milligramsPerDeciliter
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
