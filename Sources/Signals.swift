//
//  Signals.swift
//  ETSocket
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
	import Foundation
	import Glibc
#endif

public class Signals {
	
	public enum Signal: Int32 {
		case HUP    = 1
		case INT    = 2
		case QUIT   = 3
		case ABRT   = 6
		case KILL   = 9
		case ALRM   = 14
		case TERM   = 15
	}
	
	#if os(Linux)
	
	public typealias SigActionHandler = @convention(c)(Int32) -> Void
	
	public class func trap(signal: Signal, action: SigActionHandler) {
	
		var sigAction = sigaction()
	
		sigAction.__sigaction_handler = unsafeBitCast(action, to: sigaction.__Unnamed_union___sigaction_handler.self)
	
		sigaction(signal.rawValue, &sigAction, nil)
	}
	
	#else
	
	public class func trap(signal: Signal, action: @convention(c) Int32 -> ()) {
		
		typealias SignalAction = sigaction
		
		var signalAction = SignalAction(__sigaction_u: unsafeBitCast(action, to: __sigaction_u.self), sa_mask: 0, sa_flags: 0)
		
		withUnsafePointer(&signalAction) { actionPointer in
			sigaction(signal.rawValue, actionPointer, nil)
		}
	}
	
	#endif
	
	
}
