//
//  SceneKitGame.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 26/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import SceneKit
import SpriteKit
import GLKit


class SceneKitGame: Game, UIGestureRecognizerDelegate
{
    private var scene: SCNScene!
    private(set) var tileSize: CGSize!

    private var centerNode: SCNNode!
    private var tileSelectionParticleNode: SCNNode!
    private var tileSelectionParticle: SCNParticleSystem!

    private let boardHeight: Float = 0.25
    private let fieldMoveDuration: Float = 0.4

    let tilePrototype: SCNNode = { let tileNode = SCNNode()
        tileNode.geometry = SCNBox(width: 1.0, height: 1.0, length: 0.25, chamferRadius: 0.0)
        tileNode.geometry!.firstMaterial!.diffuse.contents = "TileDiffuse"
        tileNode.geometry!.firstMaterial!.normal.contents = "TileNormal"
        tileNode.physicsBody = SCNPhysicsBody.staticBody()
        tileNode.castsShadow = false
        return tileNode }()

    private var scoreLabel: SKLabelNode!
    private var scoreLabelShadow: SKLabelNode!
    private var gameOverPopup: GameOverPopup!

    private var cameraNode: SCNNode!


    // MARK: Initialization
    final override func setupView()
    {
        self.view = SCNView()
        (self.view as! SCNView).showsStatistics = true
    }


    final override func setupCustom()
    {
        (self.view as! SCNView).playing = false
        (self.view as! SCNView).antialiasingMode = .Multisampling4X
        self.view.backgroundColor = UIColor.clearColor()

        if(self.scene == nil) {
            self.scene = SCNScene()
            (self.view as! SCNView).scene = self.scene!

            let backgroundView = MainMenuBackgroundView(frame: self.view.bounds)
            self.view.superview?.insertSubview(backgroundView, atIndex: 0)

            self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        } else {
            self.scene.rootNode.enumerateChildNodesUsingBlock() { (node, p) in node.removeFromParentNode() }
        }

        self.scene.physicsWorld.gravity = SCNVector3(0.0, 0.0, -18)

        self.tileSize = CGSizeMake(1.0, 1.0)

        self.centerNode = SCNNode()
        self.scene.rootNode.addChildNode(self.centerNode)

        // Selection particle
        self.tileSelectionParticleNode = SCNNode()
        self.scene.rootNode.addChildNode(self.tileSelectionParticleNode)

        self.tileSelectionParticle = SCNParticleSystem(named: "Selection.scnp", inDirectory: nil)

        // Create spot light
        let spotLight = SCNLight()
        spotLight.type = SCNLightTypeSpot
        spotLight.shadowMode = .Forward
        spotLight.castsShadow = true
        spotLight.spotInnerAngle = 45.0;
        spotLight.spotOuterAngle = 90.0;
        spotLight.shadowSampleCount = 8
        spotLight.shadowRadius = 8.0
        spotLight.attenuationEndDistance = 50.0
        spotLight.attenuationStartDistance = 50.0
        spotLight.zFar = 100.0
        spotLight.attenuationFalloffExponent = 0
        spotLight.shadowMapSize = CGSizeMake(2048, 2048)

        let spotLightNode = SCNNode()
        spotLightNode.light = spotLight
        spotLightNode.constraints = [SCNLookAtConstraint(target: self.centerNode)]

        var spotLightPos = self.tilePositionForFieldPosition(Point(-self.field.size.width/2, -self.field.size.height/2))!
        spotLightPos.z = Float((self.field.size.width + self.field.size.height) )
        spotLightNode.position = spotLightPos
        self.scene.rootNode.addChildNode(spotLightNode)

        // Create ambient light
        let ambientLight = SCNLight()
        ambientLight.type = SCNLightTypeAmbient
        ambientLight.color = UIColor(white: 0.2, alpha: 1.0)

        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        self.scene.rootNode.addChildNode(ambientLightNode)

        // Create overlay
        let overlayScene = SKScene(size: self.view.frame.size)
        (self.view as! SCNView).overlaySKScene = overlayScene

        // Score label
        self.scoreLabel = SKLabelNode(fontNamed: "BunakenUnderwater")
        self.scoreLabel.fontSize = 32.0
        self.scoreLabel.fontColor = UIColor.marblesGreen()
        self.scoreLabel.horizontalAlignmentMode = .Center
        self.scoreLabel.verticalAlignmentMode = .Center
        self.scoreLabel.position = CGPointMake(overlayScene.size.width*2.0/3.0,
                                               overlayScene.size.height - 32.0)
        // Score label shadow
        self.scoreLabelShadow =  self.scoreLabel.copy() as! SKLabelNode
        self.scoreLabelShadow.fontColor = UIColor.blackColor()
        self.scoreLabelShadow.position.x += 1.5
        self.scoreLabelShadow.position.y -= 1.5

        overlayScene.addChild(self.scoreLabelShadow)
        overlayScene.addChild(self.scoreLabel)
        self.updateScore(0)

        // Menu button
        let menuButton = Button(defaultTexture: SKTexture(imageNamed: "Menu Button") , pressedTexture: nil)
        menuButton.position = CGPoint(x: menuButton.size.width/2.0 + 16.0, y: overlayScene.size.height - menuButton.size.height/2.0 - 16.0)
        menuButton.callback = self.pauseCallback
        overlayScene.addChild(menuButton)

        // Game over popup
        self.gameOverPopup = GameOverPopup(size: overlayScene.size)
        self.gameOverPopup.position = CGPointMake(CGRectGetMidX(overlayScene.frame), CGRectGetMidY(overlayScene.frame))
        self.gameOverPopup.restartCallback = self.startGame
        self.gameOverPopup.quitCallback = self.quitCallback
        overlayScene.addChild(self.gameOverPopup)

        self.scene.rootNode.castsShadow = false

        // Camera
        self.cameraNode = SCNNode()
        self.cameraNode.camera = SCNCamera()
        let height = Float(self.field.size.width > self.field.size.height ? self.field.size.width : self.field.size.height) * 1.6
        self.cameraNode.position = SCNVector3(0.0, 0.0, height)
        self.scene.rootNode.addChildNode(self.cameraNode)

        // Start the game
        (self.view as! SCNView).playing = true
    }


    override func showBoard(finished: () -> Void)
    {
        for y in 0 ..< field.size.height {
            for x in 0 ..< field.size.width {
                let tileNode = self.tilePrototype.duplicate()
                tileNode.position = self.tilePositionForFieldPosition(Point(x, y))!
                tileNode.position.z = -Float(self.boardHeight / 2.0)

                self.scene.rootNode.addChildNode(tileNode)
            }
        }

        // Add plane
        /*let grassNode = SCNNode()
        grassNode.position.z = -self.boardHeight
        grassNode.geometry = SCNPlane(width: 100, height: 100)
        grassNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "GrassDiffuse")
        grassNode.geometry?.firstMaterial?.diffuse.wrapS = .Repeat
        grassNode.geometry?.firstMaterial?.diffuse.wrapT = .Repeat
        grassNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(8.0, 8.0, 8.0)

        grassNode.geometry?.firstMaterial?.normal.contents = UIImage(named: "GrassNormal")
        grassNode.geometry?.firstMaterial?.normal.intensity = 0.5
        grassNode.geometry?.firstMaterial?.normal.wrapS = .Repeat
        grassNode.geometry?.firstMaterial?.normal.wrapT = .Repeat
        grassNode.geometry?.firstMaterial?.normal.contentsTransform = SCNMatrix4MakeScale(8.0, 8.0, 8.0)

        grassNode.geometry?.firstMaterial?.specular.contents = UIImage(named: "GrassDiffuse")
        grassNode.geometry?.firstMaterial?.specular.wrapS = .Repeat
        grassNode.geometry?.firstMaterial?.specular.wrapT = .Repeat
        grassNode.geometry?.firstMaterial?.specular.contentsTransform = SCNMatrix4MakeScale(8.0, 8.0, 8.0)

        self.scene.rootNode.addChildNode(grassNode)*/

        finished()
    }


    override func showMarbles(marbles: [Marble], finished: () -> Void)
    {
        for (index, marble) in marbles.enumerate() {
            let scnMarble = marble as! SceneKitMarble
            let targetPosition = scnMarble.node.position
            scnMarble.node.scale = SCNVector3Zero
            scnMarble.node.position.z += 1.0

            let waitAction = SCNAction.waitForDuration(0.2 * NSTimeInterval(index))

            let scaleAction = SCNAction.scaleTo(1.0, duration: 0.2)
            let fadeInAction = SCNAction.fadeInWithDuration(0.1)
            let appearAction = SCNAction.group([scaleAction, fadeInAction])
            let addGravityAction = SCNAction.runBlock { (node: SCNNode) in node.physicsBody = SCNPhysicsBody.dynamicBody() }
            let waitToSettle = SCNAction.waitForDuration(0.5)
            let moveToPoint = SCNAction.moveTo(targetPosition, duration: 0.1)
            let removeGravityAction = SCNAction.runBlock { (node: SCNNode) in node.physicsBody = nil }

            let runBlockAction = SCNAction.runBlock { (node: SCNNode) in if index == marbles.count-1 { finished() } }

            self.scene.rootNode.addChildNode(scnMarble.node)

            scnMarble.node.runAction(SCNAction.sequence([waitAction, appearAction, addGravityAction,
                waitToSettle, moveToPoint, removeGravityAction, runBlockAction]))
        }
    }


    override func hideMarbles(marbles: [Marble], finished: () -> Void)
    {
        for (index, marble) in marbles.enumerate() {
            let scnMarble = marble as! SceneKitMarble

            let waitAction = SCNAction.waitForDuration(0.1 * NSTimeInterval(index))

            let scaleAction = SCNAction.scaleTo(0.0, duration: 0.2)
            let fadeOutAction = SCNAction.fadeOutWithDuration(0.2)
            let disappearAction = SCNAction.group([scaleAction, fadeOutAction])
            let removeAction = SCNAction.removeFromParentNode()
            let runBlockAction = SCNAction.runBlock { (node: SCNNode) in if index == marbles.count-1 { finished() } }

            scnMarble.node.runAction(SCNAction.sequence([waitAction, disappearAction, removeAction, runBlockAction]))
        }
    }


    override func selectMarble(marbe: Marble)
    {
        (marbe as! SceneKitMarble).selected = true
    }


    override func deselectMarble(marbe: Marble)
    {
        (marbe as! SceneKitMarble).selected = false
    }


    override func moveMarble(marble: Marble, overFieldPath fieldPath: [Point], finished: () -> Void)
    {
        self.tileSelectionParticleNode.position = self.tilePositionForFieldPosition(fieldPath.last!)!
        self.tileSelectionParticleNode.addParticleSystem(self.tileSelectionParticle)

        let scnMarble = marble as! SceneKitMarble

        var previousFieldPosition = fieldPath.first!

        for (index, position) in fieldPath.enumerate() where index != 0 {
            // Rotation
            let rotationAngle: Float = (Float(self.tileSize.width) / (2.0 * π * Float((scnMarble.node.geometry as! SCNSphere).radius))) * 2 * π

            var xAngle: Float = 0.0
            if position.x > previousFieldPosition.x {
                xAngle = rotationAngle
            } else if (position.x < previousFieldPosition.x) {
                xAngle = -rotationAngle
            }

            var yAngle: Float = 0.0
            if position.y < previousFieldPosition.y {
                yAngle = rotationAngle
            } else if (position.y > previousFieldPosition.y) {
                yAngle = -rotationAngle
            }

            // X rotation
            var xAxisRotation = GLKVector3Make(0.0, 1.0, 0.0)
            xAxisRotation = GLKQuaternionRotateVector3(GLKQuaternionInvert(scnMarble.rotationQuat), xAxisRotation)
            scnMarble.rotationQuat = GLKQuaternionMultiply(scnMarble.rotationQuat, GLKQuaternionMakeWithAngleAndVector3Axis(Float(xAngle), xAxisRotation))

            // Y rotation
            var yAxisRotation = GLKVector3Make(1.0, 0.0, 0.0)
            yAxisRotation = GLKQuaternionRotateVector3(GLKQuaternionInvert(scnMarble.rotationQuat), yAxisRotation)
            scnMarble.rotationQuat = GLKQuaternionMultiply(scnMarble.rotationQuat, GLKQuaternionMakeWithAngleAndVector3Axis(Float(yAngle), yAxisRotation))

            let newRotationMatrix = GLKMatrix4MakeWithQuaternion(scnMarble.rotationQuat)
            let newPosition = self.marblePositionForFieldPosition(position)!

            // Timing function
            var timingFunction =  kCAMediaTimingFunctionLinear

            let positionDiff = position - previousFieldPosition
            let wasStraight = index >= 2 && fieldPath[index-2] == (previousFieldPosition - positionDiff)
            let willBeStraight = index <= fieldPath.count-2 && fieldPath[index+1] == (position + positionDiff)

            if !wasStraight && willBeStraight {
                timingFunction = kCAMediaTimingFunctionEaseIn
            } else if wasStraight && !willBeStraight {
                timingFunction = kCAMediaTimingFunctionEaseOut
            } else if !wasStraight && !willBeStraight {
                timingFunction = kCAMediaTimingFunctionEaseInEaseOut
            }

            // Actions
            let waitAction = SCNAction.waitForDuration(NSTimeInterval(self.fieldMoveDuration) * NSTimeInterval(index-1))

            let animAct = SCNAction.runBlock { (node:SCNNode) in
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(NSTimeInterval(self.fieldMoveDuration))
                SCNTransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: timingFunction))
                node.transform = SCNMatrix4FromGLKMatrix4(newRotationMatrix)
                node.position = newPosition
                SCNTransaction.commit()
            }

            let lastWaitAction = SCNAction.waitForDuration(NSTimeInterval(index == fieldPath.count-1 ? self.fieldMoveDuration : 0.0))

            let runBlockAction = SCNAction.runBlock { (node: SCNNode) in if index == fieldPath.count-1 { finished() } }

            (marble as! SceneKitMarble).node.runAction(SCNAction.sequence([waitAction, animAct, lastWaitAction, runBlockAction]))

            previousFieldPosition = position
        }
    }


    override func updateScore(newScore: Int)
    {
        self.scoreLabel.text = "Score: \(newScore)"
        self.scoreLabelShadow.text = self.scoreLabel.text
    }


    override func gameFinished(score: Int, isHighScore: Bool)
    {
        self.gameOverPopup.show(score, isHighScore: isHighScore)
    }


    // MARK: - Control -
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        let results = (self.view as! SCNView).hitTest(sender.locationInView(self.view), options: nil)

        for result in results {
            if let fieldPosition = self.fieldPositionForPosition(result.node.position) {
                self.tappedFieldPosition(fieldPosition)
                break
            }
        }
    }


    // MARK: - Utils -
    func tilePositionForFieldPosition(fieldPosition: Point) -> SCNVector3?
    {
        let tileXOrigin = -(CGFloat(self.field.size.width) * self.tileSize.width - self.tileSize.width) / 2.0
        let tileYOrigin = -(CGFloat(self.field.size.height) * self.tileSize.height - self.tileSize.height) / 2.0

        let x = tileXOrigin + self.tileSize.width * CGFloat(fieldPosition.x)
        let y = tileYOrigin + self.tileSize.height * CGFloat(fieldPosition.y)

        return SCNVector3(x: Float(x), y: Float(y), z: 0.0)
    }


    func marblePositionForFieldPosition(fieldPosition: Point) -> SCNVector3?
    {
        guard fieldPosition.x >= 0 && fieldPosition.x < self.field.size.width &&
            fieldPosition.y >= 0 && fieldPosition.y < self.field.size.height else {
                return nil
        }

        let tileXOrigin = -(CGFloat(self.field.size.width) * self.tileSize.width - self.tileSize.width) / 2.0
        let tileYOrigin = -(CGFloat(self.field.size.height) * self.tileSize.height - self.tileSize.width) / 2.0

        let x = tileXOrigin + self.tileSize.width * CGFloat(fieldPosition.x)
        let y = tileYOrigin + self.tileSize.height * CGFloat(fieldPosition.y)

        return SCNVector3(x: Float(x), y: Float(y), z: Float(self.tileSize.width) * 0.5 * 0.8)
    }


    func fieldPositionForPosition(position: SCNVector3) -> Point?
    {
        let tileXOrigin = -(CGFloat(self.field.size.width) * self.tileSize.width) / 2.0
        let tileYOrigin = -(CGFloat(self.field.size.height) * self.tileSize.height) / 2.0

        let x = Int((CGFloat(position.x) - tileXOrigin)/self.tileSize.width)
        let y = Int((CGFloat(position.y) - tileYOrigin)/self.tileSize.height)

        guard x >= 0 && x < self.field.size.width && y >= 0 && y < self.field.size.height else {
            return nil
        }

        return Point(x, y)
    }
}