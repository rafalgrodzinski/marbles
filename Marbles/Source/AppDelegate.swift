//
//  AppDelegate.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 31/01/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        return true
    }


    private func setupAnalytics()
    {
        #if !DEBUG
            Fabric.with([Crashlytics.self])
        #endif
    }
}

