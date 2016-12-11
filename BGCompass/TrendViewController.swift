//
//  TrendViewController.swift
//  BGCompass
//
//  Created by Steve Baker on 12/10/16.
//  Copyright © 2016 Clif Alferness. All rights reserved.
//

import UIKit

class TrendViewController: UIViewController {

    @IBOutlet var graphView: CPTGraphHostingView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // https://www.raywenderlich.com/131985/core-plot-tutorial-getting-started
        // create graph
        let graph = CPTXYGraph(frame: CGRect.zero)
        //graph.title = "Hello Graph"
        graph.paddingLeft = 0
        graph.paddingTop = 0
        graph.paddingRight = 0
        graph.paddingBottom = 0
        // hide the axes
        let axes = graph.axisSet as! CPTXYAxisSet
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineWidth = 0
        axes.xAxis?.axisLineStyle = lineStyle
        axes.yAxis?.axisLineStyle = lineStyle

        // add a pie plot
        let pie = CPTPieChart()
        pie.dataSource = self
        pie.pieRadius = (self.view.frame.size.width * 0.9)/2
        graph.add(pie)

        graphView.hostedGraph = graph
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TrendViewController: CPTBarPlotDataSource, CPTBarPlotDelegate {

    /** @brief @required The number of data points for the plot.
     *  @param plot The plot.
     *  @return The number of data points for the plot.
     **/
    public func numberOfRecords(for plot: CPTPlot) -> UInt {
        return 4
    }

    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        return idx + 1
    }

    // MARK: - CPTPlotSpaceDelegate
    
}
