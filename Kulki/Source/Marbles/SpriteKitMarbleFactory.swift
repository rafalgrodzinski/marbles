//
//  SpriteKitMarbleFactory.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 24/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

class SpriteKitMarbleFactory: MarbleFactory
{
    weak var game: SpriteKitGame!

    
    override func marbleWithColor(color: Int, fieldPosition: Point) -> Marble!
    {
        return SpriteKitMarble(color: color,
                               fieldPosition: fieldPosition,
                               position: game.positionForFieldPosition(fieldPosition)!,
                               size: game.tileSize * 0.80)
    }
}