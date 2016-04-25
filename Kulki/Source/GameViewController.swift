//
//  GameViewController.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 09/02/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit


class GameViewController: UIViewController
{
    var game: Game!


    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.game = GameFactory.gameWithGraphicsType(.SpriteKit, size: Size(8, 8), colorsCount: 3, marblesPerSpawn: 3, lineLength: 4)
        self.view = self.game.view
    }


    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)

        self.game.startGame()
    }
}