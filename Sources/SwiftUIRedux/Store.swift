import Combine
import Foundation

@MainActor
public final class Store<State: Codable> {
    public private(set) var state: State

    public lazy var dispatchFunction: DispatchFunction = createDispatchFunction()

    private var reducer: Reducer<State>

    private var isDispatching = Synchronized<Bool>(false)

    public var middleware: [Middleware<State>]

    public let actionEvent = PassthroughSubject<any Action, Never>()

    private var onDispatchFailure: ((any Action) -> Void)?

    public required init(
        reducer: @escaping Reducer<State>,
        state: State,
        middleware: [Middleware<State>] = [],
        onDispatchFailure: ((any Action) -> Void)? = nil
    ) {
        self.reducer = reducer
        self.middleware = middleware
        self.state = state
        self.onDispatchFailure = onDispatchFailure
    }

    private func createDispatchFunction() -> DispatchFunction {
        // Wrap the dispatch function with all middlewares
        return middleware
            .reversed()
            .reduce(
                { @MainActor [unowned self] action in
                    self._defaultDispatch(action: action) },
                { dispatchFunction, middleware in
                    // If the store get's deinitialized before the middleware is complete; drop
                    // the action without dispatching.
                    let dispatch: DispatchFunction = { [weak self] in self?.dispatch($0) }
                    let getState: () -> State? = { [weak self] in self?.state }
                    return middleware(dispatch, getState)(dispatchFunction)
                }
            )
    }

    // swiftlint:disable:next identifier_name
    @MainActor public func _defaultDispatch(action: Action) {
        guard !isDispatching.value else {
            assertionFailure(
                "Action has been dispatched while" +
                    " a previous action is being processed. A reducer" +
                    " is dispatching an action, or SwiftUIRedux is used in a concurrent context" +
                    " (e.g. from multiple threads). Action: \(action)"
            )
            onDispatchFailure?(action)
            DispatchQueue.main.async { [weak self] in
                self?._defaultDispatch(action: action)
            }
            return
        }
        isDispatching.value { $0 = true }
        let newState = reducer(action, state)
        isDispatching.value { $0 = false }

        state = newState
        actionEvent.send(action)
    }

    public func dispatch(_ action: Action) {
        dispatchFunction(action)
    }
}
