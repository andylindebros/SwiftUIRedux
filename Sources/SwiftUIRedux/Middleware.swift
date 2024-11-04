import Foundation

public typealias DispatchFunction = @Sendable (Action) async -> Void
public typealias Middleware<S: State> = (@escaping DispatchFunction, S) -> (
    @escaping DispatchFunction
) -> DispatchFunction

public protocol SideEffect: Action {
    func sideEffect<State>(dispatch: @escaping DispatchFunction, state: State) async -> Void
}

public extension SideEffect {
    func sideEffect<State>(dispatch _: @escaping DispatchFunction, state _: State) async {}
}

public enum SideEffectMiddleware {
    public static func createMiddleware<S: State>() -> Middleware<S> {
        { dispatch, state in
            { next in
                { action in
                    switch action {
                    case let a as any SideEffect:
                        let nextAction: Void = await next(action)
                        await a.sideEffect(dispatch: dispatch, state: state)
                        return nextAction

                    default:
                        return await next(action)
                    }
                }
            }
        }
    }
}

public enum LoggerMiddleware {
    public static func createMiddleware<S: State>() -> Middleware<S> {
        { _, _ in
            { next in
                { action in
                    print(
                        "⚡️",
                        action.debugInfo
                    )
                    return await next(action)
                }
            }
        }
    }
}
