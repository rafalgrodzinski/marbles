//
//  ScoreSingleton.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 01/05/2016.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import Foundation

class ScoreSingleton
{
    static let sharedInstance = ScoreSingleton()

    var currentScore = 0
    var highScore = 0 {
        didSet {
            UserDefaults.standard.setValue(currentScore, forKey: "kHighScore")
        }
    }

    fileprivate var colorsCount = 0
    fileprivate var lineLength = 0

    let baseScore = 10
    let extraScore = 5

    fileprivate init()
    {
        if let highScoreValue = UserDefaults.standard.value(forKey: "kHighScore") {
            self.highScore = (highScoreValue as! NSNumber).intValue
        }
    }

    func newGameWithColorsCount(_ colorsCount: Int, lineLength: Int)
    {
        self.currentScore = 0

        self.colorsCount = colorsCount
        self.lineLength = lineLength
    }

    func removedMarbles(_ marblesCount: Int)
    {
        guard marblesCount >= self.lineLength else {
            return
        }

        let baseScore = self.baseScore
        let extraScore = (marblesCount - self.lineLength) * self.extraScore

        let score = (baseScore + extraScore) * self.colorsCount

        self.currentScore += score
    }
}
