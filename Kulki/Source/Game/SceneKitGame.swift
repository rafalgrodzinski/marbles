//
//  SceneKitGame.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 26/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import SceneKit

class SceneKitGame: Game
{
    private var scene: SCNScene!
    private(set) var tileSize: CGSize!


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

        (self.view as! SCNView).autoenablesDefaultLighting = true
        (self.view as! SCNView).allowsCameraControl = true

        self.tileSize = CGSizeMake(1.0, 1.0)

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }


    override func showBoard(finished: () -> Void)
    {
        for y in 0 ..< field.size.height {
            for x in 0 ..< field.size.width {
                let tile = SCNNode()
                tile.position = self.tilePositionForFieldPosition(Point(x, y))!
                tile.geometry = SCNPlane(width: self.tileSize.width, height: self.tileSize.height)

                let tileMaterial = SCNMaterial()
                tileMaterial.diffuse.contents = UIImage(named: "Tile")
                tileMaterial.normal.contents = UIImage(named: "Tile")
                tileMaterial.doubleSided = true
                tile.geometry!.firstMaterial = tileMaterial

                self.scene.rootNode.addChildNode(tile)
            }
        }

        finished()
    }


    override func showMarbles(marbles: [Marble], finished: () -> Void)
    {
        for (index, marble) in marbles.enumerate() {
            let scnMarble = marble as! SceneKitMarble

            scnMarble.node.position = self.marblePositionForFieldPosition(marble.fieldPosition)!
            self.scene.rootNode.addChildNode(scnMarble.node)
        }

        finished()
    }


    override func hideMarbles(marbles: [Marble], finished: () -> Void)
    {
        for (index, marble) in marbles.enumerate() {
            let scnMarble = marble as! SceneKitMarble

            scnMarble.node.removeFromParentNode()
        }

        finished()
    }


    override func selectMarble(marbe: Marble)
    {
    }


    override func deselectMarble(marbe: Marble)
    {
    }


    override func moveMarble(marble: Marble, overFieldPath fieldPath: [Point], finished: () -> Void)
    {
        for (index, position) in fieldPath.reverse().enumerate() {
            let newPosition = self.marblePositionForFieldPosition(position)!

            let waitAction = SCNAction.waitForDuration(0.2 * Double(index))
            let moveAction = SCNAction.moveTo(newPosition, duration: 0.2)
            let runBlockAction = SCNAction.runBlock { (node: SCNNode) in if index == fieldPath.count-1 { finished() } }

            (marble as! SceneKitMarble).node.runAction(SCNAction.sequence([waitAction, moveAction, runBlockAction]))
        }
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
        guard fieldPosition.x >= 0 && fieldPosition.x < self.field.size.width &&
            fieldPosition.y >= 0 && fieldPosition.y < self.field.size.height else {
                return nil
        }

        let tileXOrigin = -(CGFloat(self.field.size.width) * self.tileSize.width) / 2.0
        let tileYOrigin = -(CGFloat(self.field.size.height) * self.tileSize.height) / 2.0

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

        let tileXOrigin = -(CGFloat(self.field.size.width) * self.tileSize.width) / 2.0
        let tileYOrigin = -(CGFloat(self.field.size.height) * self.tileSize.height) / 2.0

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