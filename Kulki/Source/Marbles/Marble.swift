//
//  Marble.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 24/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit


class Marble: Hashable, Equatable
{
    let color: Int
    var fieldPosition: Point
    var colors = [UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.yellowColor(), UIColor.purpleColor()]

    let pastelColors = [UIColor.init(colorLiteralRed: 0.8, green: 1.0, blue: 0.8, alpha: 1.0),
                        UIColor.init(colorLiteralRed: 1.0, green: 0.8, blue: 0.8, alpha: 1.0),
                        UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 0.8, alpha: 1.0),
                        UIColor.init(colorLiteralRed: 0.8, green: 0.85, blue: 1.0, alpha: 1.0),
                        UIColor.init(colorLiteralRed: 0.83, green: 0.80, blue: 0.99, alpha: 1.0)]

    var hashValue: Int { return "\(self.fieldPosition.x)\(self.fieldPosition.y)\(self.color)".hash }

    init(color: Int, fieldPosition: Point)
    {
        self.color = color
        self.fieldPosition = fieldPosition

        self.colors = self.pastelColors
    }
}


func ==(left: Marble, right: Marble) -> Bool
{
    return left.fieldPosition == right.fieldPosition && left.color == right.color
}