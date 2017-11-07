//
//  ArKitGame.swift
//  Marbles AR
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
    fileprivate var placeBoardButton: Button!
    fileprivate var extraInfoLabel: SKLabelNode!

    fileprivate var isScoreAndNextMarblesVisible: Bool = true {
        didSet {
            self.nextMarblesView.isHidden = !isScoreAndNextMarblesVisible
            self.scoreLabel.isHidden = !isScoreAndNextMarblesVisible
            self.scoreLabelShadow.isHidden = !isScoreAndNextMarblesVisible
            self.nextLabel.isHidden = !isScoreAndNextMarblesVisible
            self.nextLabelShadow.isHidden = !isScoreAndNextMarblesVisible
        }
    }

    override func setupView()
    {
        self.view = ARSCNView()
        let arConfig = ARWorldTrackingConfiguration()
        arConfig.planeDetection = .horizontal
        (self.view as! ARSCNView).session.run(arConfig)
        (self.view as! ARSCNView).delegate = self
        (self.view as! ARSCNView).automaticallyUpdatesLighting = false
        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))

        #if DEBUG
            (self.view as! ARSCNView).showsStatistics = true
        #endif
    }

    override func setupScene()
    {
        self.gameScale = boardWidthInCm / (100.0 * Float(field.size.width))

        super.setupScene()
        //self.scene.physicsWorld.gravity = SCNVector3(x: 0.0, y: -1.0, z: 0.0)
        self.setupPlaceholder()

        self.view.backgroundColor = UIColor.clear
        self.view.superview?.subviews.filter { $0 is MenuBackgroundView }.first?.removeFromSuperview()
    }

    fileprivate var placeholderNode: SCNNode!
    fileprivate func setupPlaceholder()
    {
        self.placeholderNode = SCNNode()
        self.placeholderNode.isHidden = true
        self.placeholderNode.opacity = 0.5

        for y in 0..<field.size.height {
            for x in 0..<field.size.width {
                let tileNode = self.tilePrototype.flattenedClone()
                tileNode.physicsBody = nil
                tileNode.position = self.tilePositionForFieldPosition(Point(x, y))!
                tileNode.position.z = 0.0
                self.placeholderNode.addChildNode(tileNode)
            }
        }

        self.centerNode.addChildNode(self.placeholderNode)
        self.centerNode.isHidden = true
    }


    override func setupShadowPlane()
    {
        let shadowPlane = SCNFloor()
        shadowPlane.reflectivity = 0.0
        shadowPlane.firstMaterial?.colorBufferWriteMask = []
        let shadowPlaneNode = SCNNode(geometry: shadowPlane)
        shadowPlaneNode.renderingOrder = 1
        shadowPlaneNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: Float.pi * 0.5)
        centerNode.addChildNode(shadowPlaneNode)
    }


    override func setupParticles()
    {
        super.setupParticles()

        // Velocity
        self.tileSelectionParticle.particleVelocity *= CGFloat(self.gameScale)
        // Particle size
        // For some reason doing self.titleSelectionParticle.particleSize = ... doesn't work, probably a bug
        let animation = CAKeyframeAnimation()
        animation.values = [self.gameScale]
        let particleController = SCNParticlePropertyController(animation: animation)
        self.tileSelectionParticle.propertyControllers = [SCNParticleSystem.ParticleProperty.size: particleController]
        // Emitter size
        if let sphere = self.tileSelectionParticle.emitterShape as? SCNSphere {
            sphere.radius *= CGFloat(self.gameScale)
        }
    }


    override func setupOverlay()
    {
        super.setupOverlay()
        self.setupNextMarbleScene()

        let isResumingGame = self.field.marbles.count > 0
        self.isScoreAndNextMarblesVisible = isResumingGame

        guard let skScene = (view as! SCNView).overlaySKScene else { return }

        // Place Board Button
        self.placeBoardButton = Button(defaultTexture: SKTexture(imageNamed: "Place Board Button"))
        self.placeBoardButton.isHidden = true
        let center = CGPoint(x: view.frame.midX, y: view.frame.midY - placeBoardButton.size.height * 2.0)
        self.placeBoardButton.position = center
        skScene.addChild(placeBoardButton)
        self.placeBoardButton.callback = { [weak self] in
            self?.placeBoardButton.removeFromParent()
            self?.extraInfoLabel.removeFromParent()
            self?.isStarted = true
            self?.placeBoard()
        }

        self.setupExtraInfoLabel()
    }


    fileprivate func setupExtraInfoLabel()
    {
        guard let skScene = (view as! SCNView).overlaySKScene else { return }

        self.extraInfoLabel = SKLabelNode(fontNamed: "BunakenUnderwater")
        self.extraInfoLabel.text = "Look around to find a surface..."
        self.extraInfoLabel.fontSize = 28.0
        self.extraInfoLabel.fontColor = Color.marblesGreen
        self.extraInfoLabel.horizontalAlignmentMode = .center
        self.extraInfoLabel.verticalAlignmentMode = .center
        self.extraInfoLabel.position = CGPoint(x: self.placeBoardButton.position.x,
                                               y: self.placeBoardButton.position.y +  self.placeBoardButton.size.height * 4.0)
        skScene.addChild(self.extraInfoLabel)
    }


    fileprivate func setupNextMarbleScene()
    {
        // Next marbles view
        self.nextMarblesView.frame = self.view.frame
        self.nextMarblesView.isUserInteractionEnabled = false
        self.view.superview?.addSubview(self.nextMarblesView)
        self.nextMarblesView.backgroundColor = UIColor.clear

        // Scene
        self.nextMarblesView.scene = SCNScene()
        self.nextMarblesView.antialiasingMode = .multisampling2X
        self.nextMarblesView.preferredFramesPerSecond = 60
        self.nextMarblesView.isPlaying = true

        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        let height = Float(self.field.size.width > self.field.size.height ? self.field.size.width : self.field.size.height) * 1.6
        cameraNode.position = SCNVector3(0.0, 0.0, height)
        self.nextMarblesView.scene?.rootNode.addChildNode(cameraNode)

        // Create spot light
        let spotLight = SCNLight()
        spotLight.type = SCNLight.LightType.spot
        spotLight.castsShadow = false
        spotLight.spotInnerAngle = 45.0;
        spotLight.spotOuterAngle = 90.0;
        spotLight.attenuationEndDistance = 50.0
        spotLight.attenuationStartDistance = 50.0
        spotLight.zNear = 1.0
        spotLight.zFar = 100.0
        spotLight.attenuationFalloffExponent = 0

        let spotLightNode = SCNNode()
        spotLightNode.light = spotLight
        spotLightNode.constraints = [SCNLookAtConstraint(target: self.nextMarblesView.scene?.rootNode)]

        var spotLightPos = self.tilePositionForFieldPosition(Point(-self.field.size.width/2, -self.field.size.height/2))!
        spotLightPos.z = Float(self.field.size.width + self.field.size.height)
        spotLightNode.position = spotLightPos
        self.nextMarblesView.scene?.rootNode.addChildNode(spotLightNode)

        // Create ambient light
        let ambientLight = SCNLight()
        ambientLight.type = SCNLight.LightType.ambient
        ambientLight.color = UIColor(white: 0.2, alpha: 1.0)

        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        self.nextMarblesView.scene?.rootNode.addChildNode(ambientLightNode)
    }


    override func setupCamera()
    {
    }


    // MARK: - Game Logic
    fileprivate var showBoardCallback: (() -> Void)?
    override func showBoard(_ finished: @escaping () -> Void)
    {
        self.showBoardCallback = finished
    }


    override func addNextMarble(_ marble: SceneKitMarble)
    {
        self.nextMarblesView.scene?.rootNode.addChildNode(marble.node)
    }


    func placeBoard()
    {
        self.placeholderNode.isHidden = true
        self.placeholderNode.removeFromParentNode()
        self.isScoreAndNextMarblesVisible = true
        
        if let showBoardCallback = showBoardCallback {
            super.showBoard(showBoardCallback)
        }
    }

    // MARK: - Control -
    fileprivate var isStarted = false
    /*override func handleTap(_ sender: UITapGestureRecognizer)
    {
        super.handleTap(sender)
    }*/

    func updateCenterNode(with transform: simd_float4x4)
    {
        if !isStarted {
            placeholderNode.isHidden = false
        }

        self.centerNode.isHidden = false

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

    // MARK: - ARKit
    fileprivate var centerNodeAnchor: ARAnchor?
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        if isStarted { return }

        DispatchQueue.main.async { [unowned self] in
            if self.centerNodeAnchor == nil {
                self.centerNodeAnchor = anchor
                self.updateCenterNode(with: anchor.transform)
                self.extraInfoLabel.text = "Surface found!"
                self.placeBoardButton.isHidden = false
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    {
        if let centerNodeAnchor = centerNodeAnchor, centerNodeAnchor == anchor {
            DispatchQueue.main.async { [unowned self] in
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
                    self.centerNodeAnchor = anchor
                    self.updateCenterNode(with: anchor.transform)
                } else {
                    self.updateCenterNode(with: result.worldTransform)
                }
                self.extraInfoLabel.text = "Surface found!"
                self.placeBoardButton.isHidden = false
            }
        }
    }
}
