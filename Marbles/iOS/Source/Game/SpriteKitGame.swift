//
//  SpriteKitGame.swift
//  Marbles AR
//
//  Created by Rafal Grodzinski on 24/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import SpriteKit


class SpriteKitGame: Game
{
    fileprivate var scene: SKScene!
    fileprivate(set) var tileSize: CGSize!
    fileprivate var scoreLabel: SKLabelNode!


    // MARK: - Initialization-
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
            self.tileSize = CGSize(width: tileWidth, height: tileWidth)
        } else {
            self.tileSize = CGSize(width: tileHeight, height: tileHeight)
        }

        // Score label
        self.scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        self.scoreLabel.fontSize = 20.0
        self.scoreLabel.horizontalAlignmentMode = .center
        self.scoreLabel.verticalAlignmentMode = .center
        self.scoreLabel.position = CGPoint(x: self.scene.size.width / 2.0,
                                               y: self.scene.size.height - 50.0)
        self.scene.addChild(self.scoreLabel)
        self.updateScore(0)

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }


    // MARK: - Game overrides -
    override func showBoard(_ finished: @escaping () -> Void)
    {
        for y in 0 ..< field.size.height {
            for x in 0 ..< field.size.width {
                let tile = SKSpriteNode(imageNamed: "Tile")
                tile.size = self.tileSize
                tile.position = self.positionForFieldPosition(Point(x, y))!

                self.scene.addChild(tile)
            }
        }

        self.scene.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.run(finished)]))
    }


    override func showMarbles(_ marbles: [Marble], nextMarbleColors: [Int], finished: @escaping () -> Void)
    {
        for (index, marble) in marbles.enumerated() {
            let skMarble = marble as! SpriteKitMarble
            skMarble.node.setScale(0.0)

            self.scene.addChild(skMarble.node)

            let waitAction = SKAction.wait(forDuration: 0.1 * TimeInterval(index))
            let scaleAction = SKAction.scale(to: 1.0, duration: 0.2)
            let runBlockAction = SKAction.run { if index == marbles.count-1 { finished() } }

            skMarble.node.run(SKAction.sequence([waitAction, scaleAction, runBlockAction]))
        }
    }


    override func hideMarbles(_ marbles: [Marble], finished: @escaping () -> Void)
    {
        for (index, marble) in marbles.enumerated() {
            let scaleAction = SKAction.scale(to: 0.0, duration: 0.2)
            let removeAction = SKAction.removeFromParent()
            let runBlockAction = SKAction.run { if index == marbles.count-1 { finished() } }

            (marble as! SpriteKitMarble).node.run(SKAction.sequence([scaleAction, removeAction, runBlockAction]))
        }
    }


    override func selectMarble(_ marbe: Marble)
    {
        (marbe as! SpriteKitMarble).node.run(SKAction.scale(to: 1.2, duration: 0.2))
    }


    override func deselectMarble(_ marbe: Marble)
    {
        (marbe as! SpriteKitMarble).node.run(SKAction.scale(to: 1.0, duration: 0.2))
    }


    override func moveMarble(_ marble: Marble, overFieldPath fieldPath: [Point], finished: @escaping () -> Void)
    {
        (marble as! SpriteKitMarble).node.run(SKAction.scale(to: 1.0, duration: 0.2))

        for (index, position) in fieldPath.enumerated() where index != 0 {
            let newPosition = self.positionForFieldPosition(position)!

            let waitAction = SKAction.wait(forDuration: 0.2 * Double(index))
            let moveAction = SKAction.move(to: newPosition, duration: 0.2)
            let runBlockAction = SKAction.run { if index == fieldPath.count-1 { finished() } }

            (marble as! SpriteKitMarble).node.run(SKAction.sequence([waitAction, moveAction, runBlockAction]))
        }
    }


    override func updateScore(_ newScore: Int)
    {
        self.scoreLabel.text = "Your score: \(newScore)"
    }


    // MARK: - Control -
    @objc func handleTap(_ sender: UITapGestureRecognizer)
    {
        var tapPosition = sender.location(in: self.view)
        tapPosition.y = self.view.frame.size.height - tapPosition.y

        if let fieldPosition = self.fieldPositionForPosition(tapPosition) {
            self.tappedFieldPosition(fieldPosition)
        }
    }


    // MARK: - Utils -
    func positionForFieldPosition(_ fieldPosition: Point) -> CGPoint?
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

        return CGPoint(x: x, y: y)
    }



    func fieldPositionForPosition(_ position: CGPoint) -> Point?
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
