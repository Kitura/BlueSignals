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
    public func on(signal: Signals.Signal, perform handler: @escaping (Signals.Signal)->Void) -> SignalWatchHandler {

        return self.queue.sync {
            let signalWatchHandler = SignalWatchHandler(id: self.getNextSignalId(), signal: signal, handler: handler)

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
        return self.queue.sync {
            guard let signalWatchHandlerList = self.signalsWatched[signal.rawValue] else { return }

            for signalHandler in signalWatchHandlerList {
                signalHandler.handler(signal)
            }
        }
    }

    private func getNextSignalId() -> Int {
        let currentSignalId = self.currentSignalId
        self.currentSignalId += 1
        return currentSignalId
    }

}

public struct SignalWatchHandler: Identifiable {
    public let id: Int
    let signal: Signals.Signal
    let handler: (Signals.Signal) -> Void
}
