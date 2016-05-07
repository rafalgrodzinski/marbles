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
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var menuView: UIView!
    var game: Game!


    // MARK: - Actions -
    @IBAction func twoDimensionalPressed(sender: AnyObject)
    {
        self.game = GameFactory.gameWithGraphicsType(.SpriteKit, size: Size(8, 8), colorsCount: 3, marblesPerSpawn: 3, lineLength: 4)
        let rect = self.view.frame
        self.gameView.addSubview(self.game.view)
        self.gameView = self.game.view
        self.game.view.frame = rect

        self.startGame()
    }


    @IBAction func threeDimensionalPressed(sender: UIButton)
    {
        self.game = GameFactory.gameWithGraphicsType(.SceneKit, size: Size(8, 8), colorsCount: 3, marblesPerSpawn: 3, lineLength: 4)
        let rect = self.view.frame
        self.gameView.addSubview(self.game.view)
        self.gameView = self.game.view
        self.game.view.frame = rect

        self.startGame()
    }


    @IBAction func highScoresPressed(sender: UIButton)
    {
    }


    // MARK: - Private Control
    private func startGame()
    {
        self.game.startGame()
        UIView.animateWithDuration(1.0, delay: 0.0, options: [], animations: {
            self.menuView.alpha = 0.0
        }) { (isFinished: Bool) in
            self.menuView.hidden = true
        }
    }
}