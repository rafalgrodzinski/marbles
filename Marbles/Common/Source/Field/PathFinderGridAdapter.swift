//
//  GridAdapter.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 02/05/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import GameplayKit


class PathFinderGridAdapter: PathFinderProtocol
{
    func pathFromFieldPosition(_ from: Point, toFieldPosition to: Point, field: Field) -> [Point]?
    {
        let graph = GKGridGraph(fromGridStartingAt: int2(0, 0),
                                width: Int32(field.size.width), height: Int32(field.size.height), diagonalsAllowed: false)

        // Remove occupied nodes from graph
        var occupiedNodes = [GKGridGraphNode]()

        for (fieldPosition, _) in field.marbles {
            if fieldPosition != from {
                let gridPosition = int2(Int32(fieldPosition.x), Int32(fieldPosition.y))
                let gridNode =  graph.node(atGridPosition: gridPosition)!
                occupiedNodes.append(gridNode)
            }
        }

        graph.remove(occupiedNodes)

        // Find path
        let startNode = graph.node(atGridPosition: int2(Int32(from.x), Int32(from.y)))!
        let endNode = graph.node(atGridPosition: int2(Int32(to.x), Int32(to.y)))!

        let path = graph.findPath(from: startNode, to: endNode)

        let fieldPath: [Point] = path.map { let gridNode = $0 as! GKGridGraphNode
            return Point(Int(gridNode.gridPosition.x), Int(gridNode.gridPosition.y))}

        // If there is no path, return nil
        guard path.count > 0 else {
            return nil
        }

        return fieldPath
    }
}
