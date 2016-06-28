//
//  MainMenuBackgroundView.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 28/06/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit


class MainMenuBackgroundView: UIView
{
    override func drawRect(rect: CGRect)
    {
        if let ctx = UIGraphicsGetCurrentContext() {
            let startPoint = CGPointMake(rect.width/2.0, 0.0)
            let endPoint = CGPointMake(rect.width/2.0, rect.height)


            let colors = [UIColor(white: 0.95, alpha: 1.0).CGColor, UIColor(white: 0.98, alpha: 1.0).CGColor, UIColor(white: 0.7, alpha: 1.0).CGColor]
            let locations: [CGFloat] = [0.0, 0.5, 1.0]

            let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), colors, locations)

            CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, CGGradientDrawingOptions.init(rawValue: 0))
        }
    }
}