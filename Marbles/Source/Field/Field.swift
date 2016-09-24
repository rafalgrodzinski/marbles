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
    let pathFinder: PathFinderProtocol = PathFinderGridAdapter()

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
    func reset()
    {
        self.marbles = [Point : Marble]()
    }


    func drawNextMarbleColors() -> [Int]
    {
        var drawnColors = [Int]()

        for _ in 0 ..< self.marblesPerSpawn {
            let color = Int(arc4random()) % self.colorsCount
            drawnColors.append(color)
        }

        return drawnColors
    }


    func spawnMarbles(_ marbleColors: [Int]) -> [Marble]
    {
        var spawnedMarbles = [Marble]()

        for i in 0 ..< self.marblesPerSpawn {
            if self.isFull {
                break
            }

            while true {
                let x = Int(arc4random()) % self.size.width
                let y = Int(arc4random()) % self.size.height
                let position = Point(x, y)

                if self.marbles[position] == nil {
                    let color = marbleColors[i]

                    let marble = self.marbleFactory.marbleWithColor(color, fieldPosition: position)

                    self.marbles[position] = marble
                    spawnedMarbles.append(marble!)

                    break
                }
            }
        }

        return spawnedMarbles
    }


    func moveMarble(_ marble: Marble, toPosition to: Point) -> [Point]?
    {
        let path = self.pathFinder.pathFromFieldPosition(marble.fieldPosition, toFieldPosition: to, field: self)

        // If found a path, move the ball in dictionary
        if path != nil {
            self.marbles.removeValue(forKey: marble.fieldPosition)
            self.marbles[to] = marble
            marble.fieldPosition = to
        }

        return path
    }


    func removeLinesAtMarble(_ marble: Marble) -> [Marble]
    {
        var removedMarbles = Set<Marble>()

        let position = marble.fieldPosition

        // Check horizontal extent
        var startX = position.x
        for x in stride(from: (startX-1), through: 0, by: -1) {
            let currentMarble = self.marbles[Point(x, position.y)]

            if currentMarble?.color == marble.color {
                startX = x
            } else {
                break
            }
        }

        var endX = position.x
        for x in stride(from: (startX+1), through: self.size.width-1, by: 1) {
            let currentMarble = self.marbles[Point(x, position.y)]

            if currentMarble?.color == marble.color {
                endX = x
            } else {
                break
            }
        }

        // Check vertial extent
        var startY = position.y
        for y in stride(from: (startY-1), through: 0, by: -1) {
            let currentMarble = self.marbles[Point(position.x, y)]

            if currentMarble?.color == marble.color {
                startY = y
            } else {
                break
            }
        }

        var endY = position.y
        for y in stride(from: (startY+1), through: self.size.height-1, by: 1) {
            let currentMarble = self.marbles[Point(position.x, y)]

            if currentMarble?.color == marble.color {
                endY = y
            } else {
                break
            }
        }


        // Check accross - bottom left to top right
        var startBottomLeft = position.x
        for bottomLeft in stride(from: (startBottomLeft-1), through: 0, by: -1) {
            let diff = position.x - bottomLeft
            let currentMarble = self.marbles[Point(position.x - diff, position.y - diff)]

            if currentMarble?.color == marble.color {
                startBottomLeft = bottomLeft
            } else {
                break
            }
        }

        var endBottomLeft = position.x
        for bottomLeft in stride(from: (endBottomLeft+1), through: self.size.width-1, by: 1) {
            let diff = bottomLeft - position.x
            let currentMarble = self.marbles[Point(position.x + diff, position.y + diff)]

            if currentMarble?.color == marble.color {
                endBottomLeft = bottomLeft
            } else {
                break
            }
        }

        // Check accross - top left to bottom right
        var startTopLeft = position.x
        for topLeft in stride(from: (startTopLeft-1), through: 0, by: -1) {
            let diff = position.x - topLeft
            let currentMarble = self.marbles[Point(position.x - diff, position.y + diff)]

            if currentMarble?.color == marble.color {
                startTopLeft = topLeft
            } else {
                break
            }
        }

        var endTopLeft = position.x
        for topLeft in stride(from: (endTopLeft+1), through: self.size.width-1, by: 1) {
            let diff = topLeft - position.x
            let currentMarble = self.marbles[Point(position.x + diff, position.y - diff)]

            if currentMarble?.color == marble.color {
                endTopLeft = topLeft
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

        // Check if there is a bottom left to top right line to be removed
        if endBottomLeft - startBottomLeft >= self.lineLength-1 {
            for bottomLeft in startBottomLeft...endBottomLeft {
                let diff = bottomLeft - position.x
                removedMarbles.insert(self.marbles[Point(position.x + diff, position.y + diff)]!)
            }
        }

        // Check if there is a top left to bottom right line to be removed
        if endTopLeft - startTopLeft >= self.lineLength-1 {
            for topLeft in startTopLeft...endTopLeft {
                let diff = topLeft - position.x
                removedMarbles.insert(self.marbles[Point(position.x + diff, position.y - diff)]!)
            }
        }

        // Remove all the relevant balls from the dictionary
        for marble in removedMarbles {
            self.marbles.removeValue(forKey: marble.fieldPosition)
        }

        return removedMarbles.map() { $0 }
    }
}
