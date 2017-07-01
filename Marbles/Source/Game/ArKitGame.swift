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
    fileprivate let nextMarblesView = SCNView()
    override func setupView()
    {
        self.view = ARSCNView()
        let arConfig = ARWorldTrackingSessionConfiguration()
        arConfig.planeDetection = .horizontal
        (self.view as! ARSCNView).session.run(arConfig)
        (self.view as! ARSCNView).delegate = self
        (self.view as! ARSCNView).automaticallyUpdatesLighting = false
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

    func setupCenterNode(with transform: simd_float4x4)
    {
        // Setup center node
        var modelMatrix = SCNMatrix4(simdMatrix: transform)
        let rotateMatrix = SCNMatrix4MakeRotation(-Float.pi * 0.5, 1.0, 0.0, 0.0) // Make it horizontal
        modelMatrix = SCNMatrix4Mult(rotateMatrix, modelMatrix)
        self.centerNode.transform = modelMatrix

        // Setup gravity
        let gravityForceMatrix = simd_make_float4(0.0, -1.8, 0.0, 0.0)
        let gravityMatrix = simd_mul(transform, gravityForceMatrix)
        self.scene.physicsWorld.gravity = SCNVector3(x: gravityMatrix.x, y: gravityMatrix.y, z: gravityMatrix.z)
    }

    fileprivate func setupNextMarbleScene()
    {
        // Next marbles view
        self.nextMarblesView.frame = self.view.frame
        self.nextMarblesView.isUserInteractionEnabled = false
        self.view.superview?.addSubview(self.nextMarblesView)
        self.nextMarblesView.backgroundColor = UIColor.clear

        self.nextMarblesView.scene = SCNScene()
        self.nextMarblesView.antialiasingMode = .multisampling2X
        self.nextMarblesView.preferredFramesPerSecond = 60
        self.nextMarblesView.isPlaying = true

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        let height = Float(self.field.size.width > self.field.size.height ? self.field.size.width : self.field.size.height) * 1.6
        cameraNode.position = SCNVector3(0.0, 0.0, height)
        self.nextMarblesView.scene?.rootNode.addChildNode(cameraNode)
    }

    override func addNextMarble(_ marble: SceneKitMarble)
    {
        self.nextMarblesView.scene?.rootNode.addChildNode(marble.node)
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
            setupNextMarbleScene()
            setupCenterNode(with: currentFrame.camera.transform)
            isStarted = true
            reallyShowBoard()
        }
    }

    // MARK: -
    fileprivate var centerNodeAnchor: ARAnchor?
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        if !isStarted {
            setupNextMarbleScene()
            centerNodeAnchor = anchor
            setupCenterNode(with: anchor.transform)
            isStarted = true
            reallyShowBoard()
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    {
        if let centerNodeAnchor = centerNodeAnchor, centerNodeAnchor == anchor {
            setupCenterNode(with: anchor.transform)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        if let lightEstimate = (self.view as! ARSCNView).session.currentFrame?.lightEstimate {
            ambientLight.intensity = lightEstimate.ambientIntensity
            spotLight.intensity = lightEstimate.ambientIntensity
        }
    }
}
