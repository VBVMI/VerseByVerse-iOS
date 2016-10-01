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

public class StyleKit : NSObject {

    //// Cache

    private struct Cache {
        static let hideGradientColor: UIColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.000)
        static let lightGrey: UIColor = UIColor(red: 0.813, green: 0.813, blue: 0.813, alpha: 1.000)
        static let darkGrey: UIColor = UIColor(red: 0.285, green: 0.285, blue: 0.285, alpha: 1.000)
        static let black: UIColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        static let white: UIColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        static let midGrey: UIColor = UIColor(red: 0.501, green: 0.501, blue: 0.501, alpha: 1.000)
        static let orange: UIColor = UIColor(red: 1.000, green: 0.615, blue: 0.000, alpha: 1.000)
        static let darkOrange: UIColor = StyleKit.orange.colorWithShadow(0.3)
        static let orangeFaint: UIColor = StyleKit.orange.colorWithAlpha(0.2)
        static let hideGradient: CGGradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [UIColor.whiteColor().CGColor, StyleKit.hideGradientColor.CGColor], [0.25, 1])!
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

    public class var hideGradientColor: UIColor { return Cache.hideGradientColor }
    public class var lightGrey: UIColor { return Cache.lightGrey }
    public class var darkGrey: UIColor { return Cache.darkGrey }
    public class var black: UIColor { return Cache.black }
    public class var white: UIColor { return Cache.white }
    public class var midGrey: UIColor { return Cache.midGrey }
    public class var orange: UIColor { return Cache.orange }
    public class var darkOrange: UIColor { return Cache.darkOrange }
    public class var orangeFaint: UIColor { return Cache.orangeFaint }

    //// Gradients

    public class var hideGradient: CGGradient { return Cache.hideGradient }

    //// Drawing Methods

    public class func drawHideBackground(frame frame: CGRect = CGRect(x: 0, y: 0, width: 196, height: 58)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        //// Rectangle Drawing
        let rectangleRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let rectanglePath = UIBezierPath(rect: rectangleRect)
        CGContextSaveGState(context)
        rectanglePath.addClip()
        CGContextDrawLinearGradient(context, StyleKit.hideGradient,
            CGPoint(x: rectangleRect.midX, y: rectangleRect.maxY),
            CGPoint(x: rectangleRect.midX, y: rectangleRect.minY),
            CGGradientDrawingOptions())
        CGContextRestoreGState(context)
    }

    public class func drawTopicLabelBackground() {

        //// Variable Declarations
        let color = StyleKit.white

        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 5, height: 5), cornerRadius: 2)
        color.setFill()
        rectanglePath.fill()
    }

    public class func drawCanvas1() {
    }

    public class func drawAirPlayCanvas() {
        //// Color Declarations
        let fillColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 10.5, y: 9.5))
        bezierPath.addLineToPoint(CGPoint(x: 18, y: 17))
        bezierPath.addLineToPoint(CGPoint(x: 3, y: 17))
        bezierPath.addLineToPoint(CGPoint(x: 10.5, y: 9.5))
        bezierPath.closePath()
        bezierPath.usesEvenOddFillRule = true;

        fillColor.setFill()
        bezierPath.fill()


        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.moveToPoint(CGPoint(x: 1, y: 11))
        bezier3Path.addLineToPoint(CGPoint(x: 1, y: 1))
        bezier3Path.addLineToPoint(CGPoint(x: 20, y: 1))
        bezier3Path.addLineToPoint(CGPoint(x: 20, y: 11))
        bezier3Path.addLineToPoint(CGPoint(x: 15, y: 11))
        bezier3Path.addLineToPoint(CGPoint(x: 16, y: 12))
        bezier3Path.addLineToPoint(CGPoint(x: 21, y: 12))
        bezier3Path.addLineToPoint(CGPoint(x: 21, y: -0))
        bezier3Path.addLineToPoint(CGPoint(x: 0, y: -0))
        bezier3Path.addLineToPoint(CGPoint(x: 0, y: 12))
        bezier3Path.addLineToPoint(CGPoint(x: 5, y: 12))
        bezier3Path.addLineToPoint(CGPoint(x: 6, y: 11))
        bezier3Path.addLineToPoint(CGPoint(x: 1, y: 11))
        bezier3Path.closePath()
        fillColor.setFill()
        bezier3Path.fill()
    }

    public class func drawPieProgress(frame frame: CGRect = CGRect(x: 0, y: 0, width: 10, height: 10), progressColor: UIColor = UIColor(red: 1.000, green: 0.615, blue: 0.000, alpha: 1.000), progress: CGFloat = 1) {

        //// Variable Declarations
        let angle: CGFloat = -(progress * 360) + 90

        //// Oval Drawing
        let ovalRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let ovalPath = UIBezierPath()
        ovalPath.addArcWithCenter(CGPoint(x: ovalRect.midX, y: ovalRect.midY), radius: ovalRect.width / 2, startAngle: -90 * CGFloat(M_PI)/180, endAngle: -angle * CGFloat(M_PI)/180, clockwise: true)
        ovalPath.addLineToPoint(CGPoint(x: ovalRect.midX, y: ovalRect.midY))
        ovalPath.closePath()

        progressColor.setFill()
        ovalPath.fill()
    }

    public class func drawForward() {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let fillColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPoint(x: 12, y: 5))
        bezier2Path.addLineToPoint(CGPoint(x: 16, y: 2.52))
        bezier2Path.addLineToPoint(CGPoint(x: 12, y: -0))
        bezier2Path.addLineToPoint(CGPoint(x: 12, y: 5))
        bezier2Path.closePath()
        bezier2Path.usesEvenOddFillRule = true;

        fillColor.setFill()
        bezier2Path.fill()


        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.moveToPoint(CGPoint(x: 16, y: 5))
        bezier3Path.addLineToPoint(CGPoint(x: 20, y: 2.52))
        bezier3Path.addLineToPoint(CGPoint(x: 16, y: -0))
        bezier3Path.addLineToPoint(CGPoint(x: 16, y: 5))
        bezier3Path.closePath()
        bezier3Path.usesEvenOddFillRule = true;

        fillColor.setFill()
        bezier3Path.fill()


        //// Oval Drawing
        let ovalPath = UIBezierPath()
        ovalPath.moveToPoint(CGPoint(x: 20.5, y: 14))
        ovalPath.addLineToPoint(CGPoint(x: 23.5, y: 14))
        ovalPath.addCurveToPoint(CGPoint(x: 12, y: 25.5), controlPoint1: CGPoint(x: 23.5, y: 20.35), controlPoint2: CGPoint(x: 18.35, y: 25.5))
        ovalPath.addCurveToPoint(CGPoint(x: 0.5, y: 14), controlPoint1: CGPoint(x: 5.65, y: 25.5), controlPoint2: CGPoint(x: 0.5, y: 20.35))
        ovalPath.addCurveToPoint(CGPoint(x: 12, y: 2.5), controlPoint1: CGPoint(x: 0.5, y: 7.65), controlPoint2: CGPoint(x: 5.65, y: 2.5))
        UIColor.whiteColor().setStroke()
        ovalPath.lineWidth = 1
        ovalPath.stroke()


        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 3.5, y: 14))
        bezierPath.addLineToPoint(CGPoint(x: 0.5, y: 14))
        UIColor.whiteColor().setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()


        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.moveToPoint(CGPoint(x: 12, y: 22.5))
        bezier4Path.addLineToPoint(CGPoint(x: 12, y: 25.5))
        UIColor.whiteColor().setStroke()
        bezier4Path.lineWidth = 1
        bezier4Path.stroke()


        //// Text Drawing
        let textRect = CGRect(x: 3.5, y: 8, width: 17, height: 12)
        let textTextContent = NSString(string: "30")
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .Center

        let textFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(10), NSForegroundColorAttributeName: UIColor.whiteColor(), NSParagraphStyleAttributeName: textStyle]

        let textTextHeight: CGFloat = textTextContent.boundingRectWithSize(CGSize(width: textRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.height
        CGContextSaveGState(context!)
        CGContextClipToRect(context!, textRect)
        textTextContent.drawInRect(CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
        CGContextRestoreGState(context!)
    }

    public class func drawRollback() {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Color Declarations
        let fillColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

        //// Group
        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPoint(x: 12, y: 5))
        bezier2Path.addLineToPoint(CGPoint(x: 8, y: 2.52))
        bezier2Path.addLineToPoint(CGPoint(x: 12, y: -0))
        bezier2Path.addLineToPoint(CGPoint(x: 12, y: 5))
        bezier2Path.closePath()
        bezier2Path.usesEvenOddFillRule = true;

        fillColor.setFill()
        bezier2Path.fill()


        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.moveToPoint(CGPoint(x: 8, y: 5))
        bezier3Path.addLineToPoint(CGPoint(x: 4, y: 2.52))
        bezier3Path.addLineToPoint(CGPoint(x: 8, y: -0))
        bezier3Path.addLineToPoint(CGPoint(x: 8, y: 5))
        bezier3Path.closePath()
        bezier3Path.usesEvenOddFillRule = true;

        fillColor.setFill()
        bezier3Path.fill()


        //// Oval Drawing
        let ovalPath = UIBezierPath()
        ovalPath.moveToPoint(CGPoint(x: 3.5, y: 14))
        ovalPath.addLineToPoint(CGPoint(x: 0.5, y: 14))
        ovalPath.addCurveToPoint(CGPoint(x: 12, y: 25.5), controlPoint1: CGPoint(x: 0.5, y: 20.35), controlPoint2: CGPoint(x: 5.65, y: 25.5))
        ovalPath.addCurveToPoint(CGPoint(x: 23.5, y: 14), controlPoint1: CGPoint(x: 18.35, y: 25.5), controlPoint2: CGPoint(x: 23.5, y: 20.35))
        ovalPath.addCurveToPoint(CGPoint(x: 12, y: 2.5), controlPoint1: CGPoint(x: 23.5, y: 7.65), controlPoint2: CGPoint(x: 18.35, y: 2.5))
        UIColor.whiteColor().setStroke()
        ovalPath.lineWidth = 1
        ovalPath.stroke()




        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 23.5, y: 14))
        bezierPath.addLineToPoint(CGPoint(x: 20.5, y: 14))
        UIColor.whiteColor().setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()


        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.moveToPoint(CGPoint(x: 12, y: 22.5))
        bezier4Path.addLineToPoint(CGPoint(x: 12, y: 25.5))
        UIColor.whiteColor().setStroke()
        bezier4Path.lineWidth = 1
        bezier4Path.stroke()


        //// Text Drawing
        let textRect = CGRect(x: 3.5, y: 8, width: 17, height: 12)
        let textTextContent = NSString(string: "30")
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .Center

        let textFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(10), NSForegroundColorAttributeName: UIColor.whiteColor(), NSParagraphStyleAttributeName: textStyle]

        let textTextHeight: CGFloat = textTextContent.boundingRectWithSize(CGSize(width: textRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.height
        CGContextSaveGState(context!)
        CGContextClipToRect(context!, textRect)
        textTextContent.drawInRect(CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
        CGContextRestoreGState(context!)
    }

    public class func drawPieProgressDeplete(frame frame: CGRect = CGRect(x: 0, y: 0, width: 10, height: 10), progressColor: UIColor = UIColor(red: 1.000, green: 0.615, blue: 0.000, alpha: 1.000), progress: CGFloat = 0) {

        let context = UIGraphicsGetCurrentContext()!
        //// Variable Declarations
        let depletionAngle: CGFloat = progress * 360 + 90

        //// Gradient Declarations
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [StyleKit.orange.CGColor, StyleKit.orangeFaint.CGColor], [0, 1])!
        
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, frame.minX + frame.width, frame.minY)
        CGContextScaleCTM(context, -1, 1)
        
        //// Oval Drawing
        let ovalRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let ovalPath = UIBezierPath()
        ovalPath.addArcWithCenter(CGPoint(x: ovalRect.midX, y: ovalRect.midY), radius: ovalRect.width / 2, startAngle: -90 * CGFloat(M_PI)/180, endAngle: -(depletionAngle - 360) * CGFloat(M_PI)/180, clockwise: true)
        ovalPath.addLineToPoint(CGPoint(x: ovalRect.midX, y: ovalRect.midY))
        ovalPath.closePath()

        CGContextSaveGState(context)
        ovalPath.addClip()
        let ovalResizeRatio: CGFloat = min(ovalRect.width / 24, ovalRect.height / 24)
        CGContextDrawRadialGradient(context, gradient,
                                    CGPoint(x: ovalRect.midX + -1.64 * ovalResizeRatio, y: ovalRect.midY + 1.95 * ovalResizeRatio), 14.96 * ovalResizeRatio,
                                    CGPoint(x: ovalRect.midX + 0 * ovalResizeRatio, y: ovalRect.midY + 0 * ovalResizeRatio), 3.73 * ovalResizeRatio,
                                    [CGGradientDrawingOptions.DrawsBeforeStartLocation, CGGradientDrawingOptions.DrawsAfterEndLocation])
        CGContextRestoreGState(context)
        
        CGContextRestoreGState(context)
    }

    public class func drawDotView(frame frame: CGRect = CGRect(x: 0, y: 0, width: 3, height: 3)) {

        //// Variable Declarations
        let dotColor = StyleKit.darkGrey

        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalInRect: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height))
        dotColor.setFill()
        ovalPath.fill()
    }

    //// Generated Images

    public class var imageOfTopicLabelBackground: UIImage {
        if Cache.imageOfTopicLabelBackground != nil {
            return Cache.imageOfTopicLabelBackground!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 5, height: 5), false, 0)
            StyleKit.drawTopicLabelBackground()

        Cache.imageOfTopicLabelBackground = UIGraphicsGetImageFromCurrentImageContext()!.resizableImageWithCapInsets(UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2), resizingMode: .Tile).imageWithRenderingMode(.AlwaysOriginal)
        UIGraphicsEndImageContext()

        return Cache.imageOfTopicLabelBackground!
    }

    public class var imageOfAirPlayCanvas: UIImage {
        if Cache.imageOfAirPlayCanvas != nil {
            return Cache.imageOfAirPlayCanvas!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 21, height: 17), false, 0)
            StyleKit.drawAirPlayCanvas()

        Cache.imageOfAirPlayCanvas = UIGraphicsGetImageFromCurrentImageContext()!.imageWithRenderingMode(.AlwaysTemplate)
        UIGraphicsEndImageContext()

        return Cache.imageOfAirPlayCanvas!
    }

    public class var imageOfForward: UIImage {
        if Cache.imageOfForward != nil {
            return Cache.imageOfForward!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 24, height: 26), false, 0)
            StyleKit.drawForward()

        Cache.imageOfForward = UIGraphicsGetImageFromCurrentImageContext()!.imageWithRenderingMode(.AlwaysTemplate)
        UIGraphicsEndImageContext()

        return Cache.imageOfForward!
    }

    public class var imageOfRollback: UIImage {
        if Cache.imageOfRollback != nil {
            return Cache.imageOfRollback!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 24, height: 26), false, 0)
            StyleKit.drawRollback()

        Cache.imageOfRollback = UIGraphicsGetImageFromCurrentImageContext()!.imageWithRenderingMode(.AlwaysTemplate)
        UIGraphicsEndImageContext()

        return Cache.imageOfRollback!
    }

    //// Customization Infrastructure

    @IBOutlet var topicLabelBackgroundTargets: [AnyObject]! {
        get { return Cache.topicLabelBackgroundTargets }
        set {
            Cache.topicLabelBackgroundTargets = newValue
            for target: AnyObject in newValue {
                target.performSelector(NSSelectorFromString("setSelectedImage:"), withObject: StyleKit.imageOfTopicLabelBackground)
            }
        }
    }

    @IBOutlet var airPlayCanvasTargets: [AnyObject]! {
        get { return Cache.airPlayCanvasTargets }
        set {
            Cache.airPlayCanvasTargets = newValue
            for target: AnyObject in newValue {
                target.performSelector(NSSelectorFromString("setImage:"), withObject: StyleKit.imageOfAirPlayCanvas)
            }
        }
    }

    @IBOutlet var forwardTargets: [AnyObject]! {
        get { return Cache.forwardTargets }
        set {
            Cache.forwardTargets = newValue
            for target: AnyObject in newValue {
                target.performSelector(NSSelectorFromString("setImage:"), withObject: StyleKit.imageOfForward)
            }
        }
    }

    @IBOutlet var rollbackTargets: [AnyObject]! {
        get { return Cache.rollbackTargets }
        set {
            Cache.rollbackTargets = newValue
            for target: AnyObject in newValue {
                target.performSelector(NSSelectorFromString("setImage:"), withObject: StyleKit.imageOfRollback)
            }
        }
    }

}



extension UIColor {
    func colorWithHue(newHue: CGFloat) -> UIColor {
        var saturation: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(nil, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: newHue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    func colorWithSaturation(newSaturation: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, brightness: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(&hue, saturation: nil, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }
    func colorWithBrightness(newBrightness: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, saturation: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: nil, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
    func colorWithAlpha(newAlpha: CGFloat) -> UIColor {
        var hue: CGFloat = 1.0, saturation: CGFloat = 1.0, brightness: CGFloat = 1.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: newAlpha)
    }
    func colorWithHighlight(highlight: CGFloat) -> UIColor {
        var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-highlight) + highlight, green: green * (1-highlight) + highlight, blue: blue * (1-highlight) + highlight, alpha: alpha * (1-highlight) + highlight)
    }
    func colorWithShadow(shadow: CGFloat) -> UIColor {
        var red: CGFloat = 1.0, green: CGFloat = 1.0, blue: CGFloat = 1.0, alpha: CGFloat = 1.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * (1-shadow), green: green * (1-shadow), blue: blue * (1-shadow), alpha: alpha * (1-shadow) + shadow)
    }
}
