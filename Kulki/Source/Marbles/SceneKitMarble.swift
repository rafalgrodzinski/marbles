//
//  SceneKitMarble.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 26/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import SceneKit


class SceneKitMarble: Marble
{
    static let marblePrototype: SCNNode = { let marbleScene = SCNScene(named: "Marble.scn")!
        return marbleScene.rootNode.childNodeWithName("Marble", recursively: false)!}()

    let node: SCNNode

    init(color: Int, fieldPosition: Point, position: SCNVector3, size: CGSize)
    {
        self.node = SceneKitMarble.marblePrototype.duplicate()

        super.init(color: color, fieldPosition: fieldPosition)

        // Setup marble
        self.node.position = position
        self.node.geometry?.firstMaterial?.diffuse.contents = self.colors[color]

        let xRot = (Float(arc4random() % 1000) / 1000.0) * 2.0
        let yRot = (Float(arc4random() % 1000) / 1000.0) * 2.0
        let zRot = (Float(arc4random() % 1000) / 1000.0) * 2.0
        self.node.eulerAngles = SCNVector3(xRot, yRot, zRot)
    }
}