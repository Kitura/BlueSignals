//
//  SignalWatch.swift
//  
//
//  Created by Danny Sung on 05/14/2022.
//

import Foundation

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

    @discardableResult
    public func on(signal: Signals.Signal, perform handler: @escaping (SignalWatchHandler)->Void) -> SignalWatchHandler {

        let signalWatchHandler = SignalWatchHandler(id: self.getNextSignalId(), signal: signal, userInfo: Void.self, handler: .noUserInfo(handler))

        return self.addHandler(signal: signal, signalWatchHandler: signalWatchHandler)
    }

    @discardableResult
    public func on(signal: Signals.Signal, perform handler: @escaping (SignalWatchHandler, Any)->Void, userInfo: Any) -> SignalWatchHandler {

        let signalWatchHandler = SignalWatchHandler(id: self.getNextSignalId(), signal: signal, userInfo: userInfo, handler: .userInfo(handler))

        return self.addHandler(signal: signal, signalWatchHandler: signalWatchHandler)
    }

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

    private func addHandler(signal: Signals.Signal, signalWatchHandler: SignalWatchHandler) -> SignalWatchHandler {
        return self.queue.sync {

            var handlerList = self.signalsWatched[signal.valueOf] ?? []
            handlerList.append(signalWatchHandler)

            self.signalsWatched[signal.valueOf] = handlerList

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

    private func getNextSignalId() -> Int {
        let currentSignalId = self.currentSignalId
        self.currentSignalId += 1
        return currentSignalId
    }
}
