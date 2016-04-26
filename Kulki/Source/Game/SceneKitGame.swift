//
//  SceneKitGame.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 26/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import SceneKit

class SceneKitGame: Game
{
    private var scene: SCNScene!


    // MARK: Initialization
    override func setupView()
    {
        self.view = SCNView()
    }


    override func setupCustom()
    {
        self.scene = SCNScene()
        (self.view as! SCNView).scene = self.scene!

        (self.view as! SCNView).autoenablesDefaultLighting = true
        (self.view as! SCNView).allowsCameraControl = true

        /*let a = SCNNode()
        a.geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        self.scene.rootNode.addChildNode(a)*/
    }


    override func showBoard(finished: () -> Void)
    {
        for y in 0 ..< field.size.height {
            for x in 0 ..< field.size.width {
                let tile = SCNNode()
                tile.geometry = SCNPlane(width: 1.0, height: 1.0)
                let tileMaterial = SCNMaterial()
                tileMaterial.diffuse.contents = UIImage(named: "Tile")
                tileMaterial.normal.contents = UIImage(named: "Tile")
                tile.geometry!.firstMaterial = tileMaterial

                /*let tile = SKSpriteNode(imageNamed: "Tile")
                tile.size = self.tileSize
                tile.position = self.positionForFieldPosition(Point(x, y))!

                self.scene.addChild(tile)*/
                self.scene.rootNode.addChildNode(tile)
            }
        }
    }
}