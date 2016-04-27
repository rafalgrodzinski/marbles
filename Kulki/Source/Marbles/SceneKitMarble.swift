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
    let node: SCNNode

    init(color: Int, fieldPosition: Point, position: SCNVector3, size: CGSize)
    {
        self.node = SCNNode()
        super.init(color: color, fieldPosition: fieldPosition)

        // Setup geometry
        self.node.geometry = SCNSphere(radius: size.width/2.0)
        self.node.position = position

        // Setup material
        let material = SCNMaterial()
        material.diffuse.contents = self.colors[color]
        self.node.geometry?.firstMaterial = material
    }
}