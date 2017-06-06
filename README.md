![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![iOS](https://img.shields.io/badge/os-iOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)
![](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)

# Signals

## Overview
Generic Cross Platform Signal Handler.

## Prerequisites

### Swift

* Swift Open Source `swift-3.0.1-RELEASE` toolchain (**Minimum REQUIRED for latest release**)
* Swift Open Source `swift-3.1.1-RELEASE` toolchain (**Recommended**)
* Swift toolchain included in *Xcode Version 9.0 beta (9M136h) or higher*.

### macOS

* macOS 10.11.6 (*El Capitan*) or higher
* Xcode Version 8.3.2 (8E2002) or higher using one of the above toolchains (*Recommended*)
* Xcode Version 9.0 beta (9M136h) or higher using the included toolchain.

### iOS

* iOS 10.0 or higher
* Xcode Version 8.3.2 (8E2002) or higher using one of the above toolchains (*Recommended*)
* Xcode Version 9.0 beta (9M136h) or higher using the included toolchain.

### Linux

* Ubuntu 16.04 (or 16.10 but only tested on 16.04)
* One of the Swift Open Source toolchain listed above

## Build

To build Signals from the command line:

```
% cd <path-to-clone>
% swift build
```

## Using Signals

### Before starting

The first thing you need to do is import the Signals framework.  This is done by the following:
```
import Signals
```

### Provided APIs

Signals provides four (4) class level APIs.  Three (3) are used for trapping and handling operating system signals.  The other function allows for the raising of a signal.

#### Trapping a signal
- `trap(signal signal: Signal, action: SigActionHandler)` - This basic API allows you to set and specific handler for a specific signal.

The example below shows how to add a trap handler to a server in order to perform and orderly shutdown in the event that user press `^C` which sends the process a `SIGINT`.
```swift
import Signals

...

let server: SomeServer = ...

Signals.trap(signal: .int) { signal in

	server.shutdownServer()
}

server.run()
```
Additionally, convenience API's that build on the basic API specified above are provided that will allow for trapping multiple signals, each to a separate handler or to a single handler.
- `trap(signals signals: [(signal: Signal, action: SigActionHandler)])` - This lets you trap multiple signals to separate handlers in a single function call.
- `trap(signals signals: [Signal], action: SigActionHandler)` - This API lets you trap multiple signals to a common handler.

#### Raising a signal
- `raise(signal signal: Signal)` - This API is used to send an operating system signal to your application.

This example illustrates how to use Signals to raise a signal with the OS, in this case `SIGABRT`.
```swift
import Signals

...

Signals.raise(signal: .abrt)
```

#### Ignoring a signal
- `func ignore(signal: Signal)` - This API is used to ignore an operating system signal.

This example illustrates how to use Signals to ignore a signal with the OS, in this case `SIGPIPE`.
```swift
import Signals

...

Signals.ignore(signal: .pipe)
```

#### Restoring a signals default handler
- `func restore(signal: Signal)` - This API is used to restore an operating system signals default handler.

This example illustrates how to use Signals to restore a signals default handler, in this case `SIGPIPE`.
```swift
import Signals

...

Signals.restore(signal: .pipe)
```

#### Adding a USER-DEFINED signal

This example shows how to add a user defined signal, add a trap handler for it and then raise the signal.
```swift
import Signals

let mySignal = Signals.Signal.user(20)

Signals.trap(signal: mySignal) { signal in

	print("Received signal \(signal)")
}

Signals.raise(signal: mySignal)

```
The output of the above snippet is:
```
Received signal 20
```
