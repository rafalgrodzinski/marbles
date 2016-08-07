//
//  GameOverPopup.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 06/08/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import SpriteKit


public class GameOverPopup: SKNode
{
    // MARK: - Variables -
    private var topLabel: SKLabelNode!
    private var topLabelShadow: SKLabelNode!

    private var bottomLabel: SKLabelNode!
    private var bottomLabelShadow: SKLabelNode!

    // MARK: - Callbacks -
    public var restartCallback: (() -> Void)?
    public var quitCallback: (() -> Void)?


    // MARK - Initialization -
    public init(size: CGSize)
    {
        super.init()

        // Background
        let path = UIBezierPath(rect: CGRectMake(0.0, 0.0, size.width, size.height)).CGPath
        let background = SKShapeNode(path: path, centered: true)
        background.fillColor = UIColor(white: 0.0, alpha: 0.7)
        background.strokeColor = UIColor.clearColor()
        self.addChild(background)

        // Setup restart button
        let restartButton = Button(defaultTexture: SKTexture(imageNamed: "Restart Button"))
        restartButton.callback = self.restartButtonPressed
        self.addChild(restartButton)

        // Setup menu button
        let menuButton = Button(defaultTexture: SKTexture(imageNamed: "Menu Button"))
        menuButton.position = CGPointMake(0.0, -restartButton.size.height*1.25)
        menuButton.callback = self.menuButtonPressed
        self.addChild(menuButton)

        // Top label
        self.topLabel = SKLabelNode(fontNamed: "BunakenUnderwater")
        self.topLabel.fontSize = 32.0
        self.topLabel.fontColor = UIColor.marblesGreen()
        self.topLabel.horizontalAlignmentMode = .Center
        self.topLabel.verticalAlignmentMode = .Center
        self.topLabel.position = CGPointMake(0.0, restartButton.size.height*0.5 + self.topLabel.fontSize*2.0)

        // Top label shadow
        self.topLabelShadow = self.topLabel.copy() as! SKLabelNode
        self.topLabelShadow.fontColor = UIColor.blackColor()
        self.topLabelShadow.position.x += 1.5
        self.topLabelShadow.position.y -= 1.5

        self.addChild(self.topLabelShadow)
        self.addChild(self.topLabel)

        // Bottom label
        self.bottomLabel = SKLabelNode(fontNamed: "BunakenUnderwater")
        self.bottomLabel.fontSize = 32.0
        self.bottomLabel.fontColor = UIColor.marblesGreen()
        self.bottomLabel.horizontalAlignmentMode = .Center
        self.bottomLabel.verticalAlignmentMode = .Center
        self.bottomLabel.position = CGPointMake(0.0, restartButton.size.height/2.0 + self.bottomLabel.fontSize)

        // Bottom label shadow
        self.bottomLabelShadow = self.bottomLabel.copy() as! SKLabelNode
        self.bottomLabelShadow.fontColor = UIColor.blackColor()
        self.bottomLabelShadow.position.x += 1.5
        self.bottomLabelShadow.position.y -= 1.5

        self.addChild(self.bottomLabelShadow)
        self.addChild(self.bottomLabel)

        // Hide the whole thing for now
        self.hidden = true
    }


    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    // MARK: - Control -
    public func show(score: Int, isHighScore: Bool)
    {
        if isHighScore {
            self.topLabel.text = "New High Score!"
            self.topLabelShadow.text = self.topLabel.text

            self.bottomLabel.text = "\(score)"
            self.bottomLabelShadow.text = self.bottomLabel.text
        } else {
            self.topLabel.text = "Game Over"
            self.topLabelShadow.text = self.topLabel.text

            self.bottomLabel.text = "Score: \(score)"
            self.bottomLabelShadow.text = self.bottomLabel.text
        }

        self.hidden = false
        self.setScale(0.0)
        self.alpha = 0.0

        let scaleAction = SKAction.scaleTo(1.0, duration: 0.5)
        scaleAction.timingMode = .EaseOut
        self.runAction(scaleAction)
        self.runAction(SKAction.fadeInWithDuration(0.5))
    }


    // MARK: - Events -
    func restartButtonPressed()
    {
        self.runAction(SKAction.fadeOutWithDuration(0.5))
        let scaleAction = SKAction.scaleTo(0.0, duration: 0.5)
        scaleAction.timingMode = .EaseIn
        self.runAction(SKAction.sequence([scaleAction,
                                         SKAction.runBlock {self.hidden = true},
                                         SKAction.runBlock(self.restartCallback!)]))
    }


    func menuButtonPressed()
    {
        self.quitCallback!()
    }
}