//
//  Field.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 11/02/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit


class Field
{
    var isFull: Bool {
        return false
    }

    private(set) var width: Int
    private(set) var height: Int


    init(fieldSize: CGSize)
    {
        self.width = Int(fieldSize.width)
        self.height = Int(fieldSize.height)
    }


    func ballAtPoint(point: CGPoint) -> Int
    {
        return 0
    }


    func canMoveFromPoint(from: CGPoint, toPoint to: CGPoint) -> Bool
    {
        return true
    }


    func movementPathFromPoint(from: CGPoint, toPoint to: CGPoint) -> [CGPoint]
    {
        var movementPath = [CGPoint]()

        return movementPath
    }


    func spawnBalls(count count: Int) -> [(CGPoint, Int)]
    {
        var spawnedBalls = [(CGPoint, Int)]()
        spawnedBalls.append((CGPointMake(0, 0), 0))
        spawnedBalls.append((CGPointMake(1, 1), 1))
        spawnedBalls.append((CGPointMake(2, 2), 2))

        return spawnedBalls
    }


    func lineAtPoint(point: CGPoint) -> [CGPoint]
    {
        var line = [CGPoint]()

        return line
    }
}