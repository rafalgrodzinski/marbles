//
//  Button.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 28/06/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import SpriteKit

class Button: SKSpriteNode
{
    private var defaultTexture: SKTexture? = nil
    private var pressedTexture: SKTexture? = nil

    var callback: (() -> Void)?


    // MARK: - Initialization -
    init(defaultTexture: SKTexture, pressedTexture: SKTexture?)
    {
        self.defaultTexture = defaultTexture
        self.pressedTexture = pressedTexture

        super.init(texture: defaultTexture, color: UIColor.clearColor(), size: defaultTexture.size())

        self.userInteractionEnabled = true
    }


    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }


    // MARK: - Control -
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.showPressed()
    }


    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.touchesCancelled(touches, withEvent: event)
    }


    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?)
    {
        self.showDefault()

        for touch in touches! {
            let location = touch.locationInNode(self.parent!)

            if self.containsPoint(location) {
                if let callback = self.callback {
                    callback()
                }
            }
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        for touch in touches {
            let location = touch.locationInNode(self.parent!)

            if self.containsPoint(location) {
                self.showPressed()
                return
            }
        }

        self.showDefault()
    }


    // MARK: - Internal Control -
    private func showDefault()
    {
        self.texture = self.defaultTexture
        self.colorBlendFactor = 0.0
    }


    private func showPressed()
    {
        if let pressedTexture = self.pressedTexture {
            self.texture = pressedTexture
        } else {
            self.color = UIColor(white: 0.0, alpha: 1.0)
            self.colorBlendFactor = 0.5
        }
    }
}