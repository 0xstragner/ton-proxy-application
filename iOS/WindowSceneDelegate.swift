//
//  Created by Adam Stragner
//

import UIKit

// MARK: - WindowSceneDelegate

final class WindowSceneDelegate: UIResponder {
    var window: UIWindow?
}

// MARK: UIWindowSceneDelegate

extension WindowSceneDelegate: UIWindowSceneDelegate {
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = scene as? UIWindowScene
        else {
            return
        }

        let window = UIWindow(windowScene: scene)
        window.rootViewController = DashboardViewController()
        window.overrideUserInterfaceStyle = .dark
        window.makeKeyAndVisible()

        self.window = window
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Await installation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            NetworkManager.shared.update()
        })
    }
}
