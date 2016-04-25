//
//  SpriteKitGame.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 24/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import SpriteKit


class SpriteKitGame: Game {
    private var scene: SKScene!

    private(set) var tileSize: CGSize!


    // MARK: Initialization
    override func setupView()
    {
        self.view = SKView()
    }


    override func setupCustom()
    {
        self.scene = SKScene(size: self.view.frame.size)
        (self.view as! SKView).presentScene(self.scene)

        let tileWidth = self.scene.size.width / CGFloat(self.field.size.width)
        let tileHeight = self.scene.size.height / CGFloat(self.field.size.height)

        if tileWidth < tileHeight {
            self.tileSize = CGSizeMake(tileWidth, tileWidth)
        } else {
            self.tileSize = CGSizeMake(tileHeight, tileHeight)
        }
    }


    override func showBoard(finished: () -> Void)
    {
        for y in 0 ..< field.size.height {
            for x in 0 ..< field.size.width {
                let tile = SKSpriteNode(imageNamed: "Tile")
                tile.size = self.tileSize
                tile.position = self.positionForFieldPosition(Point(x, y))

                self.scene.addChild(tile)
            }
        }

        self.scene.runAction(SKAction.sequence([SKAction.waitForDuration(1.0), SKAction.runBlock(finished)]))
    }


    override func showMarbles(marbles: [Marble], finished: () -> Void)
    {
        for (index, marble) in marbles.enumerate() {
            let skMarble = marble as! SpriteKitMarble
            skMarble.node.setScale(0.0)

            self.scene.addChild(skMarble.node)

            let waitAction = SKAction.waitForDuration(0.1 * NSTimeInterval(index))
            let scaleAction = SKAction.scaleTo(1.0, duration: 0.2)
            let runBlockAction = SKAction.runBlock { if index == marbles.count-1 { finished() } }

            skMarble.node.runAction(SKAction.sequence([waitAction, scaleAction, runBlockAction]))
        }
    }


    func positionForFieldPosition(fieldPosition: Point) -> CGPoint
    {
        let tileXOrigin = (self.scene.size.width - CGFloat(self.field.size.width) * self.tileSize.width) / 2.0 +
            self.tileSize.width/2.0
        let tileYOrigin = (self.scene.size.height - CGFloat(self.field.size.height) * self.tileSize.height) / 2.0 +
            self.tileSize.height/2.0

        let x = tileXOrigin + self.tileSize.width * CGFloat(fieldPosition.x)
        let y = tileYOrigin + self.tileSize.height * CGFloat(fieldPosition.y)

        return CGPointMake(x, y)
    }
}