import SwiftUIRedux

enum Main {
    struct State: SubState {
        var observed = ObservedState()
    }

    struct ObservedState: Equatable, Sendable, Codable {
        var name: String = "Andy"
    }

    enum Action: SwiftUIRedux.Action, SideEffect {
        case setName(to: String)
        case sideEffectAction(with: String)
        case thirdEffectAction(with: String)
        case test

        func sideEffect<State>(dispatch: @escaping DispatchAsyncFunction, state: State) async {
            guard let state = state as? AppState else { return }
            print("🍀 state", self, state.main.state.observed.name)
            switch self {
            case .setName:
                guard let newName = HelloWorldView.randomStrings.randomElement() else { return }
                await dispatch(Action.sideEffectAction(with: newName))
            case .sideEffectAction:

                guard let newName = HelloWorldView.randomStrings.randomElement() else { return }
                await dispatch(
                    Action.thirdEffectAction(with: newName)
                )
            case .thirdEffectAction:
                await dispatch(Action.test)
            default:
                break
            }


        }

        var debugActionName: String {
            "Main.\(type(of: self))."
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
