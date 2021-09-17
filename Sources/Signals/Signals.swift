//
//  Signals.swift
//  BlueSignals
//
//  Created by Bill Abt on 3/29/16.
//  Copyright © 2016 IBM. All rights reserved.
//
// 	Licensed under the Apache License, Version 2.0 (the "License");
// 	you may not use this file except in compliance with the License.
// 	You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// 	Unless required by applicable law or agreed to in writing, software
// 	distributed under the License is distributed on an "AS IS" BASIS,
// 	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// 	See the License for the specific language governing permissions and
// 	limitations under the License.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Darwin
#elseif os(Linux) || os(Android)
import Glibc
#endif

import Foundation

// MARK: Signals

public class Signals {

    // MARK: Enums

    ///
    /// Common OS Signals
    ///
    public enum Signal {
        case hup
        case int
        case quit
        case ill
        case trap
        case abrt
        case kill
        case pipe
        case alrm
        case term
        case user(Int)

        ///
        /// Obtain the OS dependent value of a Signal
        ///
        public var valueOf: CInt {

            switch self {
            case .hup:
                return CInt(SIGHUP)
            case .int:
                return CInt(SIGINT)
            case .quit:
                return CInt(SIGQUIT)
            case .ill:
                return CInt(SIGILL)
            case .trap:
                 return CInt(SIGTRAP)
            case .abrt:
                return CInt(SIGABRT)
            case .kill:
                return CInt(SIGKILL)
            case .pipe:
                return CInt(SIGPIPE)
            case .alrm:
                return CInt(SIGALRM)
            case .term:
                return CInt(SIGTERM)
            case .user(let sig):
                return CInt(sig)

            }
        }
    }


    // MARK: Typealiases

    ///
    /// Action handler signature.
    ///
    public typealias SigActionHandler = @convention(c) (CInt) -> Void


    // MARK: Class Methods

    ///
    /// Trap an operating system signal.
    ///
    /// - Parameters:
    ///		- signal:	The signal to catch.
    ///		- action:	The action handler.
    ///
    public class func trap(signal: Signal, mask: sigset_t = sigset_t(), flags: CInt = 0, action: @escaping SigActionHandler) {

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

        var signalAction = sigaction(
                __sigaction_u: __sigaction_u(__sa_handler: action),
                sa_mask: mask,
                sa_flags: flags
        )

        #elseif os(Linux)

        var signalAction = sigaction(
                __sigaction_handler: unsafeBitCast(action, to: sigaction.__Unnamed_union___sigaction_handler.self),
                sa_flags: flags,
                sa_mask: mask,
                sa_restorer: nil
        )

        #elseif os(Android)

        var signalAction = sigaction(
                sa_flags: flags,
                .init(sa_handler: action),
                sa_mask: mask,
                sa_restorer: nil)

        #endif

        _ = withUnsafePointer(to: &signalAction) { actionPointer in

            sigaction(signal.valueOf, actionPointer, nil)
        }
    }

    ///
    /// Trap multiple signals to individual handlers
    ///
    /// - Parameter signals:	An array of tuples each containing a signal and signal handler.
    ///
    public class func trap(signals: [(signal: Signal, action: SigActionHandler, mask: sigset_t, flags: CInt)]) {

        for item in signals {

            Signals.trap(signal: item.signal, mask: item.mask, flags: item.flags, action: item.action)
        }
    }

    ///
    /// Trap multiple signals to a single handler
    ///
    /// - Parameters:
    ///		- signals:	An array of signals to catch.
    ///		- action:	The action handler that will handle these signals.
    ///
    public class func trap(signals: [Signal], mask: sigset_t = sigset_t(), flags: CInt = 0, action: @escaping SigActionHandler) {

        for signal in signals {

            Signals.trap(signal: signal, mask: mask, flags: flags, action: action)
        }
    }

    ///
    /// Raise an operating system signal
    ///
    /// - Parameter signal:	The signal to raise.
    ///
    public class func raise(signal: Signal) {

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

        _ = Darwin.raise(signal.valueOf)

        #elseif os(Linux) || os(Android)

        _ = Glibc.raise(signal.valueOf)

        #endif
    }

    ///
    /// Ignore a signal
    ///
    /// - Parameter signal:	The signal to ignore.
    ///
    public class func ignore(signal: Signal) {

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

        _ = Darwin.signal(signal.valueOf, SIG_IGN)

        #elseif os(Linux) || os(Android)

        _ = Glibc.signal(signal.valueOf, SIG_IGN)

        #endif
    }

    ///
    /// Restore default signal handling
    ///
    /// - Parameter signal:	The signal to restore.
    ///
    public class func restore(signal: Signal) {

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

        _ = Darwin.signal(signal.valueOf, SIG_DFL)

        #elseif os(Linux) || os(Android)

        _ = Glibc.signal(signal.valueOf, SIG_DFL)

        #endif
    }

}
