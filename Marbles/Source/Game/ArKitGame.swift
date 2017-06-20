//
//  ArKitGame.swift
//  Marbles
//
//  Created by Rafal Grodzinski on 20/06/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import ARKit


@available(iOS 11.0, *)
class ArKitGame: Game
{
    override func setupView()
    {
        self.view = ARSCNView()

        #if DEBUG
            (self.view as! ARSCNView).showsStatistics = true
        #endif
    }

    override func setupCustom()
    {
        let arConfig = ARWorldTrackingSessionConfiguration()
        (self.view as! ARSCNView).session.run(arConfig)
    }

    override func showBoard(_ finished: @escaping () -> Void) {
    }

    override func showMarbles(_ marbles: [Marble], nextMarbleColors: [Int], finished: @escaping () -> Void) {
    }

    override func hideMarbles(_ marbles: [Marble], finished: @escaping () -> Void) {
    }

    override func updateScore(_ newScore: Int) {
    }

    override func selectMarble(_ marbe: Marble) {
    }

    override func deselectMarble(_ marbe: Marble) {
    }

    override func moveMarble(_ marble: Marble, overFieldPath fieldPath: [Point], finished: @escaping () -> Void) {
    }

    override func gameFinished(_ score: Int, isHighScore: Bool) {
    }
}
