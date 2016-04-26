//
//  Field.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 11/02/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import Foundation


class Field
{
    let size: Size
    let colorsCount: Int
    let marblesPerSpawn: Int
    let lineLength: Int
    let marbleFactory: MarbleFactory

    var marbles = [Point : Marble]()
    var isFull: Bool { return self.marbles.count >= self.size.width * self.size.height }


    // MARK: - Initialization -
    init(size: Size, colorsCount: Int, marblesPerSpawn: Int, lineLength: Int, marbleFactory: MarbleFactory)
    {
        self.size = size
        self.colorsCount = colorsCount
        self.marblesPerSpawn = marblesPerSpawn
        self.lineLength = lineLength
        self.marbleFactory = marbleFactory
    }


    // MARK: - Control -
    func spawnMarbles() -> [Marble]
    {
        var spawnedMarbles = [Marble]()

        for _ in 0 ..< self.marblesPerSpawn {
            if self.isFull {
                break
            }

            while true {
                let x = Int(arc4random()) % self.size.width
                let y = Int(arc4random()) % self.size.height
                let position = Point(x, y)

                if self.marbles[position] == nil {
                    let color = Int(arc4random()) % self.colorsCount

                    let marble = self.marbleFactory.marbleWithColor(color, fieldPosition: position)

                    self.marbles[position] = marble
                    spawnedMarbles.append(marble)

                    break
                }
            }
        }

        return spawnedMarbles
    }


    func moveMarble(marble: Marble, toPosition to: Point) -> [Point]?
    {
        let path = self.findPathFromPosition(marble.fieldPosition, toPosition: to)

        // If found a path, move the ball in dictionary
        if path != nil {
            self.marbles.removeValueForKey(marble.fieldPosition)
            self.marbles[to] = marble
            marble.fieldPosition = to
        }

        return path
    }


    private func findPathFromPosition(from: Point, toPosition to: Point, visitedMap: [Point : Bool]? = nil) -> [Point]?
    {
        var map = visitedMap

        // Make sure the map is initialized
        if map == nil {
            map = [Point : Bool]()
        }

        // Mask current cell as visited
        map![from] = true

        // Are we at the goal?
        if from == to {
            return [from]
        }

        // Check which directions can we move
        var hasUpExecuted = false
        var hasDownExecuted = false
        var hasLeftExecuted = false
        var hasRightExecuted = false

        var isInUpDirection = to.y > from.y
        var isInDownDirection = to.y < from.y
        var isInLeftDirection = to.x < from.x
        var isInRightDirection = to.x > from.x

        while true {
            // Up
            let isAtTopEdge = from.y >= self.size.height-1
            let isUpVisited = map![Point(from.x, from.y + 1)] == true
            let isUpOccupied = self.marbles[Point(from.x, from.y + 1)] != nil

            let canMoveUp = !isAtTopEdge && !isUpVisited && !isUpOccupied

            if canMoveUp && isInUpDirection && !hasUpExecuted {
                var path = self.findPathFromPosition(Point(from.x, from.y+1), toPosition: to, visitedMap: map)

                // If path has been found, return it
                if path != nil {
                    path!.append(from)
                    return path
                }

                hasUpExecuted = true
            } else if !canMoveUp {
                hasUpExecuted = true
            }

            // Down
            let isAtBottomEdge = from.y <= 0
            let isDownVisited = map![Point(from.x, from.y - 1)] == true
            let isDownOccupied = self.marbles[Point(from.x, from.y - 1)] != nil

            let canMoveDown = !isAtBottomEdge && !isDownVisited && !isDownOccupied

            if canMoveDown && isInDownDirection && !hasDownExecuted {
                var path = self.findPathFromPosition(Point(from.x, from.y-1), toPosition: to, visitedMap: map)

                // If path has been found, return it
                if path != nil {
                    path!.append(from)
                    return path
                }

                hasDownExecuted = true
            } else if !canMoveDown {
                hasDownExecuted = true
            }

            // Left
            let isAtLeftEdge = from.x <= 0
            let isLeftVisited = map![Point(from.x-1, from.y)] == true
            let isLeftOccupied = self.marbles[Point(from.x-1, from.y)] != nil

            let canMoveLeft = !isAtLeftEdge && !isLeftVisited && !isLeftOccupied

            if canMoveLeft && isInLeftDirection && !hasLeftExecuted {
                var path = self.findPathFromPosition(Point(from.x-1, from.y), toPosition: to, visitedMap: map)

                // If path has been found, return it
                if path != nil {
                    path!.append(from)
                    return path
                }

                hasLeftExecuted = true
            } else if !canMoveLeft {
                hasLeftExecuted = true
            }

            // Right
            let isAtRightEdge = from.x >= self.size.width-1
            let isRightVisited = map![Point(from.x+1, from.y)] == true
            let isRightOccupied = self.marbles[Point(from.x+1, from.y)] != nil

            let canMoveRight = !isAtRightEdge && !isRightVisited && !isRightOccupied

            if canMoveRight && isInRightDirection && !hasRightExecuted {
                var path = self.findPathFromPosition(Point(from.x+1, from.y), toPosition: to, visitedMap: map)

                // If path has been found, return it
                if path != nil {
                    path!.append(from)
                    return path
                }

                hasRightExecuted = true
            } else if !canMoveRight {
                hasRightExecuted = true
            }

            if isInUpDirection && isInDownDirection && isInLeftDirection && isInRightDirection {
                break
            } else {
                isInUpDirection = true
                isInDownDirection = true
                isInLeftDirection = true
                isInRightDirection = true
            }
        }

        // Nothing has been found, return nil
        return nil
    }


    func removeLinesAtMarble(marble: Marble) -> [Marble]
    {
        var removedMarbles = Set<Marble>()

        let position = marble.fieldPosition

        // Check horizontal extent
        var startX = position.x
        for x in (startX-1).stride(through: 0, by: -1) {
            let currentMarble = self.marbles[Point(x, position.y)]

            if currentMarble?.color == marble.color {
                startX = x
            } else {
                break
            }
        }

        var endX = position.x
        for x in (startX+1).stride(through: self.size.width-1, by: 1) {
            let currentMarble = self.marbles[Point(x, position.y)]

            if currentMarble?.color == marble.color {
                endX = x
            } else {
                break
            }
        }

        // Check vertial extent
        var startY = position.y
        for y in (startY-1).stride(through: 0, by: -1) {
            let currentMarble = self.marbles[Point(position.x, y)]

            if currentMarble?.color == marble.color {
                startY = y
            } else {
                break
            }
        }

        var endY = position.y
        for y in (startY+1).stride(through: self.size.height-1, by: 1) {
            let currentMarble = self.marbles[Point(position.x, y)]

            if currentMarble?.color == marble.color {
                endY = y
            } else {
                break
            }
        }

        // Check if there is a horizontal line to be removed
        if endX - startX >= self.lineLength-1 {
            for x in startX...endX {
                removedMarbles.insert(self.marbles[Point(x, position.y)]!)
            }
        }

        // Check if there is a vertical line to be removed
        if endY - startY >= self.lineLength-1 {
            for y in startY...endY {
                removedMarbles.insert(self.marbles[Point(position.x, y)]!)
            }
        }

        // Remove all the relevant balls from the dictionary
        for marble in removedMarbles {
            self.marbles.removeValueForKey(marble.fieldPosition)
        }

        return removedMarbles.map() { $0 }
    }
}