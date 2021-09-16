public protocol Action: CustomStringConvertible, Encodable {}

public extension Action {
    var description: String {
        "\(type(of: self))"
    }
}

public struct SwiftUIReduxInit: Action, Encodable {}
