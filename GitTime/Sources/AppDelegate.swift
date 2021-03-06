//
//  AppDelegate.swift
//  GitTime
//
//  Created by Kanz on 09/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let window = window else { return false }
        AppDependency.shared.configureCoordinator(launchOptions: launchOptions, window: window)
        return true
    }

}
