//
//  Created by Adam Stragner
//

import TonutilsProxy
import UIKit
import WebKit

class WebViewController: UIViewController {
    // MARK: Lifecycle

    deinit {
        Task.detached(operation: {
            try? await TonutilsProxy.shared.stop()
        })
    }

    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        let port = UInt16(1234)
        Task.detached(operation: { @MainActor [weak self] in
            let _ = try? await TonutilsProxy.shared.start(port)
            self?.load(with: port)
        })
    }

    // MARK: Private

    private func load(with port: UInt16) {
        guard let url = URL(string: "http://foundation.ton")
        else {
            return
        }

        let configuration = WKWebViewConfiguration()
        configuration.use(.init(port: port))

        let webView = WKWebView(frame: view.bounds, configuration: configuration)
        view.addSubview(webView)

        let request = URLRequest(url: url)
        webView.load(request)
    }
}
