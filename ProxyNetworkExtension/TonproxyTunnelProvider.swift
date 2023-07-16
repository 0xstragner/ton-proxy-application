//
//  Created by Adam Stragner
//

import NetworkExtension
import TonutilsProxy

@objc(TonproxyTunnelProvider)
public final class TonproxyTunnelProvider: NEPacketTunnelProvider {
    // MARK: Public

    public override func startTunnel(options: [String: NSObject]? = nil) async throws {
        let tunnel = TonutilsProxy.shared
        let parameters = try await tunnel.start(9090)

        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: parameters.host)

        settings.mtu = NSNumber(value: 1500)
        settings.ipv4Settings = NEIPv4Settings(
            addresses: ["127.0.0.1"],
            subnetMasks: ["255.255.255.255"]
        )

        settings.proxySettings = {
            let value = NEProxySettings()
            value.httpEnabled = true
            value.httpServer = NEProxyServer(address: parameters.host, port: Int(parameters.port))
            value.httpsEnabled = false
            value.excludeSimpleHostnames = false
            value.matchDomains = ["*.ton", "*.adnl", "*.t.me", "*.bug"]
            value.autoProxyConfigurationEnabled = true
            return value
        }()

        do {
            try await setTunnelNetworkSettings(settings)
        } catch {
            await _stop()
            throw TonproxyTunnelError.unableUpdateNetworkSettings(underlyingError: error)
        }
    }

    public override func stopTunnel(with reason: NEProviderStopReason) async {
        await _stop()
    }

    public override func handleAppMessage(_ messageData: Data) async -> Data? {
        if let string = String(data: messageData, encoding: .utf8) {
            print("[TonproxyTunnelProvider]: Did handle a message - \(string)")
        }

        return nil
    }

    // MARK: Private

    private func _stop() async {
        let tunnel = TonutilsProxy.shared
        do {
            try await tunnel.stop()
        } catch {
            print("\(error)")
        }
    }
}
