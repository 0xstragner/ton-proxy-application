//
//  Created by Adam Stragner
//

import Foundation

// MARK: - TonproxyTunnelError

public enum TonproxyTunnelError {
    case unableUpdateNetworkSettings(underlyingError: Error)
}

// MARK: LocalizedError

extension TonproxyTunnelError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .unableUpdateNetworkSettings(underlyingError):
            return "[TonproxyTunnelError]: Unable update network settings - \(underlyingError)"
        }
    }
}
