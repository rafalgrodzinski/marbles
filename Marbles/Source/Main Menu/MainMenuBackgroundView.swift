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
    override func draw(_ rect: CGRect)
    {
        if let ctx = UIGraphicsGetCurrentContext() {
            let startPoint = CGPoint(x: rect.width/2.0, y: 0.0)
            let endPoint = CGPoint(x: rect.width/2.0, y: rect.height)


            let colors = [UIColor(white: 0.95, alpha: 1.0).cgColor, UIColor(white: 0.98, alpha: 1.0).cgColor, UIColor(white: 0.7, alpha: 1.0).cgColor]
            let locations: [CGFloat] = [0.0, 0.5, 1.0]

            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: locations)

            ctx.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions.init(rawValue: 0))
        }
    }
}
