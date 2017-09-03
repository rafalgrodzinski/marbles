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

    // MARK: - Initialization
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

    // MARK: - Actions
    @IBAction func newGameButtonPressed(_ sender: NSButton) {
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
