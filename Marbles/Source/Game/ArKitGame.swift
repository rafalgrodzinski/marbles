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
        self.view.superview?.subviews.filter { $0 is MainMenuBackgroundView }.removeAll()
        (self.view as! SCNView).isPlaying = false
        (self.view as! SCNView).antialiasingMode = .multisampling2X
        (self.view as! SCNView).preferredFramesPerSecond = 60
        //self.view.backgroundColor = UIColor.white

        if(self.scene == nil) {
            self.scene = SCNScene()
            (self.view as! SCNView).scene = self.scene!

            //let backgroundView = MainMenuBackgroundView(frame: self.view.bounds)
            //self.view.superview?.insertSubview(backgroundView, at: 0)

            //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        } else {
            self.scene.rootNode.enumerateChildNodes() { (node, p) in node.removeFromParentNode() }
        }

        //self.scene.physicsWorld.gravity = SCNVector3(0.0, 0.0, 0.0)
        self.scene.physicsWorld.gravity = SCNVector3(0.0, 0.0, -18.0)

        self.tileSize = CGSize(width: 0.1, height: 0.1)
        self.boardHeight = 0.025

        self.centerNode = SCNNode()
        self.scene.rootNode.addChildNode(self.centerNode)
        if let currentFrame = (self.view as? ARSCNView)?.session.currentFrame {
            var modelMatrix = matrix_identity_float4x4
            modelMatrix.columns.3.z = -1.5
            modelMatrix = matrix_multiply(currentFrame.camera.transform, modelMatrix)
            self.centerNode.simdTransform = modelMatrix

            //self.centerNode.simdTransform = currentFrame.camera.transform
        }
    }

    override func setupCamera()
    {
    }

    fileprivate var showBoardCallback: () -> Void
    override func showBoard(_ finished: @escaping () -> Void)
    {
        showBoardCallback = finished
    }

    func reallyShowBoard()
    {
        super.showBoard(showBoardCallback)
    }

    // MARK: - Control -
    fileprivate var isStarted = false
    override func handleTap(_ sender: UITapGestureRecognizer)
    {
        if isStarted {
            super.handleTap(sender)
        } else {
            isStarted = true
            reallyShowBoard()
        }
    }
}
