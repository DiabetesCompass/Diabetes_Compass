//
//  TrendViewController.swift
//  BGCompass
//
//  Created by Steve Baker on 12/10/16.
//  Copyright © 2016 Clif Alferness. All rights reserved.
//

import UIKit

class TrendViewController : UIViewController {
    private var scatterGraph : CPTXYGraph? = nil

    typealias plotDataType = [CPTScatterPlotField : Double]
    fileprivate var dataForPlot = [plotDataType]()

    @IBOutlet var hostingView: CPTGraphHostingView!

    // MARK: - View lifecycle

    override func viewDidAppear(_ animated : Bool) {
        super.viewDidAppear(animated)

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

        self.dataForPlot = TrendViewController.contentArray()

        self.scatterGraph = newGraph
    }

    // MARK: - configuration

    func configurePaddings(graph: CPTXYGraph) {
        graph.paddingLeft   = 10.0
        graph.paddingRight  = 10.0
        graph.paddingTop    = 10.0
        graph.paddingBottom = 10.0
    }

    func configurePlotSpace(graph: CPTXYGraph) {
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.yRange = CPTPlotRange(location:1.0, length:2.0)
        plotSpace.xRange = CPTPlotRange(location:1.0, length:3.0)
    }

    func configureAxes(graph: CPTXYGraph) {

        let axisSet = graph.axisSet as! CPTXYAxisSet

        if let x = axisSet.xAxis {
            x.majorIntervalLength   = 0.5
            x.orthogonalPosition    = 2.0
            x.minorTicksPerInterval = 2
            x.labelExclusionRanges  = [
                CPTPlotRange(location: 0.99, length: 0.02),
                CPTPlotRange(location: 1.99, length: 0.02),
                CPTPlotRange(location: 2.99, length: 0.02)
            ]
        }

        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 0.5
            y.minorTicksPerInterval = 5
            y.orthogonalPosition    = 2.0
            y.labelExclusionRanges  = [
                CPTPlotRange(location: 0.99, length: 0.02),
                CPTPlotRange(location: 1.99, length: 0.02),
                CPTPlotRange(location: 3.99, length: 0.02)
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

    /// return sample data
    class func contentArray() -> [plotDataType] {
        var content = [plotDataType]()
        for i in 0 ..< 60 {
            let x = 1.0 + Double(i) * 0.05
            let y = 1.2 * Double(arc4random()) / Double(UInt32.max) + 1.2
            let dataPoint: plotDataType = [.X: x, .Y: y]
            content.append(dataPoint)
        }
        return content
    }

}

extension TrendViewController: CPTBarPlotDataSource, CPTBarPlotDelegate {

    /** @brief @required The number of data points for the plot.
     *  @param plot The plot.
     *  @return The number of data points for the plot.
     **/
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(self.dataForPlot.count)
    }

    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any? {
        // plotField = CPTScatterPlotField(0) == .X
        // plotField = CPTScatterPlotField(1) == .Y
        let plotField = CPTScatterPlotField(rawValue: Int(field))

        guard let num = self.dataForPlot[Int(record)][plotField!] else {
            return nil
        }
        return num as NSNumber
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
