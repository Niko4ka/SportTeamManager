//
//  AppDelegate.swift
//  SportTeamManager
//
//  Created by Вероника Данилова on 19/11/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "MainViewController", bundle: Bundle.main)
        
        guard let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else {
            return false
        }
        
        // Initiate Navagation Controller
        
        window = UIWindow()
        window?.rootViewController = UINavigationController(rootViewController: mainViewController)
        window?.makeKeyAndVisible()
        
        return true
    }

}

