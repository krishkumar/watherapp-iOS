//
//  SceneDelegate.swift
//  weatherapp
//
//  Created by Krishna Kumar on 5/16/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coordinator: DefaultWeatherFeatureCoordinator?
    var navigationController: UINavigationController? {
        UIApplication.shared.firstConnectedWindow?.rootViewController as? UINavigationController
    }

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        let rootViewController = UIViewController()

        let navigationController = UINavigationController(rootViewController: rootViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window

        coordinator = DefaultWeatherFeatureCoordinator(navigationController: navigationController)
        coordinator?.navigateToWeather()
    }
}
