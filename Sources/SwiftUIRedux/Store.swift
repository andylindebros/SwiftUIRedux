import Combine
import Foundation

public protocol ObservedStateProvider {}

@MainActor public protocol ReduxState: Sendable {
    var observedStates: [any ObservedStateProvider]  { get }
}

@MainActor public final class Store<State: ReduxState> {

    public private(set) var state: State

    public private(set) var dispatchFunction: DispatchFunction?

    // private var reducer: Reducer<State>

    public var middleware: [Middleware<State>]

    public init(
        // reducer: @escaping Reducer<State>,
        state: State,
        middleware: [Middleware<State>] = []
    ) {
        // self.reducer = reducer
        self.middleware = middleware
        self.state = state

        dispatchFunction = createDispatchFunction()
    }

    func reducer(action: Action) async {
        for state in state.observedStates.compactMap { $0 as? any ReducerProvider } {
            await state.reducer(action: action)
        }
    }

    private func createDispatchFunction() -> DispatchFunction {
        // Wrap the dispatch function with all middlewares
        middleware
            .reversed()
            .reduce(
                { [weak self] action in
                    await self?._defaultDispatch(action: action) }
                ,
                { dispatchFunction, middleware in
                    middleware(dispatch, state)(dispatchFunction)
                }
            )
    }

    // swiftlint:disable:next identifier_name
    public func _defaultDispatch(action: Action) async {
        await reducer(action: action)
    }

    public func dispatch(_ action: Action) async {
        await dispatchFunction?(action)
    }
}
