public protocol Action: DebugInfo, Codable, Sendable {}

public protocol DebugInfo {
    var debugInfo: String { get }
    var debugActionName: String { get }
}

public extension Action {
    var debugActionName: String { "" }
    var debugInfo: String {
        if let item = Mirror(reflecting: self).children.first {
            return "\(debugActionName)\(item.label ?? "")\(item.value)"
        }
        return "\(debugActionName)\(self)"
    }
}
