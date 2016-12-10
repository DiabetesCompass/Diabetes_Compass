//
//  TrendsViewController.swift
//  BGCompass
//
//  Created by Steve Baker on 12/9/16.
//  Copyright © 2016 Clif Alferness. All rights reserved.
//

import UIKit

class TrendsViewController: UIViewController {

    @IBOutlet var bloodGlucoseValueLabel: UILabel!
    @IBOutlet var ha1cValueLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let trendsAlgorithmModel = TrendsAlgorithmModel.sharedInstance() as! TrendsAlgorithmModel

        bloodGlucoseValueLabel.text = "2.71"

        let lastHa1cReading: Ha1cReading = trendsAlgorithmModel.ha1cArray.last as! Ha1cReading
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        ha1cValueLabel.text = numberFormatter.string(from: lastHa1cReading.quantity)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
