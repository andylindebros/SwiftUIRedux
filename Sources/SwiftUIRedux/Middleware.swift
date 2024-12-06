import Foundation

public typealias DispatchFunction = @Sendable (Action) -> Void
public typealias DispatchAsyncFunction = @MainActor @Sendable (Action) async -> Void
public typealias Middleware<S: SingleState> = (@escaping DispatchAsyncFunction, S) -> (@escaping DispatchAsyncFunction) -> DispatchAsyncFunction

public protocol SideEffect: Action {
    @MainActor func sideEffect<State: SingleState>(dispatch: @escaping DispatchAsyncFunction, state: State) async -> Void
}

public extension SideEffect {
    @MainActor func sideEffect<State: SingleState>(dispatch _: @escaping DispatchAsyncFunction, state _: State) async {}
}

public enum SideEffectMiddleware {
    @MainActor public static func createMiddleware<S: SingleState>() -> Middleware<S> {
        { dispatch, getState in
            { next in
                { action in
                    switch action {
                    case let a as any SideEffect:
                        let nextAction: Void = await next(action)
                        await a.sideEffect(dispatch: dispatch, state: getState)
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
    public static func createMiddleware<S: SingleState>() -> Middleware<S> {
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
