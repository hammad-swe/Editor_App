//
//  SceneDelegate.swift
//  Editor_App
//
//  Created by Hammad Ali on 17/08/2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
               let window =  UIWindow(windowScene: windowScene)
               let splashVC = SplashViewController(nibName: "SplashViewController", bundle: nil)
               let navController = UINavigationController(rootViewController: splashVC)
               
               window.rootViewController = navController
                     window.makeKeyAndVisible()
                     self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
       
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
      
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
       
    }


}

