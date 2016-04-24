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
    private var skView: SKView!


    // MARK: Initialization
    override func setupView()
    {
        self.view = SKView()
        self.skView = self.view as! SKView
    }


    override func setupCustom()
    {
        self.scene = SKScene()
    }


    override func startGame()
    {
        self.skView.presentScene(self.scene)
    }
}