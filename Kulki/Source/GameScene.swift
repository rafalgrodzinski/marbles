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
    var field: Field!
    var tileSize: CGFloat!


    convenience init(size: CGSize, fieldSize: CGSize)
    {
        self.init(size: size)

        let maxTileWidth = size.width/fieldSize.width
        let maxTileHeight = size.height/fieldSize.height

        self.field = Field(fieldSize: fieldSize)
        self.tileSize = round(maxTileWidth < maxTileHeight ? maxTileWidth : maxTileHeight)

        let tileXOrigin = (size.width - fieldSize.width * tileSize) / 2.0 + tileSize/2.0
        let tileYOrigin = (size.height - fieldSize.height * tileSize) / 2.0 + tileSize/2.0

        for y in 0 ..< Int(field.height) {
            for x in 0 ..< Int(field.width) {
                let tile = SKSpriteNode(imageNamed: "Tile")
                tile.size = CGSizeMake(self.tileSize, self.tileSize)
                tile.position.x = tileXOrigin + tileSize * CGFloat(x)
                tile.position.y = tileYOrigin + tileSize * CGFloat(y)

                self.addChild(tile)
            }
        }
    }
}