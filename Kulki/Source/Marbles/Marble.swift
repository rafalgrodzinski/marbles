//
//  Marble.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 24/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

class Marble: Hashable, Equatable
{
    let color: Int
    var fieldPosition: Point

    var hashValue: Int { return "\(self.fieldPosition.x)\(self.fieldPosition.y)\(self.color)".hash }

    init(color: Int, fieldPosition: Point)
    {
        self.color = color
        self.fieldPosition = fieldPosition
    }
}


func ==(left: Marble, right: Marble) -> Bool
{
    return left.fieldPosition == right.fieldPosition && left.color == right.color
}