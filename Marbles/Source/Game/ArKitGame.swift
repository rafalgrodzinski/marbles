//
//  ArKitGame.swift
//  Marbles
//
//  Created by Rafal Grodzinski on 20/06/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import ARKit


@available(iOS 11.0, *)
class ArKitGame: SceneKitGame, ARSCNViewDelegate
{
    override func setupView()
    {
        self.view = ARSCNView()
        let arConfig = ARWorldTrackingSessionConfiguration()
        arConfig.planeDetection = .horizontal
        (self.view as! ARSCNView).session.run(arConfig)
        (self.view as! ARSCNView).delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))

        #if DEBUG
            (self.view as! ARSCNView).showsStatistics = true
        #endif
    }

    override func setupScene()
    {
        super.setupScene()

        self.view.backgroundColor = UIColor.clear
        self.view.superview?.subviews.filter { $0 is MainMenuBackgroundView }.first?.removeFromSuperview()

        gameScale = 0.1
    }

    override func setupCamera()
    {
    }

    func setupCenterNode(with transform: SCNMatrix4)
    {
        // Setup center node
        var modelMatrix = transform
        let translateMatrix = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0)
        modelMatrix = SCNMatrix4Mult(translateMatrix, modelMatrix)
        let rotateMatrix = SCNMatrix4MakeRotation(-Float.pi * 0.5, 0.0, 1.0, 0.0)
        modelMatrix = SCNMatrix4Mult(rotateMatrix, modelMatrix)
        self.centerNode.transform = modelMatrix

        // Setup gravity
        let gravity = self.scene.physicsWorld.gravity
        let gravityForceMatrix = simd_make_float4(gravity.x, gravity.y, gravity.z, 0.0)
        let gravityMatrix = simd_mul(transform, gravityForceMatrix)
        self.scene.physicsWorld.gravity = SCNVector3(x: gravityMatrix.x, y: gravityMatrix.y, z: gravityMatrix.z)
    }

    fileprivate var showBoardCallback: (() -> Void)?
    override func showBoard(_ finished: @escaping () -> Void)
    {
        showBoardCallback = finished
    }

    func reallyShowBoard()
    {
        if let showBoardCallback = showBoardCallback {
            super.showBoard(showBoardCallback)
        }
    }

    // MARK: - Control -
    fileprivate var isStarted = false
    override func handleTap(_ sender: UITapGestureRecognizer)
    {
        if isStarted {
            super.handleTap(sender)
        } else if let currentFrame = (self.view as? ARSCNView)?.session.currentFrame {
            let t = SCNMatrix4(simdMatrix: currentFrame.camera.transform)
            setupCenterNode(with: t)
            isStarted = true
            reallyShowBoard()
        }
    }

    // MARK: -
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !isStarted {
            print("Anchor added!")
            self.centerNode.removeFromParentNode()
            node.addChildNode(self.centerNode)
            self.scene.rootNode.addChildNode(node)
            reallyShowBoard()
        }
    }
}
