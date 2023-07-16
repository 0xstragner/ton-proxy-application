//
//  Created by Adam Stragner
//

import Combine
import Foundation
import NetworkExtension

// MARK: - NetworkManager

final class NetworkManager {
    // MARK: Lifecycle

    private init() {
        self._observation = NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                guard let connection = notification.object as? NEVPNConnection
                else {
                    return
                }

                self?._handle(connection.status)
            }
        )

        update()
    }

    // MARK: Internal

    static let shared = NetworkManager()

    var publisher: AnyPublisher<State, Never> {
        _state.eraseToAnyPublisher()
    }

    func update() {
        _run({
            try await self._load()
        })
    }

    func install() {
        _run({
            let manager: NETunnelProviderManager = .ton()
            try await manager.saveToPreferences()
            return .uninstalled
        })
    }

    func connect() {
        _run({
            guard let current = try await self._current()
            else {
                return .uninstalled
            }

            switch current.connection.status {
            case .connected:
                return .connected
            case .connecting:
                return .connecting
            default:
                self._wating = true
                try current.connection.startVPNTunnel()
                return .connecting
            }
        })
    }

    func disconnect() {
        _run({
            guard let current = try await self._current()
            else {
                return .uninstalled
            }

            switch current.connection.status {
            case .disconnected:
                return .disconnecting
            case .disconnecting:
                return .disconnecting
            default:
                self._wating = true
                current.connection.stopVPNTunnel()
                return .disconnecting
            }
        })
    }

    // MARK: Private

    private let _state = CurrentValueSubject<State, Never>(.loading)
    private var _task: Task<Void, Never>?
    private let _vpn = NEVPNManager.shared()
    private var _observation: NSObjectProtocol?
    private var _wating: Bool = false

    private func _run(_ body: @escaping () async throws -> State) {
        guard _task == nil
        else {
            return
        }

        let state = _state.value
        _state.send(.loading)

        _task = .detached(operation: {
            do {
                let state = try await body()
                self._state.send(state)
            } catch {
                self._state.send(state)
                print("\(error)")
            }

            self._task = nil
        })
    }

    private func _load() async throws -> State {
        if let manager = try await _current() {
            print("[NetworkManager]: Did load current manager - \(manager)")
            switch manager.connection.status {
            case .connected:
                return .connected
            case .connecting:
                return .connecting
            case .disconnected:
                return .idle
            case .disconnecting:
                return .disconnecting
            case .invalid, .reasserting:
                return .uninstalled
            @unknown default:
                return .uninstalled
            }
        } else {
            return .uninstalled
        }
    }

    private func _current() async throws -> NETunnelProviderManager? {
        try await NETunnelProviderManager.loadAllFromPreferences().filter({
            if let providerProtocol = $0.protocolConfiguration as? NETunnelProviderProtocol,
               providerProtocol.providerBundleIdentifier == .providerBundleIdentifier
            {
                return true
            } else {
                return false
            }
        }).first
    }

    private func _handle(_ status: NEVPNStatus) {
        guard _wating
        else {
            return
        }

        switch status {
        case .connected:
            _wating = false
            _state.send(.connected)
        case .disconnected:
            _wating = false
            _state.send(.idle)
        default:
            break
        }
    }
}

// MARK: NetworkManager.State

extension NetworkManager {
    enum State {
        case loading

        case uninstalled
        case idle

        case connected

        case connecting
        case disconnecting
    }
}

private extension NETunnelProviderManager {
    static func ton() -> NETunnelProviderManager {
        let provider = NETunnelProviderProtocol()
        provider.providerBundleIdentifier = .providerBundleIdentifier
        provider.serverAddress = "ADNL"
        provider.includeAllNetworks = false
        provider.disconnectOnSleep = true

        if #available(iOS 14.2, *) {
            provider.excludeLocalNetworks = true
        }

        if #available(iOS 16.4, *) {
            provider.excludeCellularServices = false
            provider.excludeAPNs = true
        }

        let manager = NETunnelProviderManager()
        manager.localizedDescription = "The Open Network"
        manager.protocolConfiguration = provider
        manager.isOnDemandEnabled = false

        return manager
    }
}

private extension String {
    #if DEBUG
    static let providerBundleIdentifier = "com.stragner.tonproxy.debug.network-extension"
    #else
    static let providerBundleIdentifier = "com.stragner.tonproxy.network-extension"
    #endif
}
