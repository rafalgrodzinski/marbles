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
            NSUserDefaults.standardUserDefaults().setValue(currentScore, forKey: "kHighScore")
        }
    }

    private var colorsCount = 0
    private var lineLength = 0

    let baseScore = 10
    let extraScore = 5


    private init()
    {
        if let highScoreValue = NSUserDefaults.standardUserDefaults().valueForKey("kHighScore") {
            self.highScore = (highScoreValue as! NSNumber).integerValue
        }
    }


    func newGameWithColorsCount(colorsCount: Int, lineLength: Int)
    {
        self.currentScore = 0

        self.colorsCount = colorsCount
        self.lineLength = lineLength
    }


    func removedMarbles(marblesCount: Int)
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