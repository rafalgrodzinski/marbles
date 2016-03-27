//
//  GameScene.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 09/02/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import SpriteKit


enum GameState {
    case Spawning
    case WaitingForInput
    case Moving
}


class GameScene: SKScene
{
    var field: Field!
    var tileSize: CGFloat!
    var colorsCount: Int!
    var state = GameState.Spawning
    var selectedBall: SKPhysicsBody?


    convenience init(size: CGSize, fieldSize: CGSize, colorsCount: Int)
    {
        self.init(size: size)

        let maxTileWidth = size.width/fieldSize.width
        let maxTileHeight = size.height/fieldSize.height

        self.field = Field(fieldSize: fieldSize)
        self.tileSize = round(maxTileWidth < maxTileHeight ? maxTileWidth : maxTileHeight)
        self.colorsCount = colorsCount



        for y in 0 ..< Int(field.height) {
            for x in 0 ..< Int(field.width) {
                let tile = SKSpriteNode(imageNamed: "Tile")
                tile.size = CGSizeMake(self.tileSize, self.tileSize)
                tile.position = self.positionForFieldPosition(CGPointMake(CGFloat(x), CGFloat(y)))

                self.addChild(tile)
            }
        }
    }


    override func didMoveToView(view: SKView)
    {
        self.nextMove()
    }


    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if self.state == .WaitingForInput {
            if let body = self.physicsWorld.bodyAtPoint(touches.first!.locationInNode(self)) {
                if let currentBody = self.selectedBall {
                    currentBody.node?.runAction(SKAction.scaleTo(1.0, duration: 0.2))
                }

                let seq = SKAction.sequence([SKAction.scaleTo(1.2, duration: 0.2)])
                body.node?.runAction(seq)

                self.selectedBall = body
            } else if let currentBody = self.selectedBall {
                let touchLoc = touches.first!.locationInNode(self)
                    if let tileLoc = self.fieldPositionForPosition(touchLoc) {

                    self.moveBallFrom(self.fieldPositionForPosition(currentBody.node!.position)!,
                                      to: tileLoc)
                }
            }
        }
    }


    func nextMove()
    {
        self.state = .Spawning

        //Spawn new balls
        self.spawnBalls(self.colorsCount) { () -> Void in
            //Try removing balls

            //Allow movement
            self.state = .WaitingForInput
        }
    }


    func spawnBalls(count: Int, finished: () -> Void)
    {
        let spawnedBalls = self.field.spawnBalls(count: self.colorsCount)

        for (position, color) in spawnedBalls {
            let ballNode = self.ballNodeForColor(color)
            ballNode.position = self.positionForFieldPosition(position)
            self.addChild(ballNode)
        }

        finished()
    }


    func ballNodeForColor(color: Int) -> SKNode
    {
        let ballNode = SKSpriteNode(imageNamed: "Ball \(color)")
        ballNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.tileSize/2.0, self.tileSize/2.0))
        ballNode.physicsBody?.affectedByGravity = false
        ballNode.size = CGSizeMake(self.tileSize, self.tileSize)

        return ballNode
    }


    func positionForFieldPosition(fieldPosition: CGPoint) -> CGPoint
    {
        let tileXOrigin = (size.width - CGFloat(self.field.width) * tileSize) / 2.0 + tileSize/2.0
        let tileYOrigin = (size.height - CGFloat(self.field.height) * tileSize) / 2.0 + tileSize/2.0

        let x = tileXOrigin + tileSize * fieldPosition.x
        let y = tileYOrigin + tileSize * fieldPosition.y

        return CGPointMake(x, y)
    }


    func fieldPositionForPosition(position: CGPoint) -> CGPoint?
    {
        let tileXOrigin = (size.width - CGFloat(self.field.width) * tileSize) / 2.0
        let tileYOrigin = (size.height - CGFloat(self.field.height) * tileSize) / 2.0
        let x = (position.x - tileXOrigin)/self.tileSize
        let y = (position.y - tileYOrigin)/self.tileSize

        guard x >= 0.0 && x <= CGFloat(self.field.width) && y >= 0.0 && y <= CGFloat(self.field.height) else {
            return nil
        }

        return CGPointMake(floor(x), floor(y))
    }


    func moveBallFrom(from: CGPoint, to: CGPoint)
    {
        if self.field.canMoveFromPoint(from, toPoint: to) {
            self.state = .Moving
            self.selectedBall?.node?.position = self.positionForFieldPosition(to)

            self.nextMove()
        }
    }
}