//
//  GameScene.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 09/02/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import SpriteKit


class GameScene: SKScene
{
    var fieldSize: CGSize!


    convenience init(size: CGSize, fieldSize: CGSize)
    {
        self.init(size: size)

        self.fieldSize = fieldSize
    }
}