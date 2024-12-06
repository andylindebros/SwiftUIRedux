import Foundation
import SwiftUI

@MainActor public final class Observed<O: SubState>: ObservedProvider, ObservableObject {
    public init(initState: O) {
        state = initState
    }

    @Published public private(set) var observedState: UUID = .init()

    public private(set) var state: O

    private func setState(_ newState: O) async {
        let oldState = state
        state = newState

        if oldState.observed != newState.observed {
            observedState = UUID()
        }
    }

    enum CodingKeys: CodingKey {
        case state
    }
}

extension Observed: ReducerProvider {
    @MainActor func reducer(action: any Action) async {
        await setState(O.reducer(action: action, state: state))
    }
}

public protocol SubState: Sendable, Equatable, Codable {
    associatedtype O: Equatable
    var observed: O { get }

    @MainActor static func reducer(action: any Action, state: Self) -> Self
}

protocol ReducerProvider {
    @MainActor func reducer(action: Action) async
}
