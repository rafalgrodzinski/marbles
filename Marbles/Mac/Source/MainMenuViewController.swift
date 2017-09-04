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

    // MARK: - Initialization
    override func viewDidLoad()
    {
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
        // Top Button
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
