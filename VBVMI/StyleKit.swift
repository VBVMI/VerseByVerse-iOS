//
//  StyleKit.swift
//  VBVMI
//
//  Created by Thomas Carey on 1/10/16.
//  Copyright (c) 2016 . All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//



import UIKit

open class StyleKit : NSObject {

    //// Cache

    fileprivate struct Cache {
        static let hideGradientColor: UIColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.000)
        static let lightGrey: UIColor = UIColor(red: 0.813, green: 0.813, blue: 0.813, alpha: 1.000)
        static let darkGrey: UIColor = UIColor(red: 0.285, green: 0.285, blue: 0.285, alpha: 1.000)
        static let black: UIColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        static let white: UIColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        static let midGrey: UIColor = UIColor(red: 0.501, green: 0.501, blue: 0.501, alpha: 1.000)
        static let orange: UIColor = UIColor(red: 1.000, green: 0.615, blue: 0.000, alpha: 1.000)
        static let darkOrange: UIColor = StyleKit.orange.colorWithShadow(0.3)
        static let orangeFaint: UIColor = StyleKit.orange.colorWithAlpha(0.2)
        static let hideGradient: CGGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [UIColor.white.cgColor, StyleKit.hideGradientColor.cgColor] as CFArray, locations: [0.25, 1])!
        static var imageOfTopicLabelBackground: UIImage?
        static var topicLabelBackgroundTargets: [AnyObject]?
        static var imageOfAirPlayCanvas: UIImage?
        static var airPlayCanvasTargets: [AnyObject]?
        static var imageOfForward: UIImage?
        static var forwardTargets: [AnyObject]?
        static var imageOfRollback: UIImage?
        static var rollbackTargets: [AnyObject]?
    }

    //// Colors

    open class var hideGradientColor: UIColor { return Cache.hideGradientColor }
    open class var lightGrey: UIColor { return Cache.lightGrey }
    open class var darkGrey: UIColor { return Cache.darkGrey }
    open class var black: UIColor { return Cache.black }
    open class var white: UIColor { return Cache.white }
    open class var midGrey: UIColor { return Cache.midGrey }
    open class var orange: UIColor { return Cache.orange }
    open class var darkOrange: UIColor { return Cache.darkOrange }
    open class var orangeFaint: UIColor { return Cache.orangeFaint }

    //// Gradients

    open class var hideGradient: CGGradient { return Cache.hideGradient }

    //// Drawing Methods

    open class func drawHideBackground(frame: CGRect = CGRect(x: 0, y: 0, width: 196, height: 58)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        //// Rectangle Drawing
        let rectangleRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let rectanglePath = UIBezierPath(rect: rectangleRect)
        context.saveGState()
        rectanglePath.addClip()
        context.drawLinearGradient(StyleKit.hideGradient,
            start: CGPoint(x: rectangleRect.midX, y: rectangleRect.maxY),
            end: CGPoint(x: rectangleRect.midX, y: rectangleRect.minY),
            options: CGGradientDrawingOptions())
        context.restoreGState()
    }

    open class func drawTopicLabelBackground() {

        //// Variable Declarations
        let color = StyleKit.white

        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 5, height: 5), cornerRadius: 2)
        color.setFill()
        rectanglePath.fill()
    }

    open class func drawCanvas1() {
    }

    open class func drawAirPlayCanvas() {
        //// Color Declarations
        let fillColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 10.5, y: 9.5))
        bezierPath.addLine(to: CGPoint(x: 18, y: 17))
        bezierPath.addLine(to: CGPoint(x: 3, y: 17))
        bezierPath.addLine(to: CGPoint(x: 10.5, y: 9.5))
        bezierPath.close()
        bezierPath.usesEvenOddFillRule = true;

        fillColor.setFill()
        bezierPath.fill()


        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 1, y: 11))
        bezier3Path.addLine(to: CGPoint(x: 1, y: 1))
        bezier3Path.addLine(to: CGPoint(x: 20, y: 1))
        bezier3Path.addLine(to: CGPoint(x: 20, y: 11))
        bezier3Path.addLine(to: CGPoint(x: 15, y: 11))
        bezier3Path.addLine(to: CGPoint(x: 16, y: 12))
        bezier3Path.addLine(to: CGPoint(x: 21, y: 12))
        bezier3Path.addLine(to: CGPoint(x: 21, y: -0))
        bezier3Path.addLine(to: CGPoint(x: 0, y: -0))
        bezier3Path.addLine(to: CGPoint(x: 0, y: 12))
        bezier3Path.addLine(to: CGPoint(x: 5, y: 12))
        bezier3Path.addLine(to: CGPoint(x: 6, y: 11))
        bezier3Path.addLine(to: CGPoint(x: 1, y: 11))
        bezier3Path.close()
        fillColor.setFill()
        bezier3Path.fill()
    }

    open class func drawPieProgress(frame: CGRect = CGRect(x: 0, y: 0, width: 10, height: 10), progressColor: UIColor = UIColor(red: 1.000, green: 0.615, blue: 0.000, alpha: 1.000), progress: CGFloat = 1) {

        //// Variable Declarations
        let angle: CGFloat = -(progress * 360) + 90

        //// Oval Drawing
        let ovalRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let ovalPath = UIBezierPath()
        ovalPath.addArc(withCenter: CGPoint(x: ovalRect.midX, y: ovalRect.midY), radius: ovalRect.width / 2, startAngle: -90 * CGFloat(M_PI)/180, endAngle: -angle * CGFloat(M_PI)/180, clockwise: true)
        ovalPath.addLine(to: CGPoint(x: ovalRect.midX, y: ovalRect.midY))
        ovalPath.close()

        progressColor.setFill()
        ovalPath.fill()
    }

    open class func drawForward() {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let fillColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 12, y: 5))
        bezier2Path.addLine(to: CGPoint(x: 16, y: 2.52))
        bezier2Path.addLine(to: CGPoint(x: 12, y: -0))
        bezier2Path.addLine(to: CGPoint(x: 12, y: 5))
        bezier2Path.close()
        bezier2Path.usesEvenOddFillRule = true;

        fillColor.setFill()
        bezier2Path.fill()


        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 16, y: 5))
        bezier3Path.addLine(to: CGPoint(x: 20, y: 2.52))
        bezier3Path.addLine(to: CGPoint(x: 16, y: -0))
        bezier3Path.addLine(to: CGPoint(x: 16, y: 5))
        bezier3Path.close()
        bezier3Path.usesEvenOddFillRule = true;

        fillColor.setFill()
        bezier3Path.fill()


        //// Oval Drawing
        let ovalPath = UIBezierPath()
        ovalPath.move(to: CGPoint(x: 20.5, y: 14))
        ovalPath.addLine(to: CGPoint(x: 23.5, y: 14))
        ovalPath.addCurve(to: CGPoint(x: 12, y: 25.5), controlPoint1: CGPoint(x: 23.5, y: 20.35), controlPoint2: CGPoint(x: 18.35, y: 25.5))
        ovalPath.addCurve(to: CGPoint(x: 0.5, y: 14), controlPoint1: CGPoint(x: 5.65, y: 25.5), controlPoint2: CGPoint(x: 0.5, y: 20.35))
        ovalPath.addCurve(to: CGPoint(x: 12, y: 2.5), controlPoint1: CGPoint(x: 0.5, y: 7.65), controlPoint2: CGPoint(x: 5.65, y: 2.5))
        UIColor.white.setStroke()
        ovalPath.lineWidth = 1
        ovalPath.stroke()


        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 3.5, y: 14))
        bezierPath.addLine(to: CGPoint(x: 0.5, y: 14))
        UIColor.white.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()


        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 12, y: 22.5))
        bezier4Path.addLine(to: CGPoint(x: 12, y: 25.5))
        UIColor.white.setStroke()
        bezier4Path.lineWidth = 1
        bezier4Path.stroke()


        //// Text Drawing
        let textRect = CGRect(x: 3.5, y: 8, width: 17, height: 12)
        let textTextContent = NSString(string: "30")
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center

        let textFontAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 10), NSForegroundColorAttributeName: UIColor.white, NSParagraphStyleAttributeName: textStyle]

        let textTextHeight: CGFloat = textTextContent.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clip(to: textRect)
        textTextContent.draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
        context!.restoreGState()
    }

    open class func drawRollback() {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let fillColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

        //// Group
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 12, y: 5))
        bezier2Path.addLine(to: CGPoint(x: 8, y: 2.52))
        bezier2Path.addLine(to: CGPoint(x: 12, y: -0))
        bezier2Path.addLine(to: CGPoint(x: 12, y: 5))
        bezier2Path.close()
        bezier2Path.usesEvenOddFillRule = true;

        fillColor.setFill()
        bezier2Path.fill()


        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 8, y: 5))
        bezier3Path.addLine(to: CGPoint(x: 4, y: 2.52))
        bezier3Path.addLine(to: CGPoint(x: 8, y: -0))
        bezier3Path.addLine(to: CGPoint(x: 8, y: 5))
        bezier3Path.close()
        bezier3Path.usesEvenOddFillRule = true;

        fillColor.setFill()
        bezier3Path.fill()


        //// Oval Drawing
        let ovalPath = UIBezierPath()
        ovalPath.move(to: CGPoint(x: 3.5, y: 14))
        ovalPath.addLine(to: CGPoint(x: 0.5, y: 14))
        ovalPath.addCurve(to: CGPoint(x: 12, y: 25.5), controlPoint1: CGPoint(x: 0.5, y: 20.35), controlPoint2: CGPoint(x: 5.65, y: 25.5))
        ovalPath.addCurve(to: CGPoint(x: 23.5, y: 14), controlPoint1: CGPoint(x: 18.35, y: 25.5), controlPoint2: CGPoint(x: 23.5, y: 20.35))
        ovalPath.addCurve(to: CGPoint(x: 12, y: 2.5), controlPoint1: CGPoint(x: 23.5, y: 7.65), controlPoint2: CGPoint(x: 18.35, y: 2.5))
        UIColor.white.setStroke()
        ovalPath.lineWidth = 1
        ovalPath.stroke()




        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 23.5, y: 14))
        bezierPath.addLine(to: CGPoint(x: 20.5, y: 14))
        UIColor.white.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()


        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 12, y: 22.5))
        bezier4Path.addLine(to: CGPoint(x: 12, y: 25.5))
        UIColor.white.setStroke()
        bezier4Path.lineWidth = 1
        bezier4Path.stroke()


        //// Text Drawing
        let textRect = CGRect(x: 3.5, y: 8, width: 17, height: 12)
        let textTextContent = NSString(string: "30")
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center

        let textFontAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 10), NSForegroundColorAttributeName: UIColor.white, NSParagraphStyleAttributeName: textStyle]

        let textTextHeight: CGFloat = textTextContent.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clip(to: textRect)
        textTextContent.draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
        context!.restoreGState()
    }

    open class func drawPieProgressDeplete(frame: CGRect = CGRect(x: 0, y: 0, width: 10, height: 10), progressColor: UIColor = UIColor(red: 1.000, green: 0.615, blue: 0.000, alpha: 1.000), progress: CGFloat = 0) {

        let context = UIGraphicsGetCurrentContext()!
        //// Variable Declarations
        let depletionAngle: CGFloat = progress * 360 + 90

        //// Gradient Declarations
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [StyleKit.orange.cgColor, StyleKit.orangeFaint.cgColor] as CFArray, locations: [0, 1])!
        
        context.saveGState()
        context.translateBy(x: frame.minX + frame.width, y: frame.minY)
        context.scaleBy(x: -1, y: 1)
        
        //// Oval Drawing
        let ovalRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let ovalPath = UIBezierPath()
        ovalPath.addArc(withCenter: CGPoint(x: ovalRect.midX, y: ovalRect.midY), radius: ovalRect.width / 2, startAngle: -90 * CGFloat(M_PI)/180, endAngle: -(depletionAngle - 360) * CGFloat(M_PI)/180, clockwise: true)
        ovalPath.addLine(to: CGPoint(x: ovalRect.midX, y: ovalRect.midY))
        ovalPath.close()

        context.saveGState()
        ovalPath.addClip()
        let ovalResizeRatio: CGFloat = min(ovalRect.width / 24, ovalRect.height / 24)
        context.drawRadialGradient(gradient,
                                    startCenter: CGPoint(x: ovalRect.midX + -1.64 * ovalResizeRatio, y: ovalRect.midY + 1.95 * ovalResizeRatio), startRadius: 14.96 * ovalResizeRatio,
                                    endCenter: CGPoint(x: ovalRect.midX + 0 * ovalResizeRatio, y: ovalRect.midY + 0 * ovalResizeRatio), endRadius: 3.73 * ovalResizeRatio,
                                    options: [CGGradientDrawingOptions.drawsBeforeStartLocation, CGGradientDrawingOptions.drawsAfterEndLocation])
        context.restoreGState()
        
        context.restoreGState()
    }

    open class func drawDotView(frame: CGRect = CGRect(x: 0, y: 0, width: 3, height: 3)) {

        //// Variable Declarations
        let dotColor = StyleKit.darkGrey

        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height))
        dotColor.setFill()
        ovalPath.fill()
    }

    //// Generated Images

    open class var imageOfTopicLabelBackground: UIImage {
        if Cache.imageOfTopicLabelBackground != nil {
            return Cache.imageOfTopicLabelBackground!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 5, height: 5), false, 0)
            StyleKit.drawTopicLabelBackground()

        Cache.imageOfTopicLabelBackground = UIGraphicsGetImageFromCurrentImageContext()!.resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2), resizingMode: .tile).withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()

        return Cache.imageOfTopicLabelBackground!
    }

    open class var imageOfAirPlayCanvas: UIImage {
        if Cache.imageOfAirPlayCanvas != nil {
            return Cache.imageOfAirPlayCanvas!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 21, height: 17), false, 0)
            StyleKit.drawAirPlayCanvas()

        Cache.imageOfAirPlayCanvas = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysTemplate)
        UIGraphicsEndImageContext()

        return Cache.imageOfAirPlayCanvas!
    }

    open class var imageOfForward: UIImage {
        if Cache.imageOfForward != nil {
            return Cache.imageOfForward!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 24, height: 26), false, 0)
            StyleKit.drawForward()

        Cache.imageOfForward = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysTemplate)
        UIGraphicsEndImageContext()

        return Cache.imageOfForward!
    }

    open class var imageOfRollback: UIImage {
        if Cache.imageOfRollback != nil {
            return Cache.imageOfRollback!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 24, height: 26), false, 0)
            StyleKit.drawRollback()

        Cache.imageOfRollback = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysTemplate)
        UIGraphicsEndImageContext()

        return Cache.imageOfRollback!
    }

    //// Customization Infrastructure

    @IBOutlet var topicLabelBackgroundTargets: [AnyObject]! {
        get { return Cache.topicLabelBackgroundTargets }
        set {
            Cache.topicLabelBackgroundTargets = newValue
            for target: AnyObject in newValue {
                target.perform(NSSelectorFromString("setSelectedImage:"), with: StyleKit.imageOfTopicLabelBackground)
            }
        }
    }

    @IBOutlet var airPlayCanvasTargets: [AnyObject]! {
        get { return Cache.airPlayCanvasTargets }
        set {
            Cache.airPlayCanvasTargets = newValue
            for target: AnyObject in newValue {
                target.perform(NSSelectorFromString("setImage:"), with: StyleKit.imageOfAirPlayCanvas)
            }
        }
    }

    @IBOutlet var forwardTargets: [AnyObject]! {
        get { return Cache.forwardTargets }
        set {
            Cache.forwardTargets = newValue
            for target: AnyObject in newValue {
                target.perform(NSSelectorFromString("setImage:"), with: StyleKit.imageOfForward)
            }
        }
    }

    @IBOutlet var rollbackTargets: [AnyObject]! {
        get { return Cache.rollbackTargets }
        set {
            Cache.rollbackTargets = newValue
            for target: AnyObject in newValue {
                target.perform(NSSelectorFromString("setImage:"), with: StyleKit.imageOfRollback)
            }
        }
    }

}



extension UIColor {
    func colorWithHue(_ newHue: CGFloat) -> UIColor {
        var saturation: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(nil, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    func colorWithSaturation(_ newSaturation: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }
    func colorWithBrightness(_ newBrightness: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, saturation: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: nil, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
    func colorWithAlpha(_ newAlpha: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, saturation: CGFloat = 1.0, brightness: CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: newAlpha)
    }
    func colorWithHighlight(_ highlight: CGFloat) -> UIColor {
        var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-highlight) + highlight, green: green * (1-highlight) + highlight, blue: blue * (1-highlight) + highlight, alpha: alpha * (1-highlight) + highlight)
    }
    func colorWithShadow(_ shadow: CGFloat) -> UIColor {
        var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-shadow), green: green * (1-shadow), blue: blue * (1-shadow), alpha: alpha * (1-shadow) + shadow)
    }
}
