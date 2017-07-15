//
//  GameViewController.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 09/02/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit
import Crashlytics


class MainMenuViewController: UIViewController
{
    // Constant
    let logoColorUpdateInterval = 1.0/60.0
    let logoColorUpdateAmount = 1.0/(60.0 * 15.0)
    var resumeButtonHeight: CGFloat = 0.0

    // Variables
    var currentLogoHue = 100.0/360.0
    var logoColorUpdateTimer: Timer!
    var game: Game?
    var gameVc: UIViewController?
    var isArModeSelected = true

    // Outlets
    @IBOutlet private weak var logoLabel: UILabel!
    @IBOutlet private weak var highScoreLabel: UILabel!
    @IBOutlet private weak var topButton: UIButton!
    @IBOutlet private weak var bottomButton: UIButton!
    @IBOutlet private weak var tipPromptLabel: UILabel!
    @IBOutlet private weak var arModeLabel: UILabel!
    @IBOutlet private weak var arModeSwitch: UISwitch!
    @IBOutlet private weak var arUnsupportedLabel: UILabel!


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
        self.highScoreLabel.textColor = UIColor.marblesLightGreen()
        self.arModeLabel.textColor = UIColor.marblesLightGreen()
        self.arUnsupportedLabel.textColor = UIColor.marblesOrange()
        self.tipPromptLabel.textColor = UIColor.white

        if !GameFactory.isArModeAvailable {
            self.isArModeSelected = false
            self.arModeLabel.isEnabled = false
            self.arModeSwitch.isEnabled = false
            self.arModeSwitch.isOn = false
            self.arUnsupportedLabel.isHidden = false
        }

        self.setupForNewGame()
    }


    override func viewDidAppear(_ animated: Bool)
    {
        #if !DEBUG
            Answers.logCustomEvent(withName: "Entered View", customAttributes: ["Name" : "MainMenu"])
        #endif
    }


    // MARK: - Actions -
    @IBAction func newGameButtonPressed(_ sender: UIButton)
    {
        #if !DEBUG
            Answers.logCustomEvent(withName: "Game", customAttributes: ["Action" : "Started"])
        #endif

        let graphicsType: GraphicsType = self.isArModeSelected ? .arKit : .sceneKit

        self.gameVc = UIViewController()
        self.game = GameFactory.gameWithGraphicsType(graphicsType, size: Size(9, 9), colorsCount: 5, marblesPerSpawn: 3, lineLength: 5)
        self.gameVc!.view.addSubview(self.game!.view)
        self.gameVc!.modalTransitionStyle = .crossDissolve
        self.game!.view.frame = gameVc!.view.bounds

        weak var welf = self
        self.game!.pauseCallback = {
            welf?.currentLogoHue = 100.0/360.0
            welf?.updateHighScoreLabel()
            welf?.setupForResume()
            welf?.gameVc!.dismiss(animated: false, completion: nil)
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
        #if !DEBUG
            Answers.logCustomEvent(withName: "Game", customAttributes: ["Action" : "Resumed"])
        #endif

        self.present(self.gameVc!, animated: true, completion: nil)
    }


    @IBAction func arModeSwitchToggled(_ sender: UISwitch)
    {
    }


    // MARK: - Internal Control -
    @objc func updateLogoLabelColorTimeout()
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

            if UserDefaults.standard.value(forKey: "hasTipped") == nil {
                self.tipPromptLabel.isHidden = false
            } else {
                self.tipPromptLabel.isHidden = true
            }
        }
        else
        {
            self.highScoreLabel.isHidden = true
            self.tipPromptLabel.isHidden = true
        }
    }


    fileprivate func setupForNewGame()
    {
        // Top Button
        self.topButton.setTitle("New Game", for: .normal)
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
