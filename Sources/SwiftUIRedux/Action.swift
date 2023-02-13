public protocol Action: CustomStringConvertible, Codable, Sendable {}

public extension Action {
    var description: String {
        "\(type(of: self))"
    }
}

public struct SwiftUIReduxInit: Action {}
