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
	public enum Signal: Int32 {
		case HUP    = 1
		case INT    = 2
		case QUIT   = 3
		case ABRT   = 6
		case KILL   = 9
		case ALRM   = 14
		case TERM   = 15
	}
	

	// MARK: Typealiases
	
	///
	/// Action handler signature.
	///
	public typealias SigActionHandler = @convention(c)(Int32) -> Void


	// MARK: Class Methods
	
	///
	/// Trap - catch an operating system signal.
	///
	/// - Parameters:
	///		- signal:	The signal to catch.
	///		- action:	The action handler.
	///
	public class func trap(signal signal: Signal, action: SigActionHandler) {
	
		#if os(OSX) || os(iOS) || os(tvOS) || os(watchOS)

			var signalAction = sigaction(__sigaction_u: unsafeBitCast(action, to: __sigaction_u.self), sa_mask: 0, sa_flags: 0)
		
			withUnsafePointer(&signalAction) { actionPointer in
				
				Darwin.sigaction(signal.rawValue, actionPointer, nil)
			}
		
		#elseif os(Linux)
	
			var sigAction = sigaction()
	
			sigAction.__sigaction_handler = unsafeBitCast(action, to: sigaction.__Unnamed_union___sigaction_handler.self)
	
			Glibc.sigaction(signal.rawValue, &sigAction, nil)
	
		#endif
	}
	
	///
	/// Raise - raise a signal
	///
	/// - Parameter signal:	The signal to raise.
	///
	public class func raise(signal signal: Signal) {
		
		#if os(OSX) || os(iOS) || os(tvOS) || os(watchOS)
		
			Darwin.raise(signal.rawValue)
		
		#elseif os(Linux)
		
			Glibc.raise(signal.rawValue)
		
		#endif
	}
}
