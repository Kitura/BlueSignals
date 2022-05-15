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
#elseif os(Linux)
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
		case abrt
		case kill
		case alrm
		case term
		case pipe
		case user(Int)

        @available(*, renamed: "rawValue")
        public var valueOf: Int32 {
            return self.rawValue
        }

		///
		/// Obtain the OS dependent value of a Signal
		///
		public var rawValue: Int32 {
			
			switch self {
			case .hup:
				return Int32(SIGHUP)
			case .int:
				return Int32(SIGINT)
			case .quit:
				return Int32(SIGQUIT)
			case .abrt:
				return Int32(SIGABRT)
			case .kill:
				return Int32(SIGKILL)
			case .alrm:
				return Int32(SIGALRM)
			case .term:
				return Int32(SIGTERM)
			case .pipe:
				return Int32(SIGPIPE)
			case .user(let sig):
				return Int32(sig)
				
			}
		}

        init(rawValue: Int32) {
            self.init(rawValue: Int(rawValue))
        }

        init(rawValue: Int) {
            switch rawValue {
            case Int(SIGHUP): self = .hup
            case Int(SIGINT): self = .int
            case Int(SIGQUIT): self = .quit
            case Int(SIGABRT): self = .abrt
            case Int(SIGKILL): self = .kill
            case Int(SIGALRM): self = .alrm
            case Int(SIGTERM): self = .term
            case Int(SIGPIPE): self = .pipe

            default:
                self = .user(rawValue)
            }
        }
	}
	

	// MARK: Typealiases
	
	///
	/// Action handler signature.
	///
	public typealias SigActionHandler = @convention(c)(Int32) -> Void


	// MARK: Class Methods
	
	///
	/// Trap an operating system signal.
	///
	/// - Parameters:
	///		- signal:	The signal to catch.
	///		- action:	The action handler.
	///
	public class func trap(signal: Signal, action: @escaping SigActionHandler) {
	
		#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

			var signalAction = sigaction(__sigaction_u: unsafeBitCast(action, to: __sigaction_u.self), sa_mask: 0, sa_flags: 0)
		
			_ = withUnsafePointer(to: &signalAction) { actionPointer in
				
				sigaction(signal.valueOf, actionPointer, nil)
			}
		
		#elseif os(Linux)
	
			var sigAction = sigaction()
	
			sigAction.__sigaction_handler = unsafeBitCast(action, to: sigaction.__Unnamed_union___sigaction_handler.self)
	
			_ = sigaction(signal.valueOf, &sigAction, nil)
	
		#endif
	}
	
	///
	/// Trap multiple signals to individual handlers
	///
	/// - Parameter signals:	An array of tuples each containing a signal and signal handler.
	///
	public class func trap(signals: [(signal: Signal, action: SigActionHandler)]) {
	
		for sighandler in signals {
			
			Signals.trap(signal: sighandler.signal, action: sighandler.action)
		}
	}
	
	///
	/// Trap multiple signals to a single handler
	///
	/// - Parameters:
	///		- signals:	An array of signals to catch.
	///		- action:	The action handler that will handle these signals.
	///
	public class func trap(signals: [Signal], action: @escaping SigActionHandler) {
		
		for signal in signals {
			
			Signals.trap(signal: signal, action: action)
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
		
		#elseif os(Linux)
		
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
			
		#elseif os(Linux)
			
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
			
		#elseif os(Linux)
			
			_ = Glibc.signal(signal.valueOf, SIG_DFL)
			
		#endif
	}
	
}
