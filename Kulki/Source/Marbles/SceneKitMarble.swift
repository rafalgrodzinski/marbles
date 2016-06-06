//
//  SceneKitMarble.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 26/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import SceneKit
import GLKit


class SceneKitMarble: Marble
{
    static let marblePrototype: SCNNode = { let marbleScene = SCNScene(named: "Marble.scn")!
        return marbleScene.rootNode.childNodeWithName("Marble", recursively: false)!}()

    let node: SCNNode
    let marbleLight: SCNLight

    var selected: Bool {
        didSet {
            if self.selected {
                self.node.geometry?.firstMaterial?.emission.contents = self.colors[color]
                self.node.light = self.marbleLight
            } else {
                self.node.geometry?.firstMaterial?.emission.contents = UIColor.blackColor()
                self.node.light = nil
            }
        }
    }

    var rotationQuat = GLKQuaternionIdentity
    var xAngle = 0.0
    var yAngle = 0.0

    init(color: Int, fieldPosition: Point, position: SCNVector3, size: CGSize)
    {
        self.node = SceneKitMarble.marblePrototype.duplicate()
        self.marbleLight = SCNLight()
        self.selected = false

        super.init(color: color, fieldPosition: fieldPosition)


        // Setup marble
        self.node.position = position
        self.node.geometry?.firstMaterial?.diffuse.contents = self.colors[color]

        // Setup light
        self.marbleLight.type = SCNLightTypeOmni
        self.marbleLight.color = self.colors[color]
        self.marbleLight.attenuationStartDistance = 1
        self.marbleLight.attenuationEndDistance = 2
        self.marbleLight.attenuationFalloffExponent = 1


        let xRot = (Float(arc4random() % 1000) / 1000.0) * 2.0
        let yRot = (Float(arc4random() % 1000) / 1000.0) * 2.0
        let zRot = (Float(arc4random() % 1000) / 1000.0) * 2.0
        //self.node.eulerAngles = SCNVector3(xRot, yRot, zRot)
    }
}