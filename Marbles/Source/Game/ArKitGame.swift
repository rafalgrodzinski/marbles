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
    // MARK: - Setup
    fileprivate let boardWidthInCm: Float = 20.0
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
        gameScale = boardWidthInCm / (100.0 * Float(field.size.width))

        super.setupScene()
        setupPlaceholder()
        setupShadowPlane()

        self.view.backgroundColor = UIColor.clear
        self.view.superview?.subviews.filter { $0 is MainMenuBackgroundView }.first?.removeFromSuperview()

        setupDebug()
    }

    fileprivate var debugLabel: UILabel!
    fileprivate func setupDebug()
    {
        debugLabel = UILabel()
        debugLabel.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 30.0)
        debugLabel.textAlignment = .center
        view.addSubview(debugLabel)
        debugLabel.text = "Just started"
    }

    override func setupCamera()
    {
    }


    override func setupOverlay()
    {
        super.setupOverlay()

        guard let skScene = (view as! SCNView).overlaySKScene else { return }

        // Place Board Button
        let placeBoardButton = Button(defaultTexture: SKTexture(imageNamed: "Menu Button"))
        let center = CGPoint(x: view.frame.midX, y: view.frame.midY - placeBoardButton.size.height * 2.0)
        placeBoardButton.position = center
        skScene.addChild(placeBoardButton)
        placeBoardButton.callback = { [weak self] in
            placeBoardButton.removeFromParent()
            self?.setupNextMarbleScene()
            self?.isStarted = true
            self?.reallyShowBoard()
        }
    }

    fileprivate func setupNextMarbleScene()
    {
        DispatchQueue.main.async {
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
    }

    fileprivate var placeholderNode: SCNNode!
    fileprivate func setupPlaceholder()
    {
        placeholderNode = SCNNode()
        placeholderNode.isHidden = true
        placeholderNode.opacity = 0.5

        let scaleDownAction = SCNAction.scale(to: 0.9, duration: 0.8)
        scaleDownAction.timingMode = .easeInEaseOut
        let scaleUpAction = SCNAction.scale(to: 1.0, duration: 0.8)
        scaleUpAction.timingMode = .easeInEaseOut
        let pulseAction = SCNAction.repeatForever(SCNAction.sequence([scaleDownAction, scaleUpAction]))
        placeholderNode.runAction(pulseAction)

        for y in 0..<field.size.height {
            for x in 0..<field.size.width {
                let tileNode = self.tilePrototype.flattenedClone()
                tileNode.position = self.tilePositionForFieldPosition(Point(x, y))!
                tileNode.position.z = 0.0
                placeholderNode.addChildNode(tileNode)
            }
        }

        centerNode.addChildNode(placeholderNode)
    }

    fileprivate func setupShadowPlane()
    {
        let shadowPlane = SCNFloor()
        shadowPlane.reflectivity = 0.0
        shadowPlane.firstMaterial?.colorBufferWriteMask = []
        let shadowPlaneNode = SCNNode(geometry: shadowPlane)
        shadowPlaneNode.renderingOrder = 1
        shadowPlaneNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: Float.pi * 0.5)
        centerNode.addChildNode(shadowPlaneNode)
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
        placeholderNode.isHidden = true
        
        if let showBoardCallback = showBoardCallback {
            super.showBoard(showBoardCallback)
        }
    }

    // MARK: - Control -
    fileprivate var isStarted = false
    override func handleTap(_ sender: UITapGestureRecognizer)
    {
        super.handleTap(sender)
    }

    func updateCenterNode(with transform: simd_float4x4)
    {
        if !isStarted {
            placeholderNode.isHidden = false
        }

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

    // MARK: -
    fileprivate var centerNodeAnchor: ARAnchor?
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        DispatchQueue.main.async { [unowned self] in
            if self.centerNodeAnchor == nil {
                self.centerNodeAnchor = anchor
                self.updateCenterNode(with: anchor.transform)
                self.debugLabel.text = "Renderer added anchor"
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    {
        if let centerNodeAnchor = centerNodeAnchor, centerNodeAnchor == anchor {
            DispatchQueue.main.async { [unowned self] in
                self.debugLabel.text = "Anchor updated"
                self.updateCenterNode(with: anchor.transform)
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        if let lightEstimate = (self.view as! ARSCNView).session.currentFrame?.lightEstimate {
            ambientLight.intensity = lightEstimate.ambientIntensity
            spotLight.intensity = lightEstimate.ambientIntensity
        }

        hitTestNode()
    }

    fileprivate func hitTestNode()
    {
        if isStarted { return }

        DispatchQueue.main.async { [unowned self] in
            let screenCenter = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
            if let result = (self.view as! ARSCNView).hitTest(screenCenter, types: .featurePoint).first {
                if let anchor = result.anchor {
                    self.debugLabel.text = "New Anchor!"
                    self.centerNodeAnchor = anchor
                    self.updateCenterNode(with: anchor.transform)
                } else {
                    self.debugLabel.text = "New Position!"
                    self.updateCenterNode(with: result.worldTransform)
                }
            }
        }
    }
}
