import Foundation
import SwiftUIRedux

protocol SideEffect: Action {
    func sideEffect(dispatch: @escaping DispatchFunction, state: AppState) async -> Void
}

extension SideEffect {
    func sideEffect(dispatch _: @escaping DispatchFunction, state _: AppState) async {}
}

/// NOTE! This middleware provides sideEffect functions for the actions to extend. Don't add any side effects here

enum SideEffectMiddleware {
    static func createMiddleware() -> Middleware<AppState> {
        { dispatch, state in
            { next in
                { action in
                    // let nextAction: Void = next(action)
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
