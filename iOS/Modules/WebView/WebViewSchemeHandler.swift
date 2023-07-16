//
//  Created by Adam Stragner
//

import Foundation
import WebKit

// MARK: - WebViewSchemeHandler

final class WebViewSchemeHandler: NSObject, WKURLSchemeHandler {
    // MARK: Lifecycle

    init(port: UInt16) {
        self.session = URLSession(configuration: .default)
        self.proxy = {
            let configuration = URLSessionConfiguration.default
            configuration.connectionProxyDictionary = [
                kCFNetworkProxiesHTTPEnable: true,
                kCFNetworkProxiesHTTPProxy: "127.0.0.1",
                kCFNetworkProxiesHTTPPort: port,
            ]

            return URLSession(configuration: configuration)
        }()

        super.init()
    }

    // MARK: Internal

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url
        else {
            return
        }

        if url.isProxyable {
            proxy(urlSchemeTask)
        } else {
            route(urlSchemeTask)
        }
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        tasks.removeValue(forKey: urlSchemeTask.request)
    }

    // MARK: Private

    private var tasks: [URLRequest: URLSessionDataTask] = [:]

    private let session: URLSession
    private let proxy: URLSession

    private func proxy(_ task: WKURLSchemeTask) {
        let id = task.request
        let task = proxy.dataTask(
            with: task.request,
            completionHandler: { [weak task, weak self] data, response, error in
                guard let self, let task
                else {
                    task?.didFailWithError(URLError(.cancelled))
                    return
                }

                handle(task: task, data: data, response: response, error: error)
            }
        )

        tasks[id] = task
        task.resume()
    }

    private func route(_ task: WKURLSchemeTask) {
        if let scheme = task.request.url?.scheme, scheme == "http" {
            task.didFailWithError(URLError(.appTransportSecurityRequiresSecureConnection))
            return
        }

        let id = task.request
        let task = session.dataTask(
            with: task.request,
            completionHandler: { [weak task, weak self] data, response, error in
                guard let self, let task
                else {
                    task?.didFailWithError(URLError(.cancelled))
                    return
                }

                handle(task: task, data: data, response: response, error: error)
            }
        )

        tasks[id] = task
        task.resume()
    }

    private func handle(task: WKURLSchemeTask, data: Data?, response: URLResponse?, error: Error?) {
        let id = task.request
        if let error = error, error._code != NSURLErrorCancelled {
            task.didFailWithError(error)
            tasks.removeValue(forKey: task.request)
        } else if tasks[id] != nil {
            if let response = response {
                task.didReceive(response)
            }
            if let data = data {
                task.didReceive(data)
            }

            task.didFinish()
            tasks.removeValue(forKey: id)
        } else {
            task.didFinish()
        }
    }
}

private extension URL {
    private static let suffixes = [".ton", ".adnl", ".t.me", ".bug"]
    var isProxyable: Bool {
        guard let host
        else {
            return false
        }

        return !URL.suffixes.filter({
            host.hasSuffix($0)
        }).isEmpty
    }
}

extension WKWebViewConfiguration {
    func use(_ handler: WebViewSchemeHandler) {
        WKWebView._schemes.forEach({
            setURLSchemeHandler(handler, forURLScheme: $0)
        })
    }
}

extension WKWebView {
    fileprivate static let _schemes = ["http"]

    /// `WKWebView` does not allow the addition of a custom` WKURLSchemeHandler` for the `HTTP` and `HTTPS` schemes.
    /// However, this workaround enables us to accomplish this task.
    static func swizzle() {
        let origin = class_getClassMethod(WKWebView.self, #selector(WKWebView.handlesURLScheme(_:)))
        let swizzled = class_getClassMethod(
            WKWebView.self,
            #selector(WKWebView.swizzled_handlesURLScheme(_:))
        )

        guard let origin, let swizzled
        else {
            return
        }

        method_exchangeImplementations(origin, swizzled)
    }

    @objc(swizzled_handlesURLScheme:)
    static func swizzled_handlesURLScheme(_ urlScheme: String) -> Bool {
        // Help to avoid fatalError when we try to add custom url scheme
        // for 'http'/'https'
        guard !WKWebView._schemes.contains(urlScheme)
        else {
            return false
        }

        return swizzled_handlesURLScheme(urlScheme)
    }
}
