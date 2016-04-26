//
//  GameFactory.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 24/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import Foundation


enum GraphicsType {
    case SpriteKit
    case SceneKit
}


class GameFactory
{
    class func gameWithGraphicsType(graphicsType: GraphicsType, size: Size, colorsCount: Int, marblesPerSpawn: Int, lineLength: Int) -> Game
    {
        // Initialize marble factory
        var marbleFactory: MarbleFactory!

        switch graphicsType {
            case .SpriteKit:
                marbleFactory = SpriteKitMarbleFactory()
            default:
                marbleFactory = SceneKitMarbleFactory()
        }

        // Initialize field
        let field = Field(size: size, colorsCount: colorsCount, marblesPerSpawn: marblesPerSpawn, lineLength: lineLength, marbleFactory: marbleFactory)

        // Initialize game
        var game: Game!

        switch graphicsType {
            case .SpriteKit:
                game = SpriteKitGame(field: field)
                (marbleFactory as! SpriteKitMarbleFactory).game = game as! SpriteKitGame
            default:
                game = SceneKitGame(field: field)
                (marbleFactory as! SceneKitMarbleFactory).game = game as! SceneKitGame
        }

        return game
    }
}