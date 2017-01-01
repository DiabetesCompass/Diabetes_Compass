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

    enum Trend {
        case bg, ha1c
    }

    static let minutesPerWeek = Double(MINUTES_IN_ONE_HOUR * HOURS_IN_ONE_DAY * DAYS_IN_ONE_WEEK)
    static let yAxisLabelWidth = 1200.0

    var trendsAlgorithmModel: TrendsAlgorithmModel?

    private var scatterGraph: CPTXYGraph? = nil

    @IBOutlet var hostingView: CPTGraphHostingView!

    var trend: Trend?


    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        trendsAlgorithmModel = TrendsAlgorithmModel.sharedInstance() as! TrendsAlgorithmModel?

        let newGraph = CPTXYGraph(frame: .zero)
        hostingView.backgroundColor = UIColor(red:85.0/255.0, green:150.0/255.0, blue:194.0/255.0, alpha:1)

        hostingView.hostedGraph = newGraph

        configurePaddings(graph: newGraph)
        if trend != nil {
            configurePlotSpace(graph: newGraph, trend: trend!)
            configureAxes(graph: newGraph)

            let boundLinePlot = styledPlot(trend: trend!)
            boundLinePlot.dataSource = self
            newGraph.add(boundLinePlot)
            boundLinePlot.plotSymbol = TrendViewController.plotSymbol()
        }

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
    func configurePlotSpace(graph: CPTXYGraph, trend: Trend) {
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace

        plotSpace.delegate = self

        plotSpace.allowsUserInteraction = true

        // limit scrolling?
        // http://stackoverflow.com/questions/18784140/coreplot-allow-horizontal-scrolling-in-positive-quadrant-only?rq=1
        plotSpace.globalXRange = TrendViewController.globalXRange(trendsAlgorithmModel: trendsAlgorithmModel,
                                                                  trend: trend)
        // location is axis start, length is axis (end - start)
        plotSpace.xRange = TrendViewController.xRange(trendsAlgorithmModel: trendsAlgorithmModel,
                                                      trend: trend)

        plotSpace.globalYRange = TrendViewController.globalYRange(trend: trend)
        plotSpace.yRange = plotSpace.globalYRange!
    }

    /**
     Typically bgArray and ha1cArray have same number of elements, with same timeStamps
     So globalXRange returns same range for either trend
     */
    class func globalXRange(trendsAlgorithmModel: TrendsAlgorithmModel?, trend: Trend) -> CPTPlotRange {
        let rangeEmpty = CPTPlotRange(location: 0.0, length: 0.0)

        var dateFirst: Date?
        var dateLast: Date?

        switch trend {
        case .bg:
            dateFirst = trendsAlgorithmModel?.bgArrayReadingFirst()?.timeStamp
            dateLast = trendsAlgorithmModel?.bgArrayReadingLast()?.timeStamp
        case .ha1c:
            dateFirst = trendsAlgorithmModel?.ha1cArrayReadingFirst()?.timeStamp
            dateLast = trendsAlgorithmModel?.ha1cArrayReadingLast()?.timeStamp
        }

        guard let first = dateFirst, let last = dateLast else { return rangeEmpty }

        let minutesLastMinusFirst = last.timeIntervalSince(first) / Double(SECONDS_IN_ONE_MINUTE)
        // TODO: Fix me vertical axis not visible when graph first appears
        let length = NSNumber(value: minutesLastMinusFirst + yAxisLabelWidth)
        let range = CPTPlotRange(location: NSNumber(value: -yAxisLabelWidth), length: length)
        return range
    }

    class func xRange(trendsAlgorithmModel: TrendsAlgorithmModel?, trend: Trend) -> CPTPlotRange {
        let rangeEmpty = CPTPlotRange(location: 0.0, length: 0.0)

        var dateFirst: Date?
        var dateLast: Date?

        switch trend {
        case .bg:
            dateFirst = trendsAlgorithmModel?.bgArrayReadingFirst()?.timeStamp
            dateLast = trendsAlgorithmModel?.bgArrayReadingLast()?.timeStamp

        case .ha1c:
            dateFirst = trendsAlgorithmModel?.ha1cArrayReadingFirst()?.timeStamp
            dateLast = trendsAlgorithmModel?.ha1cArrayReadingLast()?.timeStamp
        }

        guard let first = dateFirst, let last = dateLast else { return rangeEmpty }

        let minutesLastMinusFirst = last.timeIntervalSince(first) / Double(SECONDS_IN_ONE_MINUTE)
        let location = minutesLastMinusFirst - minutesPerWeek
        let range = CPTPlotRange(location: NSNumber(value:location), length: NSNumber(value: minutesPerWeek))
        return range
    }

    class func globalYRange(trend: Trend) -> CPTPlotRange {
        let length = NSNumber(value:TrendViewController.rangeMaximum(trend: trend)
            + TrendViewController.xAxisLabelHeight(trend: trend))
        let range = CPTPlotRange(location: NSNumber(value: -xAxisLabelHeight(trend: trend)),
                                 length: length)
        return range
    }
    
    class func xAxisLabelHeight(trend: Trend) -> Double {
        switch trend {
        case .bg:
            return 5.0
        case .ha1c:
            return 0.5
        }
    }

    // TODO: ha1c rangeMinimum 5

    class func rangeMaximum(trend: Trend) -> Double {
        switch trend {
        case .bg:
            return 300.0
        case .ha1c:
            // TODO: set to all readings maximum
            return 11.0
        }
    }

    func configureAxes(graph: CPTXYGraph) {

        let axisSet = graph.axisSet as! CPTXYAxisSet

        if let x = axisSet.xAxis {
            x.delegate = self

            x.labelFormatter = xLabelFormatter()
            x.labelTextStyle = TrendViewController.textStyleWhite()
            x.axisLineStyle = TrendViewController.lineStyleThinWhite()
            x.majorTickLineStyle = TrendViewController.lineStyleThinWhite()
            x.minorTickLineStyle = TrendViewController.lineStyleThinWhite()
            x.majorIntervalLength   = TrendViewController.minutesPerWeek as NSNumber?
            // x axis located at y coordinate == x.orthogonalPosition
            x.orthogonalPosition    = 0.0
            // one day per minor tick
            x.minorTicksPerInterval = UInt(DAYS_IN_ONE_WEEK) - 1
            x.labelExclusionRanges  = [
                //CPTPlotRange(location: 0.99, length: 0.02),
                //CPTPlotRange(location: 1.99, length: 0.02),
                //CPTPlotRange(location: 2.99, length: 0.02)
            ]
        }

        if let y = axisSet.yAxis {
            y.delegate = self

            y.labelTextStyle = TrendViewController.textStyleWhite()
            y.axisLineStyle = TrendViewController.lineStyleThinWhite()
            y.majorTickLineStyle = TrendViewController.lineStyleThinWhite()
            y.minorTickLineStyle = TrendViewController.lineStyleThinWhite()

            // y axis located at x coordinate == y.orthogonalPosition
            y.orthogonalPosition    = 0.0
            y.labelExclusionRanges  = [
                //CPTPlotRange(location: 0.99, length: 0.02),
                //CPTPlotRange(location: 1.99, length: 0.02),
                //CPTPlotRange(location: 3.99, length: 0.02)
            ]

            guard let trendUnwrapped = trend else { return }
            switch trendUnwrapped {
            case .bg:
                y.majorIntervalLength   = 10
                y.minorTicksPerInterval = 1
            case .ha1c:
                y.majorIntervalLength   = 1
                y.minorTicksPerInterval = 1
            }
        }
    }

    func styledPlot(trend: Trend) -> CPTScatterPlot {
        let plot = CPTScatterPlot(frame: .zero)
        plot.dataLineStyle = TrendViewController.lineStyleWhite()

        switch trend {
        case .bg:
            plot.identifier    = NSString.init(string: "bg")
        case .ha1c:
            plot.identifier    = NSString.init(string: "ha1c")
        }
        return plot
    }

    class func plotSymbol() -> CPTPlotSymbol {
        let symbolLineStyle = CPTMutableLineStyle()
        symbolLineStyle.lineColor = .white()
        let symbol = CPTPlotSymbol.ellipse()
        symbol.fill          = CPTFill(color: .white())
        symbol.lineStyle     = symbolLineStyle
        symbol.size          = CGSize(width: 10.0, height: 10.0)
        return symbol
    }

    class func lineStyleThinWhite() -> CPTMutableLineStyle {
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = .white()
        lineStyle.lineWidth = 1.0
        return lineStyle
    }

    class func lineStyleWhite() -> CPTMutableLineStyle {
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = .white()
        lineStyle.lineWidth = 3.0
        lineStyle.miterLimit = 1.0
        return lineStyle
    }

    class func textStyleWhite() -> CPTMutableTextStyle {
        let textStyle = CPTMutableTextStyle()
        textStyle.color = .white()
        return textStyle
    }

    func xLabelFormatter() -> CPTCalendarFormatter {
        guard let firstReading = trendsAlgorithmModel?.ha1cArrayReadingFirst() else {
            return CPTCalendarFormatter()
        }

        let dateFormatter = DateFormatter()
        // e.g. "12/5/16"
        //dateFormatter.dateStyle = .short
        // e.g. "Dec 5, 2016"
        //dateFormatter.dateStyle = .medium
        // e.g. "12/05"
        let formatString = DateFormatter.dateFormat(fromTemplate: "MM/dd", options:0, locale:NSLocale.current)
        dateFormatter.dateFormat = formatString

        let cptFormatter = CPTCalendarFormatter()
        cptFormatter.dateFormatter = dateFormatter
        cptFormatter.referenceDate = firstReading.timeStamp
        cptFormatter.referenceCalendarUnit = NSCalendar.Unit.minute
        return cptFormatter
    }

}

// MARK: - CPTPlotDataSource
extension TrendViewController: CPTPlotDataSource {

    /** @brief @required The number of data points for the plot.
     *  @param plot The plot.
     *  @return The number of data points for the plot.
     **/
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        guard let model: TrendsAlgorithmModel = trendsAlgorithmModel,
            let trendUnwrapped = trend else { return 0 }
        switch trendUnwrapped {
        case .bg:
            return UInt(model.bgArrayCount())
        case .ha1c:
            //return UInt(model.ha1cArray.count)
            return UInt(model.ha1cArrayCount())
        }
    }

    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any? {

        guard let model: TrendsAlgorithmModel = trendsAlgorithmModel,
            let trendUnwrapped = trend else {
                return nil
        }

        // plotField = CPTScatterPlotField(0) == .X
        // plotField = CPTScatterPlotField(1) == .Y
        let plotField = CPTScatterPlotField(rawValue: Int(field))

        switch trendUnwrapped {

        case .bg:

            let reading = model.getFromBGArray(record) as BGReading
            let firstReading = model.bgArrayReadingFirst()

            if plotField == .X {
                guard let dateFirst = firstReading?.timeStamp else { return nil }
                let timeIntervalSeconds: TimeInterval = reading.timeStamp.timeIntervalSince(dateFirst)
                let timeIntervalMinutes: Double = timeIntervalSeconds / 60
                return NSNumber(value: timeIntervalMinutes)

            } else if plotField == .Y {
                if BGReading.isInMoles() {
                    return reading.quantity
                } else {
                    return reading.quantity.floatValue * Float(MG_PER_DL_PER_MMOL_PER_L)
                }
            }

        case .ha1c:

            let reading = model.getFromHa1cArray(record) as Ha1cReading
            let firstReading = model.ha1cArrayReadingFirst()

            if plotField == .X {
                guard let dateFirst = firstReading?.timeStamp else { return nil }
                let timeIntervalSeconds: TimeInterval = reading.timeStamp.timeIntervalSince(dateFirst)
                let timeIntervalMinutes: Double = timeIntervalSeconds / 60
                return NSNumber(value: timeIntervalMinutes)

            } else if plotField == .Y {
                return reading.quantity
            }

        }
        return nil
    }
}

// MARK: - CPTAxisDelegate
extension TrendViewController: CPTAxisDelegate {

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

// MARK: - CPTPlotSpaceDelegate
extension TrendViewController: CPTPlotSpaceDelegate {

    func plotSpace(_ space: CPTPlotSpace,
                   willChangePlotRangeTo newRange: CPTPlotRange,
                   for coordinate: CPTCoordinate) -> CPTPlotRange? {

        let range: CPTMutablePlotRange = CPTMutablePlotRange(location: newRange.location,
                                                             length:newRange.length)

        // Display only Quadrant I: never let the location go negative.
        //
        //        if range.locationDouble < 0.0 {
        //            range.location = 0.0
        //        }

        // Adjust axis to keep them in view at the left and bottom;
        // adjust scale-labels to match the scroll.
        //
        let axisSet: CPTXYAxisSet = space.graph!.axisSet as! CPTXYAxisSet
        if coordinate == CPTCoordinate.X {
            axisSet.yAxis?.orthogonalPosition = NSNumber(value:(range.location.doubleValue + TrendViewController.yAxisLabelWidth))
            //axisSet.xAxis?.titleLocation = CPTDecimalFromDouble(range.locationDouble + (range.lengthDouble / 2.0)) as NSNumber?
        } else if (coordinate == CPTCoordinate.Y)
            && (trend != nil) {
            axisSet.xAxis?.orthogonalPosition = NSNumber(value:(range.location.doubleValue
                + TrendViewController.xAxisLabelHeight(trend: trend!)))
            //axisSet.yAxis?.titleLocation = CPTDecimalFromDouble(range.locationDouble + (range.lengthDouble / 2.0)) as NSNumber?
        }
        return range
    }
}
