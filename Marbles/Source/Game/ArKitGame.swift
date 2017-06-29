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

        marbleSize = 0.1
        tileSize = CGSize(width: 0.1, height: 0.1)
        boardHeight = 0.025
        particleSize = 0.1
    }

    override func setupCamera()
    {
    }

    func setupCenterNode()
    {
        if let currentFrame = (self.view as? ARSCNView)?.session.currentFrame {
            var modelMatrix = matrix_identity_float4x4
            modelMatrix.columns.3.z = -1
            modelMatrix = matrix_multiply(currentFrame.camera.transform, modelMatrix)
            self.centerNode.simdTransform = modelMatrix
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
