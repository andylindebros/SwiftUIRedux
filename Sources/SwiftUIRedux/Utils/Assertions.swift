import Foundation

func raiseFatalError(_ message: @autoclosure () -> String = "",
                     file: StaticString = #file, line: UInt = #line) -> Never
{
    Assertions.fatalErrorClosure(message(), file, line)
    repeat {
        RunLoop.current.run()
    } while true
}

/// Stores custom assertions closures, by default it points to Swift functions. But test target can
/// override them.
enum Assertions {
    static var fatalErrorClosure = swiftFatalErrorClosure
    static let swiftFatalErrorClosure: (String, StaticString, UInt) -> Void
        = { Swift.fatalError($0, file: $1, line: $2) }
}
