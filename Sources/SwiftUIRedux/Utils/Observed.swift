import Foundation
import SwiftUI

public final class Observed<O: SubState>: ObservableObject, Codable {
    public init(initialState: O) {
        state = initialState
    }

    @Published public private(set) var observedState: UUID = .init()
    public private(set) var state: O

    @MainActor @discardableResult fileprivate func setState(_ newState: O) -> Self {
        let testState = state.observedState
        state = newState
        if !newState.observedState.isObservedStateEqual(to: testState) {
            observedState = UUID()
        }
        return self
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        state = try values.decode(O.self, forKey: .state)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(state, forKey: .state)
    }

    public enum CodingKeys: CodingKey {
        case state
    }
}

public protocol ObservedStruct: Sendable, Equatable, Codable {
    func isObservedStateEqual(to: any ObservedStruct) -> Bool
}

public protocol SubState: Sendable, Codable {
    var observedState: any ObservedStruct { get }
}
