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

    struct SegueIdentifiers {
        static let trendsToBloodGlucoseTrend = "trendsToBloodGlucoseTrend"
        static let trendsToHa1cTrend = "trendsToHa1cTrend"
    }

    @IBOutlet var bloodGlucoseValueLabel: UILabel!
    @IBOutlet var bloodGlucoseView: UIView!

    @IBOutlet var ha1cValueLabel: UILabel!
    @IBOutlet var ha1cView: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Trends"

        configureReadings()
        configureBloodGlucoseViewGesture()
        configureHa1cViewGesture()
    }

    // MARK: - configure readings

    func configureReadings() {
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

    // MARK: - configure gestures

    func configureBloodGlucoseViewGesture() {
        let bloodGlucoseTapGesture = UITapGestureRecognizer(target: self,
                                                            action: #selector(bloodGlucoseViewTapped(_:)))
        bloodGlucoseView.addGestureRecognizer(bloodGlucoseTapGesture)
    }

    func configureHa1cViewGesture() {
        let ha1cTapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(ha1cViewTapped(_:)))
        ha1cView.addGestureRecognizer(ha1cTapGesture)
    }

    // MARK: - Navigation

    func bloodGlucoseViewTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: SegueIdentifiers.trendsToBloodGlucoseTrend,
                     sender: self)
    }

    func ha1cViewTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: SegueIdentifiers.trendsToHa1cTrend,
                     sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let identifier = segue.identifier else { return }

        switch identifier {

        case SegueIdentifiers.trendsToBloodGlucoseTrend:
            segue.destination.title = "Blood Glucose Trend"
            let trendViewController = segue.destination as! TrendViewController
            trendViewController.trend = .bg

        case SegueIdentifiers.trendsToHa1cTrend:
            segue.destination.title = "HA1c Trend"
            let trendViewController = segue.destination as! TrendViewController
            trendViewController.trend = .ha1c

        default:
            break
            
        }
    }

}
