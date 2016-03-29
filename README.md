# Signals

## Overview
Generic Cross Platform Signal Handler.

## Prerequisites

### Swift
* Swift Open Source `swift-DEVELOPMENT-SNAPSHOT-2016-03-24-a` toolchain or higher (**REQUIRED for latest release**)

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

The first think you need to do is import the Signals framework.  This is done by the following:
```
import Signals
```

### Provided APIs

Signals provides two class level APIs.  One is used for trapping and handling operating system signals.  The other function allows for the raising of a signal.

#### Trapping a signal

The example below shows how to add a trap handler to a server in order to perfrorm and orderly shutdown in the event that user press `^C` which sends the process a `SIGINT`.
```
import Signals

...

let server: SomeServer = ...

Signals.trap(signal: .INT) { signal in

	server.shutdownServer()
}

server.run()
```

#### Raising a signal

This example illustrates how to use Signals to raise a signal with the OS, in this case `SIGABRT`.
```
import Signals

...

Signals.raise(signal: .ABRT)
```

#### Adding a USER-DEFINED signal

This example shows how to add a user defined signal, add a trap handler for it and then raise the signal.
```
import Signals

let mySignal = Signals.Signal.USER(Int32(20))

Signals.trap(signal: mySignal) { signal in

	print("Recieved signal \(signal)")
}

Signals.raise(signal: mySignal)

```
The output of the above snippet is:
```
Received signal 20
```
