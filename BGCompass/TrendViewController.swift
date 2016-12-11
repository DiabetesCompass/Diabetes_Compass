//
//  TrendViewController.swift
//  BGCompass
//
//  Created by Steve Baker on 12/10/16.
//  Copyright © 2016 Clif Alferness. All rights reserved.
//

import UIKit

// https://github.com/core-plot/core-plot/blob/master/examples/CPTTestApp-iPhone/Classes/ScatterPlotController.swift

class TrendViewController : UIViewController {

    var trendsAlgorithmModel: TrendsAlgorithmModel?

    private var scatterGraph : CPTXYGraph? = nil

    @IBOutlet var hostingView: CPTGraphHostingView!

    // MARK: - View lifecycle

    override func viewDidAppear(_ animated : Bool) {
        super.viewDidAppear(animated)

        trendsAlgorithmModel = TrendsAlgorithmModel.sharedInstance() as! TrendsAlgorithmModel?

        let newGraph = CPTXYGraph(frame: .zero)
        newGraph.apply(CPTTheme(named: .darkGradientTheme))

        hostingView.hostedGraph = newGraph

        configurePaddings(graph: newGraph)
        configurePlotSpace(graph: newGraph)
        configureAxes(graph: newGraph)

        let boundLinePlot = styledPlot()
        boundLinePlot.dataSource = self
        newGraph.add(boundLinePlot)

        configureFill(plot: boundLinePlot)

        boundLinePlot.plotSymbol = TrendViewController.plotSymbol()

        self.scatterGraph = newGraph
    }

    // MARK: - configuration

    func configurePaddings(graph: CPTXYGraph) {
        graph.paddingLeft   = 10.0
        graph.paddingRight  = 10.0
        graph.paddingTop    = 10.0
        graph.paddingBottom = 10.0
    }

    /// set axes range start and length
    func configurePlotSpace(graph: CPTXYGraph) {
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        // location is axis start, length is axis (end - start)
        plotSpace.xRange = CPTPlotRange(location:-10000.0, length:110000.0)
        plotSpace.yRange = CPTPlotRange(location:-1.0, length:11.0)
    }

    func configureAxes(graph: CPTXYGraph) {

        let axisSet = graph.axisSet as! CPTXYAxisSet

        if let x = axisSet.xAxis {
            x.majorIntervalLength   = 50000
            // x axis located at y coordinate == x.orthogonalPosition
            x.orthogonalPosition    = 0.0
            x.minorTicksPerInterval = 0
            x.labelExclusionRanges  = [
                //CPTPlotRange(location: 0.99, length: 0.02),
                //CPTPlotRange(location: 1.99, length: 0.02),
                //CPTPlotRange(location: 2.99, length: 0.02)
            ]
        }

        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 1
            y.minorTicksPerInterval = 1
            // y axis located at x coordinate == y.orthogonalPosition
            y.orthogonalPosition    = 0.0
            y.labelExclusionRanges  = [
                //CPTPlotRange(location: 0.99, length: 0.02),
                //CPTPlotRange(location: 1.99, length: 0.02),
                //CPTPlotRange(location: 3.99, length: 0.02)
            ]
            y.delegate = self
        }
    }

    func styledPlot() -> CPTScatterPlot {
        let plot = CPTScatterPlot(frame: .zero)
        let blueLineStyle = CPTMutableLineStyle()
        blueLineStyle.miterLimit    = 1.0
        blueLineStyle.lineWidth     = 3.0
        blueLineStyle.lineColor     = .blue()
        plot.dataLineStyle = blueLineStyle
        plot.identifier    = NSString.init(string: "Blue Plot")
        return plot
    }

    /// fill the area under the graph
    func configureFill(plot: CPTScatterPlot) {
        let fillImage = CPTImage(named:"cool2")
        fillImage.isTiled = true
        plot.areaFill      = CPTFill(image: fillImage)
        plot.areaBaseValue = 0.0
    }

    class func plotSymbol() -> CPTPlotSymbol {
        let symbolLineStyle = CPTMutableLineStyle()
        symbolLineStyle.lineColor = .black()
        let symbol = CPTPlotSymbol.ellipse()
        symbol.fill          = CPTFill(color: .blue())
        symbol.lineStyle     = symbolLineStyle
        symbol.size          = CGSize(width: 10.0, height: 10.0)
        return symbol
    }

}

extension TrendViewController: CPTBarPlotDataSource, CPTBarPlotDelegate {

    /** @brief @required The number of data points for the plot.
     *  @param plot The plot.
     *  @return The number of data points for the plot.
     **/
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        //return UInt(self.dataForPlot.count)
        guard let model: TrendsAlgorithmModel = trendsAlgorithmModel else { return 0 }
        //return UInt(model.bgArrayCount())
        return UInt(model.ha1cArray.count)
    }

    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any? {
        // plotField = CPTScatterPlotField(0) == .X
        // plotField = CPTScatterPlotField(1) == .Y
        let plotField = CPTScatterPlotField(rawValue: Int(field))

        guard let model: TrendsAlgorithmModel = trendsAlgorithmModel else { return nil }
        let reading = model.getFromHa1cArray(record) as Ha1cReading

        if plotField == .X {
            guard let firstReading = model.ha1cArray.first as! Ha1cReading? else { return nil }

            guard let dateFirst = firstReading.timeStamp else { return nil }
            let timeIntervalSeconds: TimeInterval = reading.timeStamp.timeIntervalSince(dateFirst)
            let timeIntervalMinutes: Double = timeIntervalSeconds / 60
            return NSNumber(value: timeIntervalMinutes)

        } else if plotField == .Y {
            return reading.quantity
        } else {
            return nil
        }
    }

    // MARK: Axis Delegate Methods

    private func axis(_ axis: CPTAxis,
                      shouldUpdateAxisLabelsAtLocations locations: NSSet!) -> Bool {
        if let formatter = axis.labelFormatter {
            let labelOffset = axis.labelOffset

            var newLabels = Set<CPTAxisLabel>()

            if let labelTextStyle = axis.labelTextStyle?.mutableCopy() as? CPTMutableTextStyle {
                for location in locations {
                    if let tickLocation = location as? NSNumber {
                        if tickLocation.doubleValue >= 0.0 {
                            labelTextStyle.color = .green()
                        }
                        else {
                            labelTextStyle.color = .red()
                        }

                        let labelString   = formatter.string(for:tickLocation)
                        let newLabelLayer = CPTTextLayer(text: labelString, style: labelTextStyle)

                        let newLabel = CPTAxisLabel(contentLayer: newLabelLayer)
                        newLabel.tickLocation = tickLocation
                        newLabel.offset       = labelOffset

                        newLabels.insert(newLabel)
                    }
                }

                axis.axisLabels = newLabels
            }
        }
        
        return false
    }
}
