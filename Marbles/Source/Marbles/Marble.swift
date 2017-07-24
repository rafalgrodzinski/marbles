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
    var colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.purple]

    let pastelColors = [UIColor(red: 0.8, green: 1.0, blue: 0.8, alpha: 1.0),
                        UIColor(red: 1.0, green: 0.8, blue: 0.8, alpha: 1.0),
                        UIColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0),
                        UIColor(red: 0.8, green: 0.85, blue: 1.0, alpha: 1.0),
                        UIColor(red: 0.83, green: 0.80, blue: 0.99, alpha: 1.0)]

    let myColors = [UIColor(red: 1.00, green: 0.25, blue: 0.25, alpha: 1.00),
                    UIColor(red: 0.25, green: 1.00, blue: 0.25, alpha: 1.00),
                    UIColor(red: 0.25, green: 0.25, blue: 1.00, alpha: 1.00),
                    UIColor(red: 1.00, green: 1.00, blue: 0.25, alpha: 1.00),
                    UIColor(red: 0.25, green: 1.00, blue: 1.00, alpha: 1.00)]

    var hashValue: Int { return "\(self.fieldPosition.x)\(self.fieldPosition.y)\(self.color)".hash }

    init(color: Int, fieldPosition: Point)
    {
        self.color = color
        self.fieldPosition = fieldPosition

        self.colors = self.myColors
    }
}


func ==(left: Marble, right: Marble) -> Bool
{
    return left.fieldPosition == right.fieldPosition && left.color == right.color
}
