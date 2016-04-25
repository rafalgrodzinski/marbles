//
//  Marble.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 24/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

class Marble {
    let color: Int
    var fieldPosition: Point


    init(color: Int, fieldPosition: Point)
    {
        self.color = color
        self.fieldPosition = fieldPosition
    }
}