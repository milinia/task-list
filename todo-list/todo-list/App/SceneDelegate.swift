//
//  SceneDelegate.swift
//  todo-list
//
//  Created by Evelina on 19.11.2024.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowsScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowsScene)
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        let todoListViewController = TaskListRouter.build(navigationController: navigationController)
        navigationController.viewControllers = [todoListViewController]
        self.window = window
        window.overrideUserInterfaceStyle = .dark
        window.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
