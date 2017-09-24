//
//  GameFactory.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 24/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import Foundation
#if os(iOS)
import ARKit
#endif


enum GraphicsType {
    case spriteKit
    case sceneKit
    case arKit
}


class GameFactory
{
    #if os(iOS)
    class var isArModeAvailable: Bool {
        if #available(iOS 11.0, *) { return ARWorldTrackingConfiguration.isSupported }
        return false
    }
    #endif

    class func gameWithGraphicsType(_ graphicsType: GraphicsType, size: Size, colorsCount: Int, marblesPerSpawn: Int, lineLength: Int, field: Field? = nil) -> Game
    {
        // Initialize marble factory
        var marbleFactory: MarbleFactory!

        switch graphicsType {
            case .spriteKit:
                #if os(iOS)
                marbleFactory = SpriteKitMarbleFactory()
                #else
                fatalError()
                #endif
            case .arKit:
                fallthrough
            case .sceneKit:
                marbleFactory = SceneKitMarbleFactory()
        }

        // Initialize field
        let field = field ?? Field(size: size, colorsCount: colorsCount, marblesPerSpawn: marblesPerSpawn, lineLength: lineLength, marbleFactory: marbleFactory)

        // Initialize game
        var game: Game!

        switch graphicsType {
            case .spriteKit:
                #if os(iOS)
                game = SpriteKitGame(field: field)
                (marbleFactory as! SpriteKitMarbleFactory).game = game as! SpriteKitGame
                #else
                fatalError()
                #endif
            case .sceneKit:
                game = SceneKitGame(field: field)
                (marbleFactory as! SceneKitMarbleFactory).game = game as! SceneKitGame
            case .arKit:
                #if os(iOS)
                if #available(iOS 11.0, *) {
                    game = ArKitGame(field: field)
                    (marbleFactory as! SceneKitMarbleFactory).game = game as! ArKitGame
                } else {
                    fatalError()
                }
                #else
                fatalError()
                #endif
        }

        return game
    }
}
