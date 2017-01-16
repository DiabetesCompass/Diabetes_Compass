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
    static let yAxisLabelWidthFraction = 0.1

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
            configureAxes(graph: newGraph, trend: trend!)

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
        let length = NSNumber(value: (1.0 + yAxisLabelWidthFraction) * minutesLastMinusFirst)
        let range = CPTPlotRange(location: NSNumber(value: yAxisLabelWidthFraction * minutesLastMinusFirst),
                                 length: length)
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

        let location = NSNumber(value: TrendViewController.rangeMinimum(trend: trend)
            - xAxisLabelHeight(trend: trend))
        
        let length = NSNumber(value:TrendViewController.rangeMaximum(trend: trend)
            - TrendViewController.rangeMinimum(trend: trend)
            + TrendViewController.xAxisLabelHeight(trend: trend))

        let range = CPTPlotRange(location: location, length: length)
        return range
    }
    
    class func xAxisLabelHeight(trend: Trend) -> Double {
        var height = 0.0
        switch trend {
        case .bg:
            if BGReading.shouldDisplayBgInMmolPerL() {
                height = 1.0
            } else {
                height = 10.0
            }
        case .ha1c:
            height = 0.5
        }
        return height
    }

    class func rangeMaximum(trend: Trend) -> Double {
        var rangeMaximum = 0.0
        switch trend {
        case .bg:
            if BGReading.shouldDisplayBgInMmolPerL() {
                rangeMaximum = 300.0 / Double(MG_PER_DL_PER_MMOL_PER_L)
            } else {
                rangeMaximum = 300.0
            }
        case .ha1c:
            // TODO: set to maximum of all readings
            rangeMaximum = 11.0
        }
        return rangeMaximum
    }

    class func rangeMinimum(trend: Trend) -> Double {
        switch trend {
        case .bg:
            return 0.0
        case .ha1c:
            return 5.0
        }
    }
    
    func configureAxes(graph: CPTXYGraph, trend: Trend) {

        let axisSet = graph.axisSet as! CPTXYAxisSet

        if let x = axisSet.xAxis {
            configureAxis(x: x, trend: trend)
        }

        if let y = axisSet.yAxis {
            configureAxis(y: y, trend: trend)
        }
    }

    func configureAxis(x: CPTXYAxis, trend: Trend) {
        x.delegate = self

        x.labelFormatter = xLabelFormatter(range: nil)
        x.labelTextStyle = TrendViewController.textStyleWhite()
        x.axisLineStyle = TrendViewController.lineStyleThinWhite()
        x.majorTickLineStyle = TrendViewController.lineStyleThinWhite()
        x.minorTickLineStyle = TrendViewController.lineStyleThinWhite()
        x.majorIntervalLength   = TrendViewController.minutesPerWeek as NSNumber?

        // x axis located at y coordinate == x.orthogonalPosition
        switch trend {
        case .bg:
            x.orthogonalPosition = 0.0
        case .ha1c:
            x.orthogonalPosition = 5.0
        }

        // one day per minor tick
        x.minorTicksPerInterval = UInt(DAYS_IN_ONE_WEEK) - 1
        x.labelExclusionRanges  = [
            //CPTPlotRange(location: 0.99, length: 0.02),
            //CPTPlotRange(location: 1.99, length: 0.02),
            //CPTPlotRange(location: 2.99, length: 0.02)
        ]
    }

    func configureAxis(y: CPTXYAxis, trend: Trend) {
        y.delegate = self

        y.labelFormatter = yLabelFormatter(trend: trend)
        y.labelTextStyle = TrendViewController.textStyleWhite()
        y.axisLineStyle = TrendViewController.lineStyleThinWhite()
        y.majorTickLineStyle = TrendViewController.lineStyleThinWhite()
        y.minorTickLineStyle = TrendViewController.lineStyleThinWhite()

        // y axis located at x coordinate == y.orthogonalPosition
        // range.location is axis start, range.length is axis (end - start)
        let xRange = TrendViewController.xRange(trendsAlgorithmModel: trendsAlgorithmModel,
                                                      trend: trend)
        let xRangeLocation = xRange.location.doubleValue
        let xRangeLength = xRange.length.doubleValue
        y.orthogonalPosition = NSNumber(value:(xRangeLocation + (TrendViewController.yAxisLabelWidthFraction * xRangeLength)))

        y.labelExclusionRanges  = [
            //CPTPlotRange(location: 0.99, length: 0.02),
            //CPTPlotRange(location: 1.99, length: 0.02),
            //CPTPlotRange(location: 3.99, length: 0.02)
        ]

        switch trend {
        case .bg:
            if BGReading.shouldDisplayBgInMmolPerL() {
                y.majorIntervalLength   = 1
                y.minorTicksPerInterval = 1
            } else {
                y.majorIntervalLength   = 20
                y.minorTicksPerInterval = 1
            }
        case .ha1c:
            y.majorIntervalLength   = 1
            y.minorTicksPerInterval = 1
        }
    }

    func styledPlot(trend: Trend) -> CPTScatterPlot {
        let plot = CPTScatterPlot(frame: .zero)
        plot.dataLineStyle = TrendViewController.lineStyleWhite()

        switch trend {
        case .bg:
            plot.identifier = NSString.init(string: "bg")
        case .ha1c:
            plot.identifier = NSString.init(string: "ha1c")
        }
        return plot
    }

    class func plotSymbol() -> CPTPlotSymbol {
        let symbolLineStyle = CPTMutableLineStyle()
        symbolLineStyle.lineColor = .white()
        let symbol = CPTPlotSymbol.ellipse()
        symbol.fill          = CPTFill(color: .white())
        symbol.lineStyle     = symbolLineStyle
        symbol.size          = CGSize(width: 5.0, height: 5.0)
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
        lineStyle.lineWidth = 1.0
        lineStyle.miterLimit = 1.0
        return lineStyle
    }

    class func textStyleWhite() -> CPTMutableTextStyle {
        let textStyle = CPTMutableTextStyle()
        textStyle.color = .white()
        return textStyle
    }

    // MARK: - label formatters 

    func xLabelFormatter(range: CPTPlotRange?) -> CPTCalendarFormatter {
        guard let firstReading = trendsAlgorithmModel?.ha1cArrayReadingFirst() else {
            return CPTCalendarFormatter()
        }

        let dateFormatter = DateFormatter()
        // e.g. "12/5/16"
        //dateFormatter.dateStyle = .short
        // e.g. "Dec 5, 2016"
        //dateFormatter.dateStyle = .medium
        // e.g. "12/05"
        let templateString = templateStringForRange(range)
        let formatString = DateFormatter.dateFormat(fromTemplate: templateString,
                                                    options:0, locale:NSLocale.current)
        dateFormatter.dateFormat = formatString

        let cptFormatter = CPTCalendarFormatter()
        cptFormatter.dateFormatter = dateFormatter
        cptFormatter.referenceDate = firstReading.timeStamp
        cptFormatter.referenceCalendarUnit = NSCalendar.Unit.minute
        return cptFormatter
    }

    /**
     - parameter range: plot range
     - returns: a template string suitable for use by a date formatter
     */
    func templateStringForRange(_ range: CPTPlotRange?) -> String {

        var templateString = "MM/dd"

        guard let axisRange = range else {
            return templateString
        }

        if axisRange.lengthDouble >= Double(MINUTES_IN_ONE_HOUR * HOURS_IN_ONE_DAY * DAYS_IN_ONE_WEEK * 52) {
            templateString = "MM/dd"
        } else if axisRange.lengthDouble >= Double(MINUTES_IN_ONE_HOUR * HOURS_IN_ONE_DAY * 8) {
            templateString = "MMM dd"
        } else if axisRange.lengthDouble >= Double(MINUTES_IN_ONE_HOUR * HOURS_IN_ONE_DAY * 2) {
            templateString = "Md"
        } else {
            if UserDefaults.standard.bool(forKey: SETTING_MILITARY_TIME) {
                templateString = "HH Md"
            } else {
                templateString = "hh a Md"
            }
        }
        return templateString
    }

    func yLabelFormatter(trend: Trend) -> NumberFormatter {

        let formatter = NumberFormatter()

        switch trend {
        case .bg:
            if BGReading.shouldDisplayBgInMmolPerL() {
                formatter.minimumFractionDigits = 1
                formatter.maximumFractionDigits = 1
            } else {
                formatter.minimumFractionDigits = 0
                formatter.maximumFractionDigits = 0
            }
        case .ha1c:
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
        }
        return formatter
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
                if BGReading.shouldDisplayBgInMmolPerL() {
                    // display mmol/L
                    return reading.quantity
                } else {
                    // display mg/dL
                    return MG_PER_DL_PER_MMOL_PER_L * reading.quantity.floatValue
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

    func plotSpace(_ space: CPTPlotSpace, willDisplaceBy: CGPoint) -> CGPoint {
        // translate horizontally but not vertically
        return CGPoint(x: 1.5 * willDisplaceBy.x, y: 0)
    }

    func plotSpace(_ space: CPTPlotSpace,
                   willChangePlotRangeTo newRange: CPTPlotRange,
                   for coordinate: CPTCoordinate) -> CPTPlotRange? {

        let range: CPTMutablePlotRange = CPTMutablePlotRange(location: newRange.location,
                                                             length:newRange.length)

        // Adjust axes to keep them in view at the left and bottom
        let axisSet: CPTXYAxisSet = space.graph!.axisSet as! CPTXYAxisSet
        if coordinate == CPTCoordinate.X {
            axisSet.yAxis?.orthogonalPosition = NSNumber(value:(range.location.doubleValue
                + (0.1 * range.lengthDouble)))
            axisSet.xAxis?.labelFormatter = xLabelFormatter(range: range)
        } else if (coordinate == CPTCoordinate.Y)
            && (trend != nil) {
            axisSet.xAxis?.orthogonalPosition = NSNumber(value:(range.location.doubleValue
                + TrendViewController.xAxisLabelHeight(trend: trend!)))
        }
        return range
    }
}
