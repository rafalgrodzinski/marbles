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

        let a = SCNNode()
        a.geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
        self.scene.rootNode.addChildNode(a)
    }


    override func showBoard(finished: () -> Void)
    {
    }
}