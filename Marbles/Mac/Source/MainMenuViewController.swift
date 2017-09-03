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
    //var game: Game?
    var gameVc: NSViewController?

    // MARK: - Initialization
    /*private func setupGame(field: Field?, drawnMarbleColors: [Int]?)
    {
        self.gameVc = NSViewController()
        self.game = GameFactory.gameWithGraphicsType(.sceneKit, size: Size(9, 9), colorsCount: 5, marblesPerSpawn: 3, lineLength: 5, field: field)
        self.gameVc!.view.addSubview(self.game!.view)
        //self.gameVc!.modalTransitionStyle = .crossDissolve
        self.game!.view.frame = gameVc!.view.bounds
        if let field = field {
            self.game!.field = field
        }
        self.game!.drawnMarbleColors = drawnMarbleColors

        self.game!.pauseCallback = { [weak self] in
            //self?.currentLogoHue = 100.0/360.0
            //self?.updateHighScoreLabel()
            //self?.setupForResume()
            self?.gameVc!.dismiss(animated: false)
        }

        self.game!.quitCallback = { [weak self] in
            //self?.currentLogoHue = 100.0/360.0
            //self?.updateHighScoreLabel()
            //self?.setupForNewGame()
            self?.gameVc!.dismiss(animated: false)
        }
    }*/

    // MARK: - Actions
    @IBAction func newGameButtonPressed(_ sender: NSButton) {
        //setupGame(field: nil, drawnMarbleColors: nil)

        //self.game!.startGame()
        //self.present(self.gameVc!, animated: true, completion: nil)
    }
}
