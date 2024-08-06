import Foundation

/// An object that manages the execution of tasks atomically.
struct Synchronized<Value> {
    private let mutex = DispatchQueue(label: "swiftuiredux.github.io.Utils.Synchronized", attributes: .concurrent)
    private var _value: Value
    init(_ value: Value) {
        _value = value
    }

    /// Returns or modify the thread-safe value.
    var value: Value { return mutex.sync { _value } }
    /// Submits a block for synchronous, thread-safe execution.
    mutating func value<T>(execute task: (inout Value) throws -> T) rethrows -> T {
        return try mutex.sync(flags: .barrier) { try task(&_value) }
    }
}
