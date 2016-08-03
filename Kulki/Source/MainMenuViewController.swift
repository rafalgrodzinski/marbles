//
//  GameViewController.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 09/02/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit


class MainMenuViewController: UIViewController
{
    // Constant
    let logoColorUpdateInterval = 1.0/60.0
    let logoColorUpdateAmount = 1.0/(60.0 * 15.0)
    var resumeButtonHeight: CGFloat = 0.0

    // Variables
    var currentLogoHue = 100.0/360.0
    var logoColorUpdateTimer: NSTimer!
    var gameVc: UIViewController?

    // Outlets
    @IBOutlet private weak var logoLabel: UILabel!
    @IBOutlet private weak var highScoreLabel: UILabel!
    @IBOutlet private weak var topButton: UIButton!
    @IBOutlet private weak var bottomButton: UIButton!


    // MARK: - Initialization -
    override func viewDidLoad()
    {
        self.updateHighScoreLabel()

        self.logoColorUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(self.logoColorUpdateInterval,
                                                                           target: self,
                                                                           selector: #selector(updateLogoLabelColorTimeout),
                                                                           userInfo: nil,
                                                                           repeats: true)

        self.logoLabel.textColor = UIColor.marblesGreen()

        self.setupForNewGame()
    }


    // MARK: - Actions -
    @IBAction func newGameButtonPressed(sender: AnyObject)
    {
        self.gameVc = UIViewController()
        let game = GameFactory.gameWithGraphicsType(.SceneKit, size: Size(9, 9), colorsCount: 5, marblesPerSpawn: 3, lineLength: 5)
        self.gameVc!.view.addSubview(game.view)
        self.gameVc!.modalTransitionStyle = .CrossDissolve
        game.view.frame = gameVc!.view.bounds

        weak var welf = self
        game.menuButtonCallback = {
            welf?.setupForResume()
            welf?.gameVc!.dismissViewControllerAnimated(false, completion: nil)
        }

        game.startGame()

        self.presentViewController(self.gameVc!, animated: true, completion: nil)
    }


    @IBAction func resumeGameButtonPressed(sender: AnyObject)
    {
        self.presentViewController(self.gameVc!, animated: true, completion: nil)
    }


    // MARK: - Internal Control -
    func updateLogoLabelColorTimeout()
    {
         self.logoLabel.textColor = UIColor(hue: CGFloat(self.currentLogoHue), saturation: 0.8, brightness: 0.8, alpha: 1.0)

        self.currentLogoHue += self.logoColorUpdateAmount
        if self.currentLogoHue > 1.0 {
            self.currentLogoHue = 0.0
        }
    }


    func updateHighScoreLabel()
    {
        if ScoreSingleton.sharedInstance.highScore > 0
        {
            self.highScoreLabel.hidden = false
            self.highScoreLabel.text = "High Score: \(ScoreSingleton.sharedInstance.highScore)"
        }
        else
        {
            self.highScoreLabel.hidden = true
        }
    }


    private func setupForNewGame()
    {
        // Top Button
        self.topButton.setTitle("New Game", forState: .Normal)
        self.topButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
        self.topButton.addTarget(self, action: #selector(newGameButtonPressed), forControlEvents: .TouchUpInside)

        // Bottom Button
        self.bottomButton.hidden = true
    }


    private func setupForResume()
    {
        // Top Button
        self.topButton.setTitle("Resume", forState: .Normal)
        self.topButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
        self.topButton.addTarget(self, action: #selector(resumeGameButtonPressed), forControlEvents: .TouchUpInside)

        // Bottom Button
        self.bottomButton.hidden = false
        self.bottomButton.setTitle("New Game", forState: .Normal)
        self.bottomButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
        self.bottomButton.addTarget(self, action: #selector(newGameButtonPressed), forControlEvents: .TouchUpInside)
    }

    // MARK: - Actions -
    /*@IBAction private func twoDimensionalPressed(sender: AnyObject)
    {
        self.game = GameFactory.gameWithGraphicsType(.SpriteKit, size: Size(8, 8), colorsCount: 3, marblesPerSpawn: 3, lineLength: 4)
        let rect = self.view.frame
        self.gameView.addSubview(self.game.view)
        self.gameView = self.game.view
        self.game.view.frame = rect

        self.startGame()
    }


    @IBAction private func threeDimensionalPressed(sender: UIButton)
    {
        self.game = GameFactory.gameWithGraphicsType(.SceneKit, size: Size(8, 8), colorsCount: 5, marblesPerSpawn: 3, lineLength: 5)
        let rect = self.view.frame
        self.gameView.addSubview(self.game.view)
        self.gameView = self.game.view
        self.game.view.frame = rect

        self.startGame()
    }


    @IBAction private func highScoresPressed(sender: UIButton)
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
    }*/
}