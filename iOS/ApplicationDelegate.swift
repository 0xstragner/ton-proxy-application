//
//  Created by Adam Stragner
//

import UIKit
import WebKit

// MARK: - ApplicationDelegate

final class ApplicationDelegate: UIResponder {}

// MARK: UIApplicationDelegate

extension ApplicationDelegate: UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        WKWebView.swizzle()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfiguration: UISceneConfiguration
        switch connectingSceneSession.role {
        case .windowApplication:
            sceneConfiguration = UISceneConfiguration(
                name: "Default",
                sessionRole: connectingSceneSession.role
            )

            sceneConfiguration.delegateClass = WindowSceneDelegate.self
            sceneConfiguration.sceneClass = UIWindowScene.self
        case .windowExternalDisplay:
            fatalError("[ApplicationDelegate]: External displays not supported yet.")
        default:
            fatalError("[ApplicationDelegate]: Scene role is unknown.")
        }

        return sceneConfiguration
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}
}
