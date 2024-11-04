import Foundation
import ReduxMonitor
import SwiftUIRedux

public struct AppState: State {
    init(main: Main.State = .init()) {
        self.main = Observed(initState: main)
    }

    let main: Observed<Main.State>

    public var observedStates: [any ObservedProvider] { [main] }

    static func createStore(
        initState: AppState = AppState()
    ) -> Store<AppState> {
        Store(state: initState, middleware: [
            LoggerMiddleware.createMiddleware(),
            SideEffectMiddleware.createMiddleware(),
        ])
    }
}
