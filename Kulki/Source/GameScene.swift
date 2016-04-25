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
    var ballsPerSpawn: Int!
    var lineLength: Int!
    var state = GameState.Spawning
    var selectedBall: SKPhysicsBody?


    convenience init(size: CGSize, fieldSize: CGSize, colorsCount: Int, ballsPerSpawn: Int, lineLength: Int)
    {
        self.init(size: size)

        let maxTileWidth = size.width/fieldSize.width
        let maxTileHeight = size.height/fieldSize.height

        //self.field = Field(fieldSize: fieldSize, colorsCount: colorsCount)
        self.tileSize = round(maxTileWidth < maxTileHeight ? maxTileWidth : maxTileHeight)
        self.colorsCount = colorsCount
        self.ballsPerSpawn = ballsPerSpawn
        self.lineLength = lineLength


        for y in 0 ..< Int(field.height) {
            for x in 0 ..< Int(field.width) {
                let tile = SKSpriteNode(imageNamed: "Tile")
                tile.size = CGSizeMake(self.tileSize, self.tileSize)
                tile.position = self.positionForFieldPosition(CGPointMake(CGFloat(x), CGFloat(y)))

                self.addChild(tile)
            }
        }
    }


    /*override func didMoveToView(view: SKView)
    {
        self.nextMove()
    }*/


    /*override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
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

                        self.moveBallFrom(self.fieldPositionForPosition(currentBody.node!.position)!, to: tileLoc) { () -> Void in
                            self.removeBallAtPoint(tileLoc) { () -> Void in
                                self.nextMove()
                            }
                        }
                }
            }
        }
    }*/


    /*func nextMove()
    {
        self.state = .Spawning

        //Spawn new balls
        self.spawnBalls() { () -> Void in
            //Try removing balls

            print("Balls count: \(self.field.balls.count)")
            //Allow movement
            self.state = .WaitingForInput
        }
    }*/


    /*func spawnBalls(finished: () -> Void)
    {
        let spawnedBalls = self.field.spawnBalls(self.ballsPerSpawn, colorsCount: self.colorsCount)

        for (position, color) in spawnedBalls {
            print("New ball \(color) @ \(position.x)x\(position.y)")
            let ballNode = self.ballNodeForColor(color)
            ballNode.position = self.positionForFieldPosition(position)
            ballNode.setScale(0.0)
            self.addChild(ballNode)

            ballNode.runAction(SKAction.sequence([SKAction.scaleTo(1.0, duration: 0.2), SKAction.runBlock({ 
                self.removeBallAtPoint(position, finished: { 
                })
            })]))
        }

        self.runAction(SKAction.sequence([SKAction.waitForDuration(0.2), SKAction.runBlock(finished)]))
    }*/


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


    func moveBallFrom(from: CGPoint, to: CGPoint, finished: () -> Void)
    {
        if let path = self.field.moveBallFromPosition(from, toPosition: to) {
            self.state = .Moving

            self.selectedBall?.node?.runAction(SKAction.scaleTo(1.0, duration: 0.2))

            for (index, position) in path.reverse().enumerate() {
                let newPosition = self.positionForFieldPosition(position)
                self.selectedBall?.node?.runAction(SKAction.sequence([SKAction.waitForDuration(0.2 * Double(index)),
                    SKAction.moveTo(newPosition, duration: 0.2),
                    SKAction.runBlock({if index == path.count-1 { finished() }})]))
            }
            //self.selectedBall?.node?.position = self.positionForFieldPosition(to)

            //finished()
        }
    }


    func removeBallAtPoint(point: CGPoint, finished: () -> Void)
    {
        let positions = self.field.removeLinesAtPosition(point, lineLength: self.lineLength)

        for position in positions {
            if let body = self.physicsWorld.bodyAtPoint(self.positionForFieldPosition(position)) {
                body.node?.runAction(SKAction.sequence([SKAction.scaleTo(0.0, duration: 0.2), SKAction.removeFromParent()]))
            }
        }

        if positions.count > 0 {
            self.runAction(SKAction.sequence([SKAction.waitForDuration(0.2), SKAction.runBlock(finished)]))
        } else {
            finished()
        }
    }
}