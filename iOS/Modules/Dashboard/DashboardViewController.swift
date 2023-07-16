//
//  Created by Adam Stragner
//

import Combine
import UIKit

// MARK: - DashboardViewController

final class DashboardViewController: UIViewController {
    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()

        actionButton.configuration = {
            var configuration = UIButton.Configuration.filled()
            configuration.cornerStyle = .large
            configuration.baseForegroundColor = .systemBackground
            return configuration
        }()

        sampleButton.configuration = {
            var configuration = UIButton.Configuration.plain()
            configuration.baseForegroundColor = .label
            return configuration
        }()

        let manager = NetworkManager.shared
        manager.publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                self?.synchronize(with: state)
            })
            .store(in: &cancellables)

        sampleButton.setTitle("foundation.ton", for: .normal)
        synchronize(with: .loading)
    }

    // MARK: Private

    @IBOutlet
    private weak var actionButton: UIButton!

    @IBOutlet
    private weak var sampleButton: UIButton!

    private var cancellables: Set<AnyCancellable> = .init()
    private var state: NetworkManager.State = .loading

    private func synchronize(with state: NetworkManager.State) {
        actionButton.isEnabled = state.isChangable
        actionButton.setTitle(state.description, for: .normal)
        self.state = state
    }

    @IBAction
    private func actionButtonDidClick(_ sender: UIButton) {
        let manager = NetworkManager.shared
        switch state {
        case .uninstalled:
            manager.install()
        case .idle:
            manager.connect()
        case .connected:
            manager.disconnect()
        case .connecting, .disconnecting, .loading:
            break
        }
    }

    @IBAction
    private func sampleButtonDidClick(_ sender: UIButton) {
        let viewController = WebViewController()
        present(viewController, animated: true)
    }
}

private extension NetworkManager.State {
    var isChangable: Bool {
        switch self {
        case .connecting, .disconnecting, .loading:
            return false
        case .connected, .idle, .uninstalled:
            return true
        }
    }

    var description: String {
        switch self {
        case .loading:
            return "Loading.."
        case .uninstalled:
            return "Install"
        case .idle:
            return "Connect"
        case .connected:
            return "Disconnect"
        case .connecting:
            return "Connecting.."
        case .disconnecting:
            return "Disconnecting.."
        }
    }
}
