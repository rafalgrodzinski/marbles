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
        return marbleScene.rootNode.childNode(withName: "Marble", recursively: false)!}()

    let node: SCNNode
    let marbleLight: SCNLight
    var ligthShaders: [SCNShaderModifierEntryPoint : String]?

    var selected: Bool {
        didSet {
            if self.selected {
                self.node.light = self.marbleLight
                self.node.geometry?.shaderModifiers = self.ligthShaders
            } else {
                self.node.light = nil
                self.node.geometry?.shaderModifiers = nil
            }
        }
    }

    var rotationQuat = GLKQuaternionIdentity

    init(color: Int, fieldPosition: Point, position: SCNVector3, scale: Float)
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

        // Scale
        self.node.scale = SCNVector3Make(scale, scale, scale)

        // And finally the color
        self.node.geometry?.firstMaterial?.diffuse.contents = self.colors[color]

        // Setup light
        self.marbleLight.type = SCNLight.LightType.omni
        self.marbleLight.color =  self.colors[color]
        self.marbleLight.attenuationStartDistance = 1
        self.marbleLight.attenuationEndDistance = 2
        self.marbleLight.attenuationFalloffExponent = 1

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.colors[color].getRed(&r, green: &g, blue: &b, alpha: &a)
        let s = String(format: "float mult = pow(1.0 - dot(_surface.view, _surface.normal), 1.0); " +
            "_output.color += float4(mult * %f, mult * %f, mult * %f, 1.0);", r, g, b)
        self.node.geometry?.shaderModifiers = [SCNShaderModifierEntryPoint.fragment : s]
        self.ligthShaders = self.node.geometry?.shaderModifiers
        self.node.geometry?.shaderModifiers = nil
    }


    deinit {
        self.node.geometry?.shaderModifiers = nil
        self.node.geometry?.firstMaterial?.diffuse.contents = nil
        self.node.geometry = nil
    }
}
