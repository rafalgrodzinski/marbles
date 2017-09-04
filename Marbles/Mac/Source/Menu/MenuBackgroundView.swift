//
//  MainMenuBackgroundView.swift
//  Marbles Mac
//
//  Created by Rafal Grodzinski on 04/09/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import AppKit

class MenuBackgroundView: NSView
{
    override func draw(_ dirtyRect: NSRect)
    {
        let gradient = NSGradient(colorsAndLocations: (NSColor(deviceWhite: 0.95, alpha: 1.0), 0.0),
                                                      (NSColor(deviceWhite: 0.98, alpha: 1.0), 0.5),
                                                      (NSColor(deviceWhite: 0.70, alpha: 1.0), 1.0))
        gradient?.draw(in: bounds, angle: -90.0)
    }
}
