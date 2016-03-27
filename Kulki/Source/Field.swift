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
        return self.balls.count >= self.width * self.height
    }

    private(set) var width: Int
    private(set) var height: Int
    private(set) var balls: [String : Int] //position and color
    private(set) var colorsCount: Int


    init(fieldSize: CGSize, colorsCount: Int)
    {
        self.width = Int(fieldSize.width)
        self.height = Int(fieldSize.height)
        self.balls = [String : Int]()
        self.colorsCount = colorsCount
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
        let fromKey = "\(Int(from.x))x\(Int(from.y))"
        let toKey = "\(Int(to.x))x\(Int(to.y))"
        let color = self.balls[fromKey]

        self.balls.removeValueForKey(fromKey)
        self.balls[toKey] = color

        var movementPath = [CGPoint]()

        return movementPath
    }


    func spawnBalls(count: Int) -> [(CGPoint, Int)]
    {
        var spawnedBalls = [(CGPoint, Int)]()

        for _ in 0..<count {
            if !self.isFull {
                while true {
                    let x = random() % self.width
                    let y = random() % self.height
                    let key = "\(x)x\(y)"
                    if self.balls[key] == nil {
                        let color = random() % self.colorsCount
                        self.balls[key] = color
                        spawnedBalls.append((CGPointMake(CGFloat(x), CGFloat(y)), color))
                        break
                    }
                }
            } else {
                break
            }
        }

        return spawnedBalls
    }


    func lineAtPoint(point: CGPoint) -> [CGPoint]
    {
        var line = [CGPoint]()

        return line
    }
}