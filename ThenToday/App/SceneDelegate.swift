//
//  SceneDelegate.swift
//  ThenToday
//
//  Created by Anton Solovev on 02.02.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }

        let dependencies = AppDependencies()
        let rootViewController: UIViewController = dependencies.makeDatePickerViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        window = .init(windowScene: scene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
