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
    var logoColorUpdateTimer: Timer!
    var game: SceneKitGame?
    var gameVc: UIViewController?

    // Outlets
    @IBOutlet fileprivate weak var logoLabel: UILabel!
    @IBOutlet fileprivate weak var highScoreLabel: UILabel!
    @IBOutlet fileprivate weak var topButton: UIButton!
    @IBOutlet fileprivate weak var bottomButton: UIButton!


    // MARK: - Initialization -
    override func viewDidLoad()
    {
        self.updateHighScoreLabel()

        self.logoColorUpdateTimer = Timer.scheduledTimer(timeInterval: self.logoColorUpdateInterval,
                                                                           target: self,
                                                                           selector: #selector(updateLogoLabelColorTimeout),
                                                                           userInfo: nil,
                                                                           repeats: true)

        self.logoLabel.textColor = UIColor.marblesGreen()
        self.highScoreLabel.textColor = UIColor.marblesGreen()

        self.setupForNewGame()
    }


    // MARK: - Actions -
    @IBAction func newGameButtonPressed(_ sender: AnyObject)
    {
        self.gameVc = UIViewController()
        self.game = GameFactory.gameWithGraphicsType(.sceneKit, size: Size(9, 9), colorsCount: 5, marblesPerSpawn: 3, lineLength: 5) as? SceneKitGame
        self.gameVc!.view.addSubview(self.game!.view)
        self.gameVc!.modalTransitionStyle = .crossDissolve
        self.game!.view.frame = gameVc!.view.bounds

        weak var welf = self
        self.game!.pauseCallback = {
            welf?.currentLogoHue = 100.0/360.0
            welf?.updateHighScoreLabel()
            welf?.setupForResume()
            welf?.gameVc!.dismiss(animated: false, completion: nil)
            welf?.gameVc = nil
        }

        self.game!.quitCallback = {
            welf?.currentLogoHue = 100.0/360.0
            welf?.updateHighScoreLabel()
            welf?.setupForNewGame()
            welf?.gameVc!.dismiss(animated: false, completion: nil)
        }

        self.game!.startGame()
        self.present(self.gameVc!, animated: true, completion: nil)
    }


    @IBAction func resumeGameButtonPressed(_ sender: AnyObject)
    {
        self.present(self.gameVc!, animated: true, completion: nil)
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
            self.highScoreLabel.isHidden = false
            self.highScoreLabel.text = "High Score: \(ScoreSingleton.sharedInstance.highScore)"
        }
        else
        {
            self.highScoreLabel.isHidden = true
        }
    }


    fileprivate func setupForNewGame()
    {
        // Top Button
        self.topButton.setTitle("New Game", for: UIControlState())
        self.topButton.removeTarget(nil, action: nil, for: .allEvents)
        self.topButton.addTarget(self, action: #selector(newGameButtonPressed), for: .touchUpInside)

        // Bottom Button
        self.bottomButton.isHidden = true
    }


    fileprivate func setupForResume()
    {
        // Top Button
        self.topButton.setTitle("Resume", for: UIControlState())
        self.topButton.removeTarget(nil, action: nil, for: .allEvents)
        self.topButton.addTarget(self, action: #selector(resumeGameButtonPressed), for: .touchUpInside)

        // Bottom Button
        self.bottomButton.isHidden = false
        self.bottomButton.setTitle("New Game", for: UIControlState())
        self.bottomButton.removeTarget(nil, action: nil, for: .allEvents)
        self.bottomButton.addTarget(self, action: #selector(newGameButtonPressed), for: .touchUpInside)
    }
}
