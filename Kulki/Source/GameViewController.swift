//
//  GameViewController.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 09/02/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController
{
    var skView: SKView!
    var gameScene: GameScene!


    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.skView = self.view as! SKView
        self.gameScene = GameScene(size: self.skView.frame.size, fieldSize: CGSizeMake(8, 8), colorsCount: 3, ballsPerSpawn: 3, lineLength: 4)

        self.skView.presentScene(self.gameScene)
    }
}