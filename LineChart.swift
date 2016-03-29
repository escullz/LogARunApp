//
//  LineChart.swift
//  LogARun
//
//  Created by Emmett Scully on 3/2/16.
//  Copyright © 2016 pixyzehn. All rights reserved.
//

import UIKit
import QuartzCore

// delegate method
public protocol LineChartDelegate {
    func didSelectDataPoint2(x: CGFloat, yValues: [CGFloat])
}

extension UIView {
    func layerGradient() {
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = self.frame.size
        layer.frame.origin = CGPointMake(0.0,0.0)
        
        let color0 = UIColor(red: 0.0901961, green: 0.745098, blue: 0.811765, alpha: 1).CGColor
        let color1 = UIColor(red:200.0/255, green:200.0/255, blue: 200.0/255, alpha:0.0).CGColor
        
        
        layer.colors = [color0,color1]
        self.layer.insertSublayer(layer, atIndex: 0)
    }
}

/**
 * LineChart
 */
public class LineChart: UIView {
    
    /**
     * Helpers class
     */
    private class Helpers {
        
        /**
         * Convert hex color to UIColor
         */
        private class func UIColorFromHex(hex: Int) -> UIColor {
            let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
            let blue = CGFloat((hex & 0xFF)) / 255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1)
        }
        
        /**
         * Lighten color.
         */
        private class func lightenUIColor(color: UIColor) -> UIColor {
            var h: CGFloat = 0
            var s: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            return UIColor(hue: h, saturation: s, brightness: b * 1.5, alpha: a)
        }
    }
    
    public struct Labels {
        public var visible: Bool = true
        public var values: [String] = []
    }
    
    public struct Grid {
        public var visible: Bool = true
        public var count: CGFloat = 10
        // #eeeeee
        public var color: UIColor = UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
    }
    
    public struct Axis {
        public var visible: Bool = true
        // #607d8b
        public var color: UIColor = UIColor(red: 96/255.0, green: 125/255.0, blue: 139/255.0, alpha: 1)
        public var inset: CGFloat = 15
    }
    
    public struct Coordinate {
        // public
        public var labels: Labels = Labels()
        public var grid: Grid = Grid()
        public var axis: Axis = Axis()
        
        // private
        private var linear: LinearScale!
        private var scale: ((CGFloat) -> CGFloat)!
        private var invert: ((CGFloat) -> CGFloat)!
        private var ticks: (CGFloat, CGFloat, CGFloat)!
    }
    
    public struct Animation {
        public var enabled: Bool = true
        public var duration: CFTimeInterval = 1
    }
    
    public struct Dots {
        
        public var visible: Bool = true
        public var color: UIColor =  UIColor(
            red: 0x34/255,
            green: 0x67/255,
            blue: 0x33/255,
            alpha: 0.7)
    
        public var innerRadius: CGFloat = 20
        public var outerRadius: CGFloat = 38
        public var innerRadiusHighlighted: CGFloat = 40
        public var outerRadiusHighlighted: CGFloat = 80
    }
    
    
    // default configuration
    public var area: Bool = true
    public var animation: Animation = Animation()
    public var dots: Dots = Dots()
    public var lineWidth: CGFloat = 3
    
    public var x: Coordinate = Coordinate()
    public var y: Coordinate = Coordinate()
    
    
    public var barHeights: [CGFloat] = [CGFloat]()
    public var barXs: [CGFloat] = [CGFloat]()
    
    // values calculated on init
    private var drawingHeight: CGFloat = 0 {
        didSet {
            let max = (getMaximumValue())
            let min = getMinimumValue()
            y.linear = LinearScale(domain: [min, max], range: [0, drawingHeight])
            y.scale = y.linear.scale()
            y.ticks = y.linear.ticks(Int(y.grid.count))
        }
    }
    private var drawingWidth: CGFloat = 0 {
        didSet {
            let data = dataStore[0]
            x.linear = LinearScale(domain: [0.0, CGFloat(data.count - 1)], range: [0, drawingWidth])
            x.scale = x.linear.scale()
            x.invert = x.linear.invert()
            x.ticks = x.linear.ticks(Int(x.grid.count))
        }
    }
    
    public var delegate: LineChartDelegate?
    
    // data stores
    private var dataStore: [[CGFloat]] = []
    private var dotsDataStore: [[DotCALayer]] = []
    private var lineLayerStore: [CAShapeLayer] = []
    
    private var removeAll: Bool = false
    
    // category10 colors from d3 - https://github.com/mbostock/d3/wiki/Ordinal-Scales
    public var colors: [UIColor] = [
        UIColor(red: 0.121569, green: 0.466667, blue: 0.705882, alpha: 1),
        UIColor(red: 1, green: 0.498039, blue: 0.054902, alpha: 1),
        UIColor(red: 0.172549, green: 0.627451, blue: 0.172549, alpha: 1),
        UIColor(red: 0.839216, green: 0.152941, blue: 0.156863, alpha: 1),
        UIColor(red: 0.580392, green: 0.403922, blue: 0.741176, alpha: 1),
        UIColor(red: 0.54902, green: 0.337255, blue: 0.294118, alpha: 1),
        UIColor(red: 0.890196, green: 0.466667, blue: 0.760784, alpha: 1),
        UIColor(red: 0.498039, green: 0.498039, blue: 0.498039, alpha: 1),
        UIColor(red: 0.737255, green: 0.741176, blue: 0.133333, alpha: 1),
        UIColor(red: 0.0901961, green: 0.745098, blue: 0.811765, alpha: 1)
    ]
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        
        let grey = UIColor(
            red: 0x77/255,
            green: 0x7B/255,
            blue: 0x79/255,
            alpha: 0.0)
        
        self.backgroundColor = grey
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func drawRect(rect: CGRect) {
        
        if removeAll {
            let context = UIGraphicsGetCurrentContext()
            CGContextClearRect(context, rect)
            return
        }
        
        self.drawingHeight = self.bounds.height //- (2 * y.axis.inset)
        self.drawingWidth = self.bounds.width //- (2 * x.axis.inset)
        
        // remove all labels
        for view: AnyObject in self.subviews {
            view.removeFromSuperview()
        }
        
        // remove all lines on device rotation
        for lineLayer in lineLayerStore {
            lineLayer.removeFromSuperlayer()
        }
        lineLayerStore.removeAll()
        
        // remove all dots on device rotation
        for dotsData in dotsDataStore {
            for dot in dotsData {
                dot.removeFromSuperlayer()
            }
        }
        dotsDataStore.removeAll()
        
        // draw grid
        if x.grid.visible && y.grid.visible { drawGrid() }
        
        // draw axes
        if x.axis.visible && y.axis.visible { drawAxes() }
        
        // draw labels
        if x.labels.visible { drawXLabels() }
        if y.labels.visible { drawYLabels() }
        
        // draw lines
        for (lineIndex, _) in dataStore.enumerate() {
            
            drawLine(lineIndex)
            
            // draw dots
            if dots.visible { drawDataDots(lineIndex) }
            
            // draw area under line chart
            if area { drawAreaBeneathLineChart(lineIndex) }
            
        }
        
    }
    
    
    
    /**
     * Get y value for given x value. Or return zero or maximum value.
     */
    private func getYValuesForXValue(x: Int) -> [CGFloat] {
        var result: [CGFloat] = []
        for lineData in dataStore {
            if x < 0 {
                result.append(lineData[0])
            } else if x > lineData.count - 1 {
                result.append(lineData[lineData.count - 1])
            } else {
                result.append(lineData[x])
            }
        }
        return result
    }
    
    
    
    /**
     * Handle touch events.
     */
    private func handleTouchEvents(touches: NSSet!, event: UIEvent) {
        if (self.dataStore.isEmpty) {
            return
        }
        
        let point: AnyObject! = touches.anyObject()
        let xValue = point.locationInView(self).x
        let inverted = self.x.invert(xValue)
        let rounded = Int(round(Double(inverted)))
        let yValues: [CGFloat] = getYValuesForXValue(rounded)
        highlightDataPoints(rounded)
        delegate?.didSelectDataPoint2(CGFloat(rounded), yValues: yValues)
        
    }
    
    
    
    /**
     * Listen on touch end event.
     */
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouchEvents(touches, event: event!)
    }
    
    
    
    /**
     * Listen on touch move event
     */
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouchEvents(touches, event: event!)
    }
    
    /**
     * Highlight data points at index.
     */
    private func highlightDataPoints(index: Int) {
        for (lineIndex, dotsData) in dotsDataStore.enumerate() {
            
            var count = 1
            
            for dot in dotsData {
                
                count += 1
                
                dot.backgroundColor = UIColor.clearColor().CGColor
                dot.borderColor = UIColor.clearColor().CGColor
                
                
                
            }
            // highlight current data point
            var dot: DotCALayer
            if index < 0 {
                dot = dotsData[0]
            } else if index > dotsData.count - 1 {
                dot = dotsData[dotsData.count - 1]
            } else {
                dot = dotsData[index]
            }
            
            dot.dotInnerColor = UIColor(
                red: 0xFC/255,
                green: 0xFF/255,
                blue: 0xD7/255,
                alpha: 1.0) // yellow as UIColor
            
            dot.borderColor = backColor.CGColor
            dot.borderWidth = 8
            
            dot.backgroundColor =
               yellowHeavy
            
           
            
            
            
        }
    }
    
    let green = UIColor(
        red: 0x34/255,
        green: 0x67/255,
        blue: 0x33/255,
        alpha: 0.5).CGColor
    
    let yellow = UIColor(
        red: 0xFC/255,
        green: 0xFF/255,
        blue: 0xD7/255,
        alpha: 0.5).CGColor
    
    let greenHeavy = UIColor(
        red: 0x34/255,
        green: 0x67/255,
        blue: 0x33/255,
        alpha: 0.95).CGColor
    
    let yellowHeavy = UIColor(
        red: 0xFC/255,
        green: 0xFF/255,
        blue: 0xD7/255,
        alpha: 1.0).CGColor
    
    let backColor = UIColor(
    
        red: 0x72/255,
        green: 0x9F/255,
        blue: 0x61/255,
        alpha: 1.0)
    
    /**
     * Draw small dot at every data point.
     */
    private func drawDataDots(lineIndex: Int) {
        var dotLayers: [DotCALayer] = []
        var data = self.dataStore[lineIndex]
        
        for index in 0..<data.count {
            let xValue = (self.x.scale(CGFloat(index)) - dots.outerRadius/2)
            let yValue = self.bounds.height - self.y.scale(data[index]) - y.axis.inset - dots.outerRadius/2
            
            // draw custom layer with another layer in the center
            let dotLayer = DotCALayer()
            dotLayer.innerRadius = dots.innerRadius
            
            let screenSize = UIScreen.mainScreen().bounds
            dotLayer.frame = CGRect(x: xValue, y: yValue, width: dots.outerRadius, height: dots.outerRadius)
            
            let newX = ((screenSize.width/12)/2) * (2*CGFloat(index))
            
            dotLayer.dotInnerColor = UIColor.clearColor() // UIColor(CGColor: yellowHeavy)
            dotLayer.innerRadius = dots.innerRadius
            dotLayer.backgroundColor = UIColor.clearColor().CGColor // UIColor.blackColor().CGColor
            dotLayer.cornerRadius = dots.outerRadius / 2
            dotLayer.frame = CGRect(x: xValue, y: yValue, width: dots.outerRadius, height: dots.outerRadius)
            self.layer.addSublayer(dotLayer)
            dotLayers.append(dotLayer)
            
            // animate opacity
            if animation.enabled {
                let anim = CABasicAnimation(keyPath: "opacity")
                anim.duration = animation.duration
                anim.fromValue = 0
                anim.toValue = 1
                dotLayer.addAnimation(anim, forKey: "opacity")
            }
            
        }
        dotsDataStore.append(dotLayers)
    }

    
    
    
    /**
     * Draw x and y axis.
     */
    private func drawAxes() {
        let height = self.bounds.height
        let width = self.bounds.width
        let path = UIBezierPath()
        // draw x-axis
        x.axis.color.setStroke()
        let y0 = height - self.y.scale(0) - y.axis.inset
        path.moveToPoint(CGPoint(x: x.axis.inset, y: y0))
        path.addLineToPoint(CGPoint(x: width - x.axis.inset, y: y0))
        path.stroke()
        // draw y-axis
        y.axis.color.setStroke()
        path.moveToPoint(CGPoint(x: x.axis.inset, y: height - y.axis.inset))
        path.addLineToPoint(CGPoint(x: x.axis.inset, y: y.axis.inset))
        path.stroke()
    }
    
    
    
    /**
     * Get maximum value in all arrays in data store.
     */
    private func getMaximumValue() -> CGFloat {
        var max: CGFloat = 1
        for data in dataStore {
            let newMax = data.maxElement()!
            if newMax > max {
                max = newMax
            }
        }
        return max
    }
    
    
    
    /**
     * Get maximum value in all arrays in data store.
     */
    private func getMinimumValue() -> CGFloat {
        var min: CGFloat = 0
        for data in dataStore {
            let newMin = data.minElement()!
            if newMin < min {
                min = newMin
            }
        }
        return min
    }
    
    public func generatePath(points points: [CGPoint], lineWidth: CGFloat) -> UIBezierPath {
        
        let path = UIBezierPath()
        var p0: CGPoint
        var p1: CGPoint
        var p2: CGPoint
        var p3: CGPoint
        var tensionBezier1: CGFloat
        var tensionBezier2: CGFloat
        
        path.lineCapStyle = .Round
        path.lineJoinStyle = .Round
        
        var previousPoint1: CGPoint = CGPointZero
        
        path.moveToPoint(points.first!)
        
        for i in 0..<(points.count - 1) {
            p1 = points[i]
            p2 = points[i + 1]
            
            tensionBezier1 = 0.3
            tensionBezier2 = 0.3
            if i > 0 {  // Exception for first line because there is no previous point
                p0 = previousPoint1
                
                if p2.y - p1.y == p2.y - p0.y {
                    tensionBezier1 = 0
                }
                
            } else {
                tensionBezier1 = 0
                p0 = p1
            }
            
            if i < points.count - 2 { // Exception for last line because there is no next point
                p3 = points[i + 2]
                if p3.y - p2.y == p2.y - p1.y {
                    tensionBezier2 = 0
                }
            } else {
                p3 = p2
                tensionBezier2 = 0
            }
            
            let controlPoint1 = CGPointMake(p1.x + (p2.x - p1.x) / 3, p1.y - (p1.y - p2.y) / 3 - (p0.y - p1.y) * tensionBezier1)
            let controlPoint2 = CGPointMake(p1.x + 2 * (p2.x - p1.x) / 3, (p1.y - 2 * (p1.y - p2.y) / 3) + (p2.y - p3.y) * tensionBezier2)
            
            path.addCurveToPoint(p2, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            
            previousPoint1 = p1;
        }
        
        path.lineJoinStyle = .Round
        path.lineCapStyle = .Round
        return path
    }

    
    
    /**
     * Draw line.
     */
    private func drawLine(lineIndex: Int) {
        
        var data = self.dataStore[lineIndex]

        var pts : [CGPoint] = [CGPoint]()
   
        for index in 0..<data.count {
            var xValue = self.x.scale(CGFloat(index)) // + x.axis.inset
            let screenSize = UIScreen.mainScreen().bounds
            let hV = (screenSize.height) * 0.42
            let yV = self.bounds.height - self.y.scale(data[index]) - y.axis.inset
            pts.append(CGPoint(x: xValue, y: yV))
            
        }
        
        let path = generatePath(points: pts, lineWidth: 3.0)


        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path.CGPath
        layer.cornerRadius = 20
        layer.strokeColor = yellowHeavy
        
        layer.fillColor = nil
        layer.lineWidth = lineWidth
        self.layer.addSublayer(layer)
        
        // animate line drawing
        if animation.enabled {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.duration = animation.duration
            anim.fromValue = 0
            anim.toValue = 1
            layer.addAnimation(anim, forKey: "strokeEnd")
        }
        
        // add line layer to store
        lineLayerStore.append(layer)
    }
    
    
    
    /**
     * Fill area between line chart and x-axis.
     */
    private func drawAreaBeneathLineChart(lineIndex: Int) {
        
        let context = UIGraphicsGetCurrentContext()

        let startColor: UIColor = UIColor(
            red: 0x61/255,
            green: 0x7F/255,
            blue: 0x55/255,
            alpha: 1.0)
        let endColor: UIColor = UIColor(
            red: 0x61/255,
            green: 0x7F/255,
            blue: 0x55/255,
            alpha: 0.0)

        
        let colors = [startColor.CGColor, endColor.CGColor]
        
        //3 - set up the color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //4 - set up the color stops
        let colorLocations:[CGFloat] = [0.1, 0.8]
        
        //5 - create the gradient
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
    
        
        UIColor.clearColor().setFill()
        
        
        var data = self.dataStore[lineIndex]
        
        var pts : [CGPoint] = [CGPoint]()
        
        for index in 0..<data.count {
            var xValue = self.x.scale(CGFloat(index)) // + x.axis.inset
            let screenSize = UIScreen.mainScreen().bounds
            let hV = (screenSize.height) * 0.42
            let yV = self.bounds.height - self.y.scale(data[index]) - y.axis.inset
            pts.append(CGPoint(x: xValue, y: yV))
            
        }
        
        let path = generatePath(points: pts, lineWidth: 3.0)
    
              // move down to x axis
        path.addLineToPoint(CGPoint(x: self.x.scale(CGFloat(data.count - 1)) + x.axis.inset, y: self.bounds.height - self.y.scale(0)))
        // move to origin
        path.addLineToPoint(CGPoint(x: x.axis.inset, y: self.bounds.height - self.y.scale(0) ))
        path.fill()
        
        
        
        //2 - make a copy of the path
        let clippingPath = path.copy() as! UIBezierPath
        
     /*   let hV = (self.frame.height) * 0.42
        let yV = self.frame.height - hV
     */
        
        //3 - add lines to the copied path to complete the clip area
        clippingPath.addLineToPoint(CGPoint(
            x: CGFloat(data.count - 1),
            y: self.frame.height))
        clippingPath.addLineToPoint(CGPoint(
            x: CGFloat(0),
            y: self.frame.height))
        clippingPath.closePath()
        
        //4 - add the clipping path to the context
        clippingPath.addClip()
        
        let maxTry = clippingPath.bounds.maxY
        
        let margin:CGFloat = 0

        let highestYPoint = CGFloat(-15.0) // - CGFloat(Int(data.maxElement()!) * (2/3))
        print(highestYPoint)
        let startPoint = CGPoint(x:margin, y: highestYPoint)
        let endPoint = CGPoint(x:margin, y:self.bounds.height)
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, [])
        
        path
    }
    
    
    
    /**
     * Draw x grid.
     */
    private func drawXGrid() {
        x.grid.color.setStroke()
        let path = UIBezierPath()
        var x1: CGFloat
        let y1: CGFloat = self.bounds.height - y.axis.inset
        let y2: CGFloat = y.axis.inset
        let (start, stop, step) = self.x.ticks
        for var i: CGFloat = start; i <= stop; i += step {
            x1 = self.x.scale(i) + x.axis.inset
            path.moveToPoint(CGPoint(x: x1, y: y1))
            path.addLineToPoint(CGPoint(x: x1, y: y2))
        }
        path.stroke()
    }
    
    
    
    /**
     * Draw y grid.
     */
    private func drawYGrid() {
        self.y.grid.color.setStroke()
        let path = UIBezierPath()
        let x1: CGFloat = x.axis.inset
        let x2: CGFloat = self.bounds.width - x.axis.inset
        var y1: CGFloat
        let (start, stop, step) = self.y.ticks
        for var i: CGFloat = start; i <= stop; i += step {
            y1 = self.bounds.height - self.y.scale(i) - y.axis.inset
            path.moveToPoint(CGPoint(x: x1, y: y1))
            path.addLineToPoint(CGPoint(x: x2, y: y1))
        }
        path.stroke()
    }
    
    
    
    /**
     * Draw grid.
     */
    private func drawGrid() {
        drawXGrid()
        drawYGrid()
    }
    
    
    
    /**
     * Draw x labels.
     */
    private func drawXLabels() {
        let xAxisData = self.dataStore[0]
        let y = self.bounds.height - x.axis.inset
        let (_, _, step) = x.linear.ticks(xAxisData.count)
        let width = x.scale(step)
        
        var text: String
        for (index, _) in xAxisData.enumerate() {
            let xValue = self.x.scale(CGFloat(index)) + x.axis.inset - (width / 2)
            let label = UILabel(frame: CGRect(x: xValue, y: y, width: width, height: x.axis.inset))
            label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
            label.textAlignment = .Center
            if (x.labels.values.count != 0) {
                text = x.labels.values[index]
            } else {
                text = String(index)
            }
            label.text = text
            self.addSubview(label)
        }
    }
    
    
    
    /**
     * Draw y labels.
     */
    private func drawYLabels() {
        var yValue: CGFloat
        let (start, stop, step) = self.y.ticks
        for var i: CGFloat = start; i <= stop; i += step {
            yValue = self.bounds.height - self.y.scale(i) - (y.axis.inset * 1.5)
            let label = UILabel(frame: CGRect(x: -15, y: yValue, width: 0, height: y.axis.inset))
            label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
            label.textAlignment = .Center
            label.text = String(Int(round(i)))
            self.addSubview(label)
        }
    }
    
    
    
    /**
     * Add line chart
     */
    public func addLine(data: [CGFloat]) {
        self.dataStore.append(data)
        self.setNeedsDisplay()
    }
    
    
    
    /**
     * Make whole thing white again.
     */
    public func clearAll() {
        self.removeAll = true
        clear()
        self.setNeedsDisplay()
        self.removeAll = false
    }
    
    
    
    /**
     * Remove charts, areas and labels but keep axis and grid.
     */
    public func clear() {
        // clear data
        dataStore.removeAll()
        self.setNeedsDisplay()
    }
}



/**
 * DotCALayer
 */
class DotCALayer: CALayer {
    
    var innerRadius: CGFloat = 8
    var dotInnerColor = UIColor.blackColor()
    
    override init() {
        super.init()
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        let inset = self.bounds.size.width - innerRadius
        let innerDotLayer = CALayer()
        innerDotLayer.frame = CGRectInset(self.bounds, inset/2, inset/2)
        innerDotLayer.backgroundColor = dotInnerColor.CGColor
        innerDotLayer.cornerRadius = innerRadius / 2
        self.addSublayer(innerDotLayer)
    }
    
}



/**
 * LinearScale
 */
public class LinearScale {
    
    var domain: [CGFloat]
    var range: [CGFloat]
    
    public init(domain: [CGFloat] = [0, 1], range: [CGFloat] = [0, 1]) {
        self.domain = domain
        self.range = range
    }
    
    public func scale() -> (x: CGFloat) -> CGFloat {
        return bilinear(domain, range: range, uninterpolate: uninterpolate, interpolate: interpolate)
    }
    
    public func invert() -> (x: CGFloat) -> CGFloat {
        return bilinear(range, range: domain, uninterpolate: uninterpolate, interpolate: interpolate)
    }
    
    public func ticks(m: Int) -> (CGFloat, CGFloat, CGFloat) {
        return scale_linearTicks(domain, m: m)
    }
    
    private func scale_linearTicks(domain: [CGFloat], m: Int) -> (CGFloat, CGFloat, CGFloat) {
        return scale_linearTickRange(domain, m: m)
    }
    
    private func scale_linearTickRange(domain: [CGFloat], m: Int) -> (CGFloat, CGFloat, CGFloat) {
        var extent = scaleExtent(domain)
        let span = extent[1] - extent[0]
        var step = CGFloat(pow(10, floor(log(Double(span) / Double(m)) / M_LN10)))
        let err = CGFloat(m) / span * step
        
        // Filter ticks to get closer to the desired count.
        if (err <= 0.15) {
            step *= 10
        } else if (err <= 0.35) {
            step *= 5
        } else if (err <= 0.75) {
            step *= 2
        }
        
        // Round start and stop values to step interval.
        let start = ceil(extent[0] / step) * step
        let stop = floor(extent[1] / step) * step + step * 0.5 // inclusive
        
        return (start, stop, step)
    }
    
    
    
    private func scaleExtent(domain: [CGFloat]) -> [CGFloat] {
        let start = domain[0]
        let stop = domain[domain.count - 1]
        return start < stop ? [start, stop] : [stop, start]
    }
    
    private func interpolate(a: CGFloat, b: CGFloat) -> (c: CGFloat) -> CGFloat {
        var diff = b - a
        func f(c: CGFloat) -> CGFloat {
            return (a + diff) * c
        }
        return f
    }
    
    private func uninterpolate(a: CGFloat, b: CGFloat) -> (c: CGFloat) -> CGFloat {
        var diff = b - a
        var re = diff != 0 ? 1 / diff : 0
        func f(c: CGFloat) -> CGFloat {
            return (c - a) * re
        }
        return f
    }
    
    private func bilinear(domain: [CGFloat], range: [CGFloat], uninterpolate: (a: CGFloat, b: CGFloat) -> (c: CGFloat) -> CGFloat, interpolate: (a: CGFloat, b: CGFloat) -> (c: CGFloat) -> CGFloat) -> (c: CGFloat) -> CGFloat {
        var u: (c: CGFloat) -> CGFloat = uninterpolate(a: domain[0], b: domain[1])
        var i: (c: CGFloat) -> CGFloat = interpolate(a: range[0], b: range[1])
        func f(d: CGFloat) -> CGFloat {
            return i(c: u(c: d))
        }
        return f
    }
    
}