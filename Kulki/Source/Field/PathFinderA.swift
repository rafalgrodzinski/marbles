//
//  PathFinderA.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 03/05/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

class PathFinderA: PathFinderProtocol
{
    func pathFromFieldPosition(from: Point, toFieldPosition to: Point, field: Field) -> [Point]?
    {
        let path = self.findPathFromFieldPosition(from, toFieldPosition: to, fieldSize: field.size, fieldPositions: field.marbles)

        if path == nil {
            return nil
        }

        return path?.reverse()
    }


    private func findPathFromFieldPosition(from: Point, toFieldPosition to: Point, fieldSize: Size, fieldPositions: [Point : Marble], visitedMap: [Point : Bool]? = nil) -> [Point]?
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
            let isAtTopEdge = from.y >= fieldSize.height-1
            let isUpVisited = map![Point(from.x, from.y + 1)] == true
            let isUpOccupied = fieldPositions[Point(from.x, from.y + 1)] != nil

            let canMoveUp = !isAtTopEdge && !isUpVisited && !isUpOccupied

            if canMoveUp && isInUpDirection && !hasUpExecuted {
                var path = self.findPathFromFieldPosition(Point(from.x, from.y+1), toFieldPosition: to, fieldSize: fieldSize, fieldPositions: fieldPositions, visitedMap: map)

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
            let isDownOccupied = fieldPositions[Point(from.x, from.y - 1)] != nil

            let canMoveDown = !isAtBottomEdge && !isDownVisited && !isDownOccupied

            if canMoveDown && isInDownDirection && !hasDownExecuted {
                var path = self.findPathFromFieldPosition(Point(from.x, from.y-1), toFieldPosition: to, fieldSize: fieldSize, fieldPositions: fieldPositions, visitedMap: map)

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
            let isLeftOccupied = fieldPositions[Point(from.x-1, from.y)] != nil

            let canMoveLeft = !isAtLeftEdge && !isLeftVisited && !isLeftOccupied

            if canMoveLeft && isInLeftDirection && !hasLeftExecuted {
                var path = self.findPathFromFieldPosition(Point(from.x-1, from.y), toFieldPosition: to, fieldSize: fieldSize, fieldPositions: fieldPositions, visitedMap: map)

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
            let isAtRightEdge = from.x >= fieldSize.width-1
            let isRightVisited = map![Point(from.x+1, from.y)] == true
            let isRightOccupied = fieldPositions[Point(from.x+1, from.y)] != nil

            let canMoveRight = !isAtRightEdge && !isRightVisited && !isRightOccupied

            if canMoveRight && isInRightDirection && !hasRightExecuted {
                var path = self.findPathFromFieldPosition(Point(from.x+1, from.y), toFieldPosition: to, fieldSize: fieldSize, fieldPositions: fieldPositions, visitedMap: map)

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
}