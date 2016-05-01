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
    var bestScore = 0

    private var colorsCount = 0
    private var lineLength = 0

    let baseScore = 10
    let extraScore = 5


    private init()
    {
    }


    func newGameWithColorsCount(colorsCount: Int, lineLength: Int)
    {
        self.currentScore = 0

        self.colorsCount = colorsCount
        self.lineLength = lineLength
    }


    func scoresForColorsCount(colorsCount: Int, lineLength: Int) -> [Int]
    {
        return [Int]()
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