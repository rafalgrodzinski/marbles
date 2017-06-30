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
        self.view.superview?.subviews.filter { $0 is MainMenuBackgroundView }.first?.removeFromSuperview()

        gameScale = 0.1
    }

    override func setupCamera()
    {
    }

    func setupCenterNode()
    {
        if let currentFrame = (self.view as? ARSCNView)?.session.currentFrame {
            // Setup center node
            var modelMatrix = matrix_identity_float4x4
            modelMatrix.columns.3.z = -1
            modelMatrix = matrix_multiply(currentFrame.camera.transform, modelMatrix)
            self.centerNode.simdTransform = modelMatrix

            // Setup gravity
            let gravity = self.scene.physicsWorld.gravity
            let gravityForceMatrix = simd_make_float4(gravity.x, gravity.y, gravity.z, 0.0)
            let gravityMatrix = simd_mul(currentFrame.camera.transform, gravityForceMatrix)
            self.scene.physicsWorld.gravity = SCNVector3(x: gravityMatrix.x, y: gravityMatrix.y, z: gravityMatrix.z)
        }
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
        } else {
            setupCenterNode()
            isStarted = true
            reallyShowBoard()
        }
    }
}
