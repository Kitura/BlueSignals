import Foundation
import Signals

let reason = CommandLine.arguments.count == 2 ? CommandLine.arguments[1] : "unknown"

func A1() -> Void {
    A2()
}

func A2() -> Void {
    A3()
}

func A3() -> Void {
    B1()
}

func B1() -> Void {
    B2()
}

func B2() -> Void {
    B3()
}

func B3() -> Void {
    Van().drive()
}

class Van {
    func drive() -> Void {

        print("\n\n\n")
        print("👇👇👇")
        fatalError(reason) // raise  SIGILL  here !!!
        print("👆👆👆")
        print("\n\n\n")
    }

    func oilEmpty() throws -> Void {
        throw CarError.oilEmpty(message: "!!! oil empty !!!")
    }
}

enum CarError: Error {
    case oilEmpty(message: String)
}

Signals.trap(signal: Signals.Signal.ill) { signal in

    print("----> \(signal)")

    if (signal == SIGILL) {
        #if os(macOS)
        exit(EXIT_FAILURE)
        #endif
    }
}

A1()


