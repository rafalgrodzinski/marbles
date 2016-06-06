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
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.2)
            if self.selected {
                self.node.geometry?.firstMaterial?.emission.contents = self.pastelColors[color]
                self.node.light = self.marbleLight
            } else {
                self.node.geometry?.firstMaterial?.emission.contents = UIColor.blackColor()
                self.node.light = nil
            }
            SCNTransaction.commit()
        }
    }

    var rotationQuat = GLKQuaternionIdentity

    init(color: Int, fieldPosition: Point, position: SCNVector3, size: CGSize)
    {
        self.node = SceneKitMarble.marblePrototype.duplicate()
        self.marbleLight = SCNLight()
        self.selected = false

        super.init(color: color, fieldPosition: fieldPosition)


        // Setup marble's rotation
        let xRot = (Float(arc4random() % 1000) / 1000.0) * 1.0
        let yRot = (Float(arc4random() % 1000) / 1000.0) * 1.0
        let zRot = (Float(arc4random() % 1000) / 1000.0) * 1.0
        let angle = (Float(arc4random() % 1000) / 1000.0) * 2.0 * π

        let rotationMatrix = GLKMatrix4MakeRotation(angle, xRot, yRot, zRot)
        self.rotationQuat = GLKQuaternionMakeWithMatrix4(rotationMatrix)
        self.node.transform = SCNMatrix4FromGLKMatrix4(rotationMatrix)

        // Then its position
        self.node.position = position

        // And finally the color
        self.node.geometry?.firstMaterial?.diffuse.contents = self.pastelColors[color]

        // Setup light
        self.marbleLight.type = SCNLightTypeOmni
        self.marbleLight.color = self.pastelColors[color]
        self.marbleLight.attenuationStartDistance = 1
        self.marbleLight.attenuationEndDistance = 2
        self.marbleLight.attenuationFalloffExponent = 1
    }
}