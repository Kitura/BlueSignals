//
//  Signals.swift
//  Signals
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

#if os(OSX) || os(iOS) || os(tvOS) || os(watchOS)
	import Darwin
	import Foundation
#elseif os(Linux)
	import Glibc
	import Foundation
#endif

// MARK: Signals

public class Signals {
	
	// MARK: Enums
	
	///
	/// Common OS Signals
	///
	public enum Signal {
		case HUP
		case INT
		case QUIT
		case ABRT
		case KILL
		case ALRM
		case TERM
		case USER(Int32)
		
		///
		/// Obtain the OS dependent value of a Signal
		///
		public var valueOf: Int32 {
			
			switch self {
			case HUP:
				return SIGHUP
			case INT:
				return SIGINT
			case QUIT:
				return SIGQUIT
			case ABRT:
				return SIGABRT
			case KILL:
				return SIGKILL
			case ALRM:
				return SIGALRM
			case TERM:
				return SIGTERM
			case USER(let sig):
				return sig
				
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
	public class func trap(signal signal: Signal, action: SigActionHandler) {
	
		#if os(OSX) || os(iOS) || os(tvOS) || os(watchOS)

			var signalAction = sigaction(__sigaction_u: unsafeBitCast(action, to: __sigaction_u.self), sa_mask: 0, sa_flags: 0)
		
			withUnsafePointer(&signalAction) { actionPointer in
				
				Darwin.sigaction(signal.valueOf, actionPointer, nil)
			}
		
		#elseif os(Linux)
	
			var sigAction = sigaction()
	
			sigAction.__sigaction_handler = unsafeBitCast(action, to: sigaction.__Unnamed_union___sigaction_handler.self)
	
			Glibc.sigaction(signal.valueOf, &sigAction, nil)
	
		#endif
	}
	
	///
	/// Trap multiple signals to individual handlers
	///
	/// - Parameter signals:	An array of tuples each containing a signal and signal handler.
	///
	public class func trap(signals signals: [(signal: Signal, action: SigActionHandler)]) {
	
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
	public class func trap(signals signals: [Signal], action: SigActionHandler) {
		
		for signal in signals {
			
			Signals.trap(signal: signal, action: action)
		}
	}
	
	///
	/// Raise an operating system signal
	///
	/// - Parameter signal:	The signal to raise.
	///
	public class func raise(signal signal: Signal) {
		
		#if os(OSX) || os(iOS) || os(tvOS) || os(watchOS)
		
			Darwin.raise(signal.valueOf)
		
		#elseif os(Linux)
		
			Glibc.raise(signal.valueOf)
		
		#endif
	}
}
