//
//  SceneKitMarbleFactory.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 26/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

class SceneKitMarbleFactory: MarbleFactory
{
    weak var game: SceneKitGame!


    override func marbleWithColor(color: Int, fieldPosition: Point) -> Marble!
    {
        return SceneKitMarble(color: color,
                              fieldPosition: fieldPosition,
                              position: game.marblePositionForFieldPosition(fieldPosition)!,
                              size: game.tileSize * 0.8)
    }
}