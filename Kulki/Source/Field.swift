//
//  Field.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 11/02/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit


// This enables us to store CGPoint as a key in dictionary
extension CGPoint: Hashable
{
    public var hashValue: Int {
        return "\(x)\(y)".hash
    }
}


class Field
{
    var isFull: Bool {
        return self.balls.count >= self.width * self.height
    }

    private(set) var width: Int
    private(set) var height: Int
    private(set) var balls: [CGPoint : Int] //position and color


    init(fieldSize: CGSize, colorsCount: Int)
    {
        self.width = Int(fieldSize.width)
        self.height = Int(fieldSize.height)
        self.balls = [CGPoint : Int]()
    }


    func moveBallFromPosition(from: CGPoint, toPosition to: CGPoint) -> [CGPoint]?
    {
        let path = self.findPathFromPosition(from, toPosition: to)

        // If found a path, move the ball in dictionary
        if path != nil {
            let ballColor = self.balls[from]
            self.balls.removeValueForKey(from)
            self.balls[to] = ballColor
        }

        return path
    }


    private func findPathFromPosition(from: CGPoint, toPosition to: CGPoint, visitedMap: [CGPoint: Bool]? = nil) -> [CGPoint]?
    {
        var map = visitedMap

        // Make sure the map is initialized
        if map == nil {
            map = [CGPoint: Bool]()
        }

        // Mask current cell as visited
        map![from] = true

        // Are we at the goal?
        if from == to {
            return [from]
        }

        // Check which directions can we move

        // Up
        let isAtTopEdge = Int(from.y) >= self.height-1
        let isUpVisited = map![CGPointMake(from.x, from.y + 1)] == true
        let isUpOccupied = self.balls[CGPointMake(from.x, from.y + 1)] != nil

        let canMoveUp = !isAtTopEdge && !isUpVisited && !isUpOccupied

        if canMoveUp {
            var path = self.findPathFromPosition(CGPointMake(from.x, from.y+1), toPosition: to, visitedMap: map)

            // If path has been found, return it
            if path != nil {
                path!.append(from)
                return path
            }
        }

        // Down
        let isAtBottomEdge = from.y <= 0
        let isDownVisited = map![CGPointMake(from.x, from.y - 1)] == true
        let isDownOccupied = self.balls[CGPointMake(from.x, from.y - 1)] != nil

        let canMoveDown = !isAtBottomEdge && !isDownVisited && !isDownOccupied

        if canMoveDown {
            var path = self.findPathFromPosition(CGPointMake(from.x, from.y-1), toPosition: to, visitedMap: map)

            // If path has been found, return it
            if path != nil {
                path!.append(from)
                return path
            }
        }

        // Left
        let isAtLeftEdge = Int(from.x) <= 0
        let isLeftVisited = map![CGPointMake(from.x-1, from.y)] == true
        let isLeftOccupied = self.balls[CGPointMake(from.x-1, from.y)] != nil

        let canMoveLeft = !isAtLeftEdge && !isLeftVisited && !isLeftOccupied

        if canMoveLeft {
            var path = self.findPathFromPosition(CGPointMake(from.x-1, from.y), toPosition: to, visitedMap: map)

            // If path has been found, return it
            if path != nil {
                path!.append(from)
                return path
            }
        }

        // Right
        let isAtRightEdge = Int(from.x) >= self.width-1
        let isRightVisited = map![CGPointMake(from.x+1, from.y)] == true
        let isRightOccupied = self.balls[CGPointMake(from.x+1, from.y)] != nil

        let canMoveRight = !isAtRightEdge && !isRightVisited && !isRightOccupied

        if canMoveRight {
            var path = self.findPathFromPosition(CGPointMake(from.x+1, from.y), toPosition: to, visitedMap: map)

            // If path has been found, return it
            if path != nil {
                path!.append(from)
                return path
            }
        }

        // Nothing has been found, return nil
        return nil
    }


    func spawnBalls(count: Int, colorsCount: Int) -> [(CGPoint, Int)]
    {
        var spawnedBalls = [(CGPoint, Int)]()

        for _ in 0..<count {
            if self.isFull {
                break
            }

            while true {
                let x = random() % self.width
                let y = random() % self.height
                let position = CGPointMake(CGFloat(x), CGFloat(y))

                if self.balls[position] == nil {
                    let color = random() % colorsCount
                    self.balls[position] = color

                    spawnedBalls.append((position, color))
                    break
                }
            }
        }

        return spawnedBalls
    }


    func removeLinesAtPosition(position: CGPoint, lineLength: Int) -> [CGPoint]
    {
        var removedPositions = Set<CGPoint>()

        let color = self.balls[position]

        // Check horizontal extent
        var startX = Int(position.x)
        for x in (startX-1).stride(through: 0, by: -1) {
            let currentPosition = CGPointMake(CGFloat(x), position.y)
            let currentColor = self.balls[currentPosition]
            if currentColor == color {
                startX = x
            } else {
                break
            }
        }

        var endX = Int(position.x)
        for x in (startX+1).stride(through: self.width-1, by: 1) {
            let currentPosition = CGPointMake(CGFloat(x), position.y)
            let currentColor = self.balls[currentPosition]
            if currentColor == color {
                endX = x
            } else {
                break
            }
        }

        // Check vertial extent
        var startY = Int(position.y)
        for y in (startY-1).stride(through: 0, by: -1) {
            let currentPosition = CGPointMake(position.x, CGFloat(y))
            let currentColor = self.balls[currentPosition]
            if currentColor == color {
                startY = y
            } else {
                break
            }
        }

        var endY = Int(position.y)
        for y in (startY+1).stride(through: self.height-1, by: 1) {
            let currentPosition = CGPointMake(position.x, CGFloat(y))
            let currentColor = self.balls[currentPosition]
            if currentColor == color {
                endY = y
            } else {
                break
            }
        }

        // Check if there is a horizontal line to be removed
        if endX - startX >= lineLength-1 {
            for x in startX...endX {
                removedPositions.insert(CGPointMake(CGFloat(x), position.y))
            }
        }

        // Check if there is a vertical line to be removed
        if endY - startY >= lineLength-1 {
            for y in startY...endY {
                removedPositions.insert(CGPointMake(position.x, CGFloat(y)))
            }
        }

        // Remove all the relevant balls from the dictionary
        for position in removedPositions {
            self.balls.removeValueForKey(position)
        }

        return removedPositions.map() { $0 }
    }
}