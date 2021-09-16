import Foundation

open class Store<State: Codable> {
    public private(set) var state: State!

    public lazy var dispatchFunction: DispatchFunction! = createDispatchFunction()

    private var reducer: Reducer<State>

    private var isDispatching = Synchronized<Bool>(false)

    public var middleware: [Middleware<State>] {
        didSet {
            dispatchFunction = createDispatchFunction()
        }
    }

    public required init(
        reducer: @escaping Reducer<State>,
        state: State?,
        middleware: [Middleware<State>] = []
    ) {
        self.reducer = reducer
        self.middleware = middleware

        if let state = state {
            self.state = state
        } else {
            dispatch(SwiftUIReduxInit())
        }
    }

    private func createDispatchFunction() -> DispatchFunction! {
        // Wrap the dispatch function with all middlewares
        return middleware
            .reversed()
            .reduce(
                { [unowned self] action in
                    self._defaultDispatch(action: action) },
                { dispatchFunction, middleware in
                    // If the store get's deinitialized before the middleware is complete; drop
                    // the action without dispatching.
                    let dispatch: (Action) -> Void = { [weak self] in self?.dispatch($0) }
                    let getState: () -> State? = { [weak self] in self?.state }
                    return middleware(dispatch, getState)(dispatchFunction)
                }
            )
    }

    // swiftlint:disable:next identifier_name
    open func _defaultDispatch(action: Action) {
        guard !isDispatching.value else {
            raiseFatalError(
                "Action has been dispatched while" +
                    " a previous action is being processed. A reducer" +
                    " is dispatching an action, or SwiftUIRedux is used in a concurrent context" +
                    " (e.g. from multiple threads). Action: \(action)"
            )
        }
        isDispatching.value { $0 = true }
        let newState = reducer(action, state)
        isDispatching.value { $0 = false }

        state = newState
    }

    open func dispatch(_ action: Action) {
        dispatchFunction(action)
    }

    public typealias DispatchCallback = (State) -> Void
}
