//
//  GameOverPopup.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 06/08/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import SpriteKit


open class GameOverPopup: SKNode
{
    // MARK: - Variables -
    fileprivate var topLabel: SKLabelNode!
    fileprivate var topLabelShadow: SKLabelNode!

    fileprivate var bottomLabel: SKLabelNode!
    fileprivate var bottomLabelShadow: SKLabelNode!

    // MARK: - Callbacks -
    open var restartCallback: (() -> Void)?
    open var quitCallback: (() -> Void)?


    // MARK - Initialization -
    public init(size: CGSize)
    {
        super.init()

        // Background
        let path = UIBezierPath(rect: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)).cgPath
        let background = SKShapeNode(path: path, centered: true)
        background.fillColor = UIColor(white: 0.0, alpha: 0.7)
        background.strokeColor = UIColor.clear
        self.addChild(background)

        // Setup restart button
        let restartButton = Button(defaultTexture: SKTexture(imageNamed: "Restart Button"))
        restartButton.callback = { [weak self] in self?.restartButtonPressed() }
        self.addChild(restartButton)

        // Setup menu button
        let menuButton = Button(defaultTexture: SKTexture(imageNamed: "Menu Button"))
        menuButton.position = CGPoint(x: 0.0, y: -restartButton.size.height*1.25)
        menuButton.callback = { [weak self] in self?.menuButtonPressed() }
        self.addChild(menuButton)

        // Top label
        self.topLabel = SKLabelNode(fontNamed: "BunakenUnderwater")
        self.topLabel.fontSize = 32.0
        self.topLabel.fontColor = UIColor.marblesGreen()
        self.topLabel.horizontalAlignmentMode = .center
        self.topLabel.verticalAlignmentMode = .center
        self.topLabel.position = CGPoint(x: 0.0, y: restartButton.size.height*0.5 + self.topLabel.fontSize*2.0)

        // Top label shadow
        self.topLabelShadow = self.topLabel.copy() as! SKLabelNode
        self.topLabelShadow.fontColor = UIColor.black
        self.topLabelShadow.position.x += 1.5
        self.topLabelShadow.position.y -= 1.5

        self.addChild(self.topLabelShadow)
        self.addChild(self.topLabel)

        // Bottom label
        self.bottomLabel = SKLabelNode(fontNamed: "BunakenUnderwater")
        self.bottomLabel.fontSize = 32.0
        self.bottomLabel.fontColor = UIColor.marblesGreen()
        self.bottomLabel.horizontalAlignmentMode = .center
        self.bottomLabel.verticalAlignmentMode = .center
        self.bottomLabel.position = CGPoint(x: 0.0, y: restartButton.size.height/2.0 + self.bottomLabel.fontSize)

        // Bottom label shadow
        self.bottomLabelShadow = self.bottomLabel.copy() as! SKLabelNode
        self.bottomLabelShadow.fontColor = UIColor.black
        self.bottomLabelShadow.position.x += 1.5
        self.bottomLabelShadow.position.y -= 1.5

        self.addChild(self.bottomLabelShadow)
        self.addChild(self.bottomLabel)

        // Hide the whole thing for now
        self.isHidden = true
    }


    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    // MARK: - Control -
    open func show(_ score: Int, isHighScore: Bool)
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

        self.isHidden = false
        self.setScale(0.0)
        self.alpha = 0.0

        let scaleAction = SKAction.scale(to: 1.0, duration: 0.5)
        scaleAction.timingMode = .easeOut
        self.run(scaleAction)
        self.run(SKAction.fadeIn(withDuration: 0.5))
    }


    // MARK: - Events -
    func restartButtonPressed()
    {
        let restartCallback = { DispatchQueue.main.async { self.restartCallback!() } }
        self.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.2),
                                         SKAction.run {self.isHidden = true},
                                         SKAction.run(restartCallback)]))
    }


    func menuButtonPressed()
    {
        DispatchQueue.main.async { self.quitCallback!() }
    }
}
