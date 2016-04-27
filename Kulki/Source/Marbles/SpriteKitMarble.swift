//
//  SpriteKitMarble.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 24/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import SpriteKit


class SpriteKitMarble: Marble
{
    let node: SKSpriteNode


    init(color: Int, fieldPosition: Point, position: CGPoint, size: CGSize)
    {
        self.node = SKSpriteNode(imageNamed: "Ball \(color)")
        super.init(color: color, fieldPosition: fieldPosition)

        // Setup appearence
        self.node.position = position
        self.node.size = size
        self.node.physicsBody = SKPhysicsBody(rectangleOfSize: size)
        self.node.physicsBody?.affectedByGravity = false
    }
}