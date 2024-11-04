import SwiftUIRedux

enum Main {
    struct State: SubState {
        var observed = ObservedState()
    }

    struct ObservedState: Equatable, Sendable, Codable {
        var name: String = "Andy"
    }

    enum Action: SwiftUIRedux.Action, SideEffect, CustomStringConvertible {
        case setName(to: String)
        case sideEffectAction(with: String)
        case thirdEffectAction(with: String)

        var desc: String { "Main.\(type(of: self))" }
        var description: String {
            switch self {
            case let .setName(name):
                "\(desc).setName(to: \(name)"
            case let .sideEffectAction(with: name):
                "\(desc).sideEffectAction(with: \(name))"
            case let .thirdEffectAction(with: name):
                "\(desc).thirdEffectAction(with: \(name))"
            }
        }

        func sideEffect(dispatch: @escaping DispatchFunction, state _: AppState) async {
            switch self {
            case .setName:
                await dispatch(Action.sideEffectAction(with: "test"))
            case .sideEffectAction:
                await dispatch(Action.thirdEffectAction(with: "complete"))
            default:
                break
            }
        }
    }
}

extension Main.State {
    static func reducer(action: SwiftUIRedux.Action, state: Main.State) -> Main.State {
        var state = state
        switch action as? Main.Action {
        case let .setName(name):
            state.observed.name = name
        case let .sideEffectAction(with: name):
            state.observed.name = name
        case let .thirdEffectAction(with: name):
            state.observed.name = name
        default:
            break
        }
        return state
    }
}
