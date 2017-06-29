//
//  ArKitMarbleFactory.swift
//  Marbles
//
//  Created by Rafal Grodzinski on 20/06/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import ARKit

@available(iOS 11.0, *)
class ArKitMarbleFactory: MarbleFactory {
    weak var game: ArKitGame!


    override func marbleWithColor(_ color: Int, fieldPosition: Point) -> Marble!
    {
        return SceneKitMarble(color: color,
                              fieldPosition: fieldPosition,
                              position: game.marblePositionForFieldPosition(fieldPosition)!,
                              size: game.marbleSize)
    }
}
