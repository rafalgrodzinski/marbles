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


    func removeAtPoint(point: CGPoint, lineLength: Int) -> [CGPoint]
    {
        var points = [CGPoint]()

        let color = self.balls["\(Int(point.x))x\(Int(point.y))"]

        var startX = Int(point.x)
        for x in (0..<Int(point.x)).reverse() {
            let currColor = self.balls["\(x)x\(Int(point.y))"]
            if currColor == color {
                startX = x
            } else {
                break
            }
        }

        var endX = Int(point.x)
        for x in Int(point.x)..<self.width {
            let currColor = self.balls["\(x)x\(Int(point.y))"]
            if currColor == color {
                endX = x
            } else {
                break
            }
        }

        var startY = Int(point.y)
        for y in (0..<Int(point.y)).reverse() {
            let currColor = self.balls["\(Int(point.x))x\(y)"]
            if currColor == color {
                startY = y
            } else {
                break
            }
        }

        var endY = Int(point.y)
        for y in Int(point.y)..<self.height {
            let currColor = self.balls["\(Int(point.x))x\(y)"]
            if currColor == color {
                endY = y
            } else {
                break
            }
        }

        if endX - startX >= lineLength-1 {
            for x in startX...endX {
                points.append(CGPointMake(CGFloat(x), point.y))
                self.balls.removeValueForKey("\(x)x\(Int(point.y))")
            }
        }

        if endY - startY >= lineLength-1 {
            for y in startY...endY {
                points.append(CGPointMake(point.x, CGFloat(y)))
                self.balls.removeValueForKey("\(Int(point.x))x\(y)")
            }
        }

        return points
    }
}