//
//  ViewController.swift
//  Marbles
//
//  Created by Rafal Grodzinski on 31/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import Cocoa
import SceneKit

class MainMenuViewController: NSViewController {
    var game: Game?
    @IBOutlet var topButton: NSButton!
    @IBOutlet var bottomButton: NSButton!
    @IBOutlet var highScoreLabel: NSTextField!

    // MARK: - Initialization
    override func viewDidLoad()
    {
        updateHighScoreLabel()
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
            //self?.currentLogoHue = 100.0/360.0
            //self?.updateHighScoreLabel()
            //self?.setupForResume()
            //self?.gameVc!.dismiss(animated: false)
            self?.game?.view.removeFromSuperview()
        }

        game.quitCallback = { [weak self] in
            //self?.currentLogoHue = 100.0/360.0
            //self?.updateHighScoreLabel()
            //self?.setupForNewGame()
            //self?.gameVc!.dismiss(animated: false)
        }
    }

    private func setupForNewGame()
    {
        // Top Button
        topButton.isHidden = false
        set(title: "New Game", forButton: topButton)

        // Bottom Button
        bottomButton.isHidden = true
    }

    private func set(title: String, forButton button: NSButton)
    {
        let titleShadow = NSShadow()
        titleShadow.shadowColor = NSColor.black
        titleShadow.shadowBlurRadius = 2.0
        titleShadow.shadowOffset = NSSize(width: 2, height: -2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let titleAttributes: [NSAttributedStringKey : AnyObject] = [NSAttributedStringKey.font            : NSFont(name: "BunakenUnderwater", size: 28.0)!,
                                                                    NSAttributedStringKey.foregroundColor : NSColor.white,
                                                                    NSAttributedStringKey.shadow          : titleShadow,
                                                                    NSAttributedStringKey.paragraphStyle  : paragraphStyle]
        button.attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
    }

    private func updateHighScoreLabel()
    {
        /*if ScoreSingleton.sharedInstance.highScore > 0
        {*/
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
        /*}
        else
        {
            self.highScoreLabel.isHidden = true
        }*/
    }

    // MARK: - Actions
    @IBAction func newGameButtonPressed(_ sender: NSButton)
    {
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
