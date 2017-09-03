//
//  Color.swift
//  Marbles
//
//  Created by Rafal Grodzinski on 03/09/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import AppKit
#endif

class Color {
    #if os(iOS)
    typealias ColorType = UIColor
    #else
    typealias ColorType = NSColor
    #endif

    class func color(red: Float, green: Float, blue: Float, alpha: Float = 1.0) -> ColorType {
        #if os(iOS)
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
        #else
        return NSColor(deviceRed: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
        #endif
    }

    class var marblesGreen: ColorType {
        return Color.color(red: 0.55, green: 0.89, blue: 0.21)
    }


    class var marblesLightGreen: ColorType {
        return Color.color(red: 0.64, green: 0.78, blue: 0.58)
    }


    class var marblesOrange: ColorType {
        return Color.color(red: 0.78, green: 0.38, blue: 0.03)
    }

    class var black: ColorType {
            return Color.color(red: 0.0, green: 0.0, blue: 0.0)
    }

    class var white: ColorType {
        return Color.color(red: 1.0, green: 1.0, blue: 1.0)
    }

    class var red: ColorType {
        return Color.color(red: 1.0, green: 0.0, blue: 0.0)
    }

    class var green: ColorType {
        return Color.color(red: 0.0, green: 1.0, blue: 0.0)
    }

    class var blue: ColorType {
        return Color.color(red: 0.0, green: 0.0, blue: 1.0)
    }

    class var yellow: ColorType {
        return Color.color(red: 0.0, green: 1.0, blue: 1.0)
    }

    class var purple: ColorType {
        return Color.color(red: 1.0, green: 0.0, blue: 1.0)
    }

    class var clear: ColorType {
        return Color.color(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    }
}
