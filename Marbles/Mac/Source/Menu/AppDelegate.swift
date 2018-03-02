//
//  AppDelegate.swift
//  Marbles
//
//  Created by Rafal Grodzinski on 31/08/2017.
//  Copyright © 2017 UnalignedByte. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        #if !DEBUG
            Fabric.with([Crashlytics.self])
        #endif
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
    {
        return true
    }
}
