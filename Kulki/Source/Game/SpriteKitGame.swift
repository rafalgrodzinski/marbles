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

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }


    // MARK: - Game overrides -
    override func showBoard(finished: () -> Void)
    {
        for y in 0 ..< field.size.height {
            for x in 0 ..< field.size.width {
                let tile = SKSpriteNode(imageNamed: "Tile")
                tile.size = self.tileSize
                tile.position = self.positionForFieldPosition(Point(x, y))!

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


    override func selectMarble(marbe: Marble)
    {
        (marbe as! SpriteKitMarble).node.runAction(SKAction.scaleTo(1.2, duration: 0.2))
    }


    override func deselectMarble(marbe: Marble)
    {
        (marbe as! SpriteKitMarble).node.runAction(SKAction.scaleTo(1.0, duration: 0.2))
    }


    override func moveMarble(marble: Marble, overFieldPath fieldPath: [Point], finished: () -> Void)
    {
        (marble as! SpriteKitMarble).node.runAction(SKAction.scaleTo(1.0, duration: 0.2))

        for (index, position) in fieldPath.reverse().enumerate() {
            let newPosition = self.positionForFieldPosition(position)!

            let waitAction = SKAction.waitForDuration(0.2 * Double(index))
            let moveAction = SKAction.moveTo(newPosition, duration: 0.2)
            let runBlockAction = SKAction.runBlock { if index == fieldPath.count-1 { finished() } }

            (marble as! SpriteKitMarble).node.runAction(SKAction.sequence([waitAction, moveAction, runBlockAction]))
        }
    }


    // MARK: - Control -
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        var tapPosition = sender.locationInView(self.view)
        tapPosition.y = self.view.frame.size.height - tapPosition.y

        if let fieldPosition = self.fieldPositionForPosition(tapPosition) {
            self.tappedFieldPosition(fieldPosition)
        }
    }


    // MARK: - Utils -
    func positionForFieldPosition(fieldPosition: Point) -> CGPoint?
    {
        guard fieldPosition.x >= 0 && fieldPosition.x < self.field.size.width &&
            fieldPosition.y >= 0 && fieldPosition.y < self.field.size.height else {
                return nil
        }

        let tileXOrigin = (self.scene.size.width - CGFloat(self.field.size.width) * self.tileSize.width) / 2.0 +
            self.tileSize.width/2.0
        let tileYOrigin = (self.scene.size.height - CGFloat(self.field.size.height) * self.tileSize.height) / 2.0 +
            self.tileSize.height/2.0

        let x = tileXOrigin + self.tileSize.width * CGFloat(fieldPosition.x)
        let y = tileYOrigin + self.tileSize.height * CGFloat(fieldPosition.y)

        return CGPointMake(x, y)
    }



    func fieldPositionForPosition(position: CGPoint) -> Point?
    {
        let tileXOrigin = (self.scene.size.width - CGFloat(self.field.size.width) * self.tileSize.width) / 2.0
        let tileYOrigin = (self.scene.size.height - CGFloat(self.field.size.height) * self.tileSize.height) / 2.0

        let x = Int((position.x - tileXOrigin)/self.tileSize.width)
        let y = Int((position.y - tileYOrigin)/self.tileSize.height)

        guard x >= 0 && x < self.field.size.width && y >= 0 && y < self.field.size.height else {
            return nil
        }

        return Point(x, y)
    }
}