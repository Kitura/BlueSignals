//
//  SignalWatch.swift
//  
//
//  Created by Danny Sung on 05/14/2022.
//

import Foundation

/// ``SignalWatch`` provides an interface around ``Signals`` that allows for multiple handlers to be registered for any given signal.
public class SignalWatch {
    public static let shared = SignalWatch()

    typealias SignalNumber = Int32
    private var signalsWatched: [SignalNumber:[SignalWatchHandler]]
    private let queue: DispatchQueue
    private var currentSignalId = 0

    init() {
        self.signalsWatched = [:]
        self.queue = DispatchQueue(label: "SignalWatch Internal")
    }

    /// Add a handler for a signal
    /// - Parameters:
    ///   - signal: Signal to watch
    ///   - handler: Closure to call when the signal is recieved
    /// - Returns: A handle that can be used to remove the watcher
    @discardableResult
    public func on(signal: Signals.Signal, perform handler: @escaping (SignalWatchHandler)->Void) -> SignalWatchHandler {

        let signalWatchHandler = SignalWatchHandler(id: self.getNextSignalHandlerId(), signal: signal, userInfo: Void.self, handler: .noUserInfo(handler))

        return self.addHandler(signal: signal, signalWatchHandler: signalWatchHandler)
    }

    /// Add a handler for a signal
    /// - Parameters:
    ///   - signal: Signal to watch
    ///   - handler: Closure to call when the signal is recieved
    ///   - userInfo: Additional data that will be passed to the handler
    /// - Returns: A handle that can be used to remove the watcher
    @discardableResult
    public func on(signal: Signals.Signal, perform handler: @escaping (SignalWatchHandler, Any)->Void, userInfo: Any) -> SignalWatchHandler {

        let signalWatchHandler = SignalWatchHandler(id: self.getNextSignalHandlerId(), signal: signal, userInfo: userInfo, handler: .userInfo(handler))

        return self.addHandler(signal: signal, signalWatchHandler: signalWatchHandler)
    }

    /// Remove the a signal handler
    /// - Parameter handler: ``SignalWatchHandler`` to remove
    public func remove(handler: SignalWatchHandler) {
        self.queue.sync {
            guard var handlerList = self.signalsWatched[handler.signal.rawValue] else { return }

            handlerList = handlerList.filter({ $0.id != handler.id })
            if handlerList.isEmpty {
                Signals.restore(signal: handler.signal)
                self.signalsWatched.removeValue(forKey: handler.signal.rawValue)
            } else {
                self.signalsWatched[handler.signal.rawValue] = handlerList
            }
        }
    }

    // MARK: - Private methods

    private func addHandler(signal: Signals.Signal, signalWatchHandler: SignalWatchHandler) -> SignalWatchHandler {
        return self.queue.sync {

            var handlerList = self.signalsWatched[signal.rawValue] ?? []
            handlerList.append(signalWatchHandler)

            self.signalsWatched[signal.rawValue] = handlerList

            Signals.trap(signal: signal) { signalValue in
                let signal = Signals.Signal(rawValue: signalValue)
                SignalWatch.shared.didRecieve(signal: signal)
            }

            return signalWatchHandler
        }

    }


    private func didRecieve(signal: Signals.Signal) {
        return self.queue.async {
            guard let signalWatchHandlerList = self.signalsWatched[signal.rawValue] else { return }

            for signalHandler in signalWatchHandlerList {
                signalHandler.callHandler()
            }
        }
    }

    private func getNextSignalHandlerId() -> Int {
        let currentSignalId = self.currentSignalId
        self.currentSignalId += 1
        return currentSignalId
    }
}
