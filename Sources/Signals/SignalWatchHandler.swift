//
//  SignalWatchHandler.swift
//  
//
//  Created by Danny Sung on 05/14/2022.
//

import Foundation

public struct SignalWatchHandler: Identifiable {
    public let id: Int
    public let signal: Signals.Signal
    let userInfo: Any

    enum HandlerType {
        case noUserInfo((SignalWatchHandler) -> Void)
        case userInfo((SignalWatchHandler, Any) -> Void)
    }
    let handler: HandlerType

    internal func callHandler() {
        switch self.handler {
        case .noUserInfo(let handler):
            handler(self)
        case .userInfo(let handler):
            handler(self, self.userInfo)
        }
    }
}
