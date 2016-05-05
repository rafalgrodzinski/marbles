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


class SceneKitGame: Game
{
    private var scene: SCNScene!
    private(set) var tileSize: CGSize!

    private var centerNode: SCNNode!
    private var tileSelectionParticleNode: SCNNode!
    private var tileSelectionParticle: SCNParticleSystem!

    private let boardHeight: Float = 0.25

    let tilePrototype: SCNNode = { let tileNode = SCNNode()
        tileNode.geometry = SCNBox(width: 1.0, height: 1.0, length: 0.25, chamferRadius: 0.0)
        tileNode.geometry!.firstMaterial!.diffuse.contents = "TileDiffuse"
        tileNode.geometry!.firstMaterial!.normal.contents = "TileNormal"
        tileNode.physicsBody = SCNPhysicsBody.staticBody()
        tileNode.castsShadow = false
        return tileNode }()

    private var scoreLabel: SKLabelNode!


    // MARK: Initialization
    override func setupView()
    {
        self.view = SCNView()
    }


    override func setupCustom()
    {
        self.scene = SCNScene()
        (self.view as! SCNView).scene = self.scene!
        (self.view as! SCNView).antialiasingMode = .Multisampling4X

        self.scene.background.contents = ["Skybox Back", "Skybox Front", "Skybox Right", "Skybox Left", "Skybox Bottom", "Skybox Top", ]
        self.scene.physicsWorld.gravity = SCNVector3(0.0, 0.0, -9.8)

        (self.view as! SCNView).allowsCameraControl = true

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
        spotLight.shadowMapSize = CGSizeMake(4096, 4096)

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

        // Overlay background
        let backWidth = 250.0
        let backHeight = 75.0
        let path = UIBezierPath(roundedRect: CGRectMake(0.0, 0.0, CGFloat(backWidth), CGFloat(backHeight)), cornerRadius: 10.0).CGPath
        let background = SKShapeNode(path: path, centered: true)
        background.position = CGPointMake(overlayScene.size.width/2.0,
            overlayScene.size.height - CGFloat(backHeight)/2.0 - 10.0)
        background.fillColor = UIColor(white: 0.0, alpha: 0.5)
        background.strokeColor = UIColor.clearColor()
        overlayScene.addChild(background)

        // Score label
        self.scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        self.scoreLabel.fontSize = 20.0
        self.scoreLabel.horizontalAlignmentMode = .Left
        self.scoreLabel.verticalAlignmentMode = .Center
        self.scoreLabel.position = CGPointMake(background.position.x - background.frame.size.width/2.0 + 10.0,
                                               background.position.y + 15.0)
        overlayScene.addChild(self.scoreLabel)
        self.updateScore(0)

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))

        self.scene.rootNode.castsShadow = false

        // Start the game
        (self.view as! SCNView).play(nil)
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
        let grassNode = SCNNode()
        grassNode.position.z = -self.boardHeight
        grassNode.geometry = SCNPlane(width: 100, height: 100)
        grassNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "GrassDiffuse")
        grassNode.geometry?.firstMaterial?.diffuse.wrapS = .Repeat
        grassNode.geometry?.firstMaterial?.diffuse.wrapT = .Repeat
        grassNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(4.0, 4.0, 4.0)

        grassNode.geometry?.firstMaterial?.normal.contents = UIImage(named: "GrassNormal")
        grassNode.geometry?.firstMaterial?.normal.intensity = 0.5
        grassNode.geometry?.firstMaterial?.normal.wrapS = .Repeat
        grassNode.geometry?.firstMaterial?.normal.wrapT = .Repeat
        grassNode.geometry?.firstMaterial?.normal.contentsTransform = SCNMatrix4MakeScale(4.0, 4.0, 4.0)

        grassNode.geometry?.firstMaterial?.specular.contents = UIImage(named: "GrassDiffuse")
        grassNode.geometry?.firstMaterial?.specular.wrapS = .Repeat
        grassNode.geometry?.firstMaterial?.specular.wrapT = .Repeat
        grassNode.geometry?.firstMaterial?.specular.contentsTransform = SCNMatrix4MakeScale(4.0, 4.0, 4.0)

        self.scene.rootNode.addChildNode(grassNode)

        finished()
    }


    override func showMarbles(marbles: [Marble], finished: () -> Void)
    {
        for (index, marble) in marbles.enumerate() {
            let scnMarble = marble as! SceneKitMarble
            scnMarble.node.scale = SCNVector3Zero
            scnMarble.node.position.z += 1.0

            let waitAction = SCNAction.waitForDuration(0.2 * NSTimeInterval(index))

            let scaleAction = SCNAction.scaleTo(1.0, duration: 0.2)
            let fadeInAction = SCNAction.fadeInWithDuration(0.1)
            let appearAction = SCNAction.group([scaleAction, fadeInAction])
            let addGravityAction = SCNAction.runBlock { (node: SCNNode) in node.physicsBody = SCNPhysicsBody.dynamicBody() }

            let waitToSettle = SCNAction.waitForDuration(1.0)
            let removeGravityAction = SCNAction.runBlock { (node: SCNNode) in node.physicsBody = nil }

            let runBlockAction = SCNAction.runBlock { (node: SCNNode) in if index == marbles.count-1 { finished() } }

            self.scene.rootNode.addChildNode(scnMarble.node)

            scnMarble.node.runAction(SCNAction.sequence([waitAction, appearAction, addGravityAction,
                waitToSettle, removeGravityAction, runBlockAction]))
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
            let angle: Float = (Float(self.tileSize.width) / (2.0 * π * Float((scnMarble.node.geometry as! SCNSphere).radius))) * 2 * π

            var xMult = 1.0
            if position.x < previousFieldPosition.x {
                xMult = -1.0
            }

            var yMult = 1.0
            if position.y < previousFieldPosition.y {
                yMult = -1.0
            }

            //let xAngle = Float(position.x - previousFieldPosition.x) * angle
            //let yAngle = Float(position.y - previousFieldPosition.y) * angle

            //print("xAngle: \(xAngle)")

            if position.x != previousFieldPosition.x {
                var up = GLKVector3Make(0.0, Float(xMult), 0.0)
                up = GLKQuaternionRotateVector3(GLKQuaternionInvert(scnMarble.rotationQuat), up)
                scnMarble.rotationQuat = GLKQuaternionMultiply(scnMarble.rotationQuat, GLKQuaternionMakeWithAngleAndVector3Axis(angle, up))
            }

            if position.y != previousFieldPosition.y {
                var right = GLKVector3Make(Float(yMult), 0.0, 0.0)
                right = GLKQuaternionRotateVector3(GLKQuaternionInvert(scnMarble.rotationQuat), right)
                scnMarble.rotationQuat = GLKQuaternionMultiply(scnMarble.rotationQuat, GLKQuaternionMakeWithAngleAndVector3Axis(-angle, right))
            }

            let a = GLKQuaternionAxis(scnMarble.rotationQuat)
            let rotationAxis = SCNVector3FromGLKVector3(a)
            let rotationAngle = CGFloat(GLKQuaternionAngle(scnMarble.rotationQuat))

            // Movement
            let newPosition = self.marblePositionForFieldPosition(position)!

            let waitAction = SCNAction.waitForDuration(0.5 * Double(index))

            //let rotateAction = SCNAction.rotateByAngle(rotationAngle, aroundAxis: rotationAxis, duration: 0.5)
            let rotateAction = SCNAction.rotateToAxisAngle(SCNVector4(rotationAxis.x, rotationAxis.y, rotationAxis.z, Float(rotationAngle)), duration: 0.5)
            let moveAction = SCNAction.moveTo(newPosition, duration: 0.5)
            let moveGroup = SCNAction.group([moveAction, rotateAction])

            let runBlockAction = SCNAction.runBlock { (node: SCNNode) in if index == fieldPath.count-1 { finished() } }

            (marble as! SceneKitMarble).node.runAction(SCNAction.sequence([waitAction, moveGroup, runBlockAction]))

            previousFieldPosition = position
        }
    }


    override func updateScore(newScore: Int)
    {
        self.scoreLabel.text = "Your score: \(newScore)"
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