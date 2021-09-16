import Foundation
import ReduxMonitor
import SwiftUIRedux

class AppState: ObservableObject, Codable {
    @Published fileprivate(set) var name = "Andy"

    init() {}
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
    }

    enum CodingKeys: CodingKey {
        case name
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }

    static func reducer(action: Action, state: AppState?) -> AppState {
        let state = state ?? AppState()
        switch action {
        case let a as SomeAction:
            state.name = a.payload
#if DEBUG
        case let a as SetState:
            state.name = a.payload.name
#endif

        default:
            break
        }
        return state
    }

    static func createStore(
        initState: AppState? = nil
    ) -> Store<AppState> {
        var middlewares = [Middleware<AppState>]()
#if DEBUG
        middlewares.append(AppState.createReduxMontitorMiddleware(monitor: ReduxMonitor()))
#endif
        let store = Store<AppState>(reducer: AppState.reducer, state: initState, middleware: middlewares)

        return store
    }

#if DEBUG
    private static func createReduxMontitorMiddleware(monitor: ReduxMonitorProvider) -> Middleware<Any> {
        return { dispatch, state in
            var monitor = monitor
            monitor.connect()

            monitor.monitorAction = { monitorAction in
                let decoder = JSONDecoder()
                switch monitorAction.type {
                case let .jumpToState(_, stateDataString):

                    guard
                        let stateData = stateDataString.data(using: .utf8),
                        let newState = try? decoder.decode(AppState.self, from: stateData)
                    else {
                        return
                    }

                    dispatch(SetState(payload: newState))

                case let .action(actionString):
                    guard
                        let actionRawData = actionString.data(using: .utf8)

                    else {
                        return print("Didn't work out")
                    }
                    do {
                        dispatch(try decoder.decode(SomeAction.self, from: actionRawData))
                    } catch let e {
                        return print("It didn't work out with error", e)
                    }
                }
            }
            return { next in
                { action in
                    let newAction: Void = next(action)
                    let newState = state()
                    if let encodableState = newState as? Encodable {
                        monitor.publish(action: AnyEncodable(action), state: AnyEncodable(encodableState))
                    } else {
                        print("Could not monitor action because either state does not conform to encodable", action)
                    }
                    return newAction
                }
            }
        }
    }
#endif
}
