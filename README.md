# Signals

## Overview
Generic Cross Platform Signal Handler.

## Prerequisites

### Swift
* Swift Open Source `swift-DEVELOPMENT-SNAPSHOT-2016-04-12-a` toolchain or higher (**REQUIRED for latest release**)

### OS X

* OS X 10.11.0 (*El Capitan*) or higher
* Xcode Version 7.3 (7D175) or higher using the above toolchain (*Recommended*)

### Linux

* Ubuntu 15.10 (or 14.04 but only tested on 15.10)
* Swift Open Source toolchain listed above

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

Signals.trap(signal: .INT) { signal in

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

Signals.raise(signal: .ABRT)
```

#### Adding a USER-DEFINED signal

This example shows how to add a user defined signal, add a trap handler for it and then raise the signal.
```swift
import Signals

let mySignal = Signals.Signal.USER(20)

Signals.trap(signal: mySignal) { signal in

	print("Received signal \(signal)")
}

Signals.raise(signal: mySignal)

```
The output of the above snippet is:
```
Received signal 20
```
