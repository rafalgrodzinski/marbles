//
//  ViewController.swift
//  Marbles
//
//  Created by Rafal Grodzinski on 31/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import Cocoa
import SceneKit

private let logoColorUpdateInterval = 1.0/60.0
private let logoColorUpdateAmount = 1.0/(60.0 * 15.0)

class MenuViewController: NSViewController {
    private var game: Game?
    private var currentLogoHue = 100.0/360.0
    private var logoColorUpdateTimer: Timer!
    @IBOutlet private var logoLabel: NSTextField!
    @IBOutlet private var topButton: NSButton!
    @IBOutlet private var bottomButton: NSButton!
    @IBOutlet private var highScoreLabel: NSTextField!

    // MARK: - Initialization
    override func viewDidLoad()
    {
        updateHighScoreLabel()
        setupLogoColorUpdateTimer()
        setupForNewGame()
    }

    private func setupGame(field: Field?, drawnMarbleColors: [Int]?)
    {
        let game = GameFactory.gameWithGraphicsType(.sceneKit, size: Size(9, 9), colorsCount: 5, marblesPerSpawn: 3, lineLength: 5, field: field)
        self.game = game
        game.view.frame = view.bounds
        if let field = field {
            game.field = field
        }
        game.drawnMarbleColors = drawnMarbleColors

        game.pauseCallback = { [weak self] in
            self?.currentLogoHue = 100.0/360.0
            self?.updateHighScoreLabel()
            self?.setupForResume()
            self?.game?.view.isHidden = true
        }

        game.quitCallback = { [weak self] in
            self?.currentLogoHue = 100.0/360.0
            self?.updateHighScoreLabel()
            self?.setupForNewGame()
        }
    }

    private func setupForNewGame()
    {
        // In case of previus game being here
        game?.view.removeFromSuperview()
        game = nil

        // Top Button
        topButton.isHidden = false
        set(title: "New Game", forButton: topButton)
        topButton.target = self
        topButton.action = #selector(newGameButtonPressed)

        // Bottom Button
        bottomButton.isHidden = true
    }

    private func setupForResume()
    {
        // Top Button
        topButton.isHidden = false
        set(title: "Resume", forButton: topButton)
        topButton.target = self
        topButton.action = #selector(resumeGameButtonPressed)

        // Bottom Button
        bottomButton.isHidden = false
        set(title: "New Game", forButton: bottomButton)
        bottomButton.target = self
        bottomButton.action = #selector(newGameButtonPressed)
    }

    private func set(title: String, forButton button: NSButton)
    {
        let titleShadow = NSShadow()
        titleShadow.shadowColor = NSColor.black
        titleShadow.shadowBlurRadius = 2.0
        titleShadow.shadowOffset = NSSize(width: 2, height: -2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        button.attributedTitle = NSAttributedString(string: title, attributes: [.font            : NSFont(name: "BunakenUnderwater", size: 28.0)!,
                                                                                .foregroundColor : NSColor.white,
                                                                                .shadow          : titleShadow,
                                                                                .paragraphStyle  : paragraphStyle])
    }

    private func updateHighScoreLabel()
    {
        if ScoreSingleton.sharedInstance.highScore > 0
        {
            let titleShadow = NSShadow()
            titleShadow.shadowColor = NSColor.black
            titleShadow.shadowBlurRadius = 1.5
            titleShadow.shadowOffset = NSSize(width: 1.5, height: -1.5)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let titleAttributes: [NSAttributedStringKey : AnyObject] = [NSAttributedStringKey.font            : NSFont(name: "BunakenUnderwater", size: 24.0)!,
                                                                        NSAttributedStringKey.foregroundColor : Color.marblesGreen,
                                                                        NSAttributedStringKey.shadow          : titleShadow,
                                                                        NSAttributedStringKey.paragraphStyle  : paragraphStyle]
            self.highScoreLabel.attributedStringValue = NSAttributedString(string: "High Score: \(ScoreSingleton.sharedInstance.highScore)",
                                                                           attributes: titleAttributes)

            self.highScoreLabel.isHidden = false
        }
        else
        {
            self.highScoreLabel.isHidden = true
        }
    }

    private func setupLogoColorUpdateTimer()
    {
        self.logoColorUpdateTimer = Timer.scheduledTimer(timeInterval: logoColorUpdateInterval,
                                                         target: self,
                                                         selector: #selector(updateLogoLabelColorTimeout),
                                                         userInfo: nil,
                                                         repeats: true)
    }

    @objc private func updateLogoLabelColorTimeout()
    {
        logoLabel.textColor = NSColor(deviceHue: CGFloat(self.currentLogoHue), saturation: 0.8, brightness: 0.8, alpha: 1.0)

        self.currentLogoHue += logoColorUpdateAmount
        if self.currentLogoHue > 1.0 {
            self.currentLogoHue = 0.0
        }
    }

    // MARK: - Actions
    @IBAction func resumeGameButtonPressed(_ sender: NSButton)
    {
        game?.view.isHidden = false
    }

    @IBAction func newGameButtonPressed(_ sender: NSButton)
    {
        // In case of previus game being here
        game?.view.removeFromSuperview()
        game = nil

        setupGame(field: nil, drawnMarbleColors: nil)

        guard let game = self.game else { fatalError() }

        game.startGame()

        view.addSubview(game.view)
        game.view.translatesAutoresizingMaskIntoConstraints = false
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": game.view])
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": game.view])
        let constraints = [horizontal, vertical].flatMap { $0 }
        view.addConstraints(constraints)
    }
}
