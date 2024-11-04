import Foundation
import ReduxMonitor
import SwiftUIRedux

@MainActor public struct AppState: ReduxState {
    init(
        main: Main.State = .init()
    ) {
        self.main = Observed(initialState: main)
    }

    let main: Observed<Main.State>

    public var observedStates: [any ObservedStateProvider] {
        [
            main
        ]
    }

    static func createStore(
        initState: AppState = AppState()
    ) -> Store<AppState> {
        Store<AppState>(state: initState, middleware: [
            LoggerMiddleware.createMiddleware(),
            SideEffectMiddleware.createMiddleware()
        ])
    }
}
