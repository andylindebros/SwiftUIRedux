import Combine
import Foundation

@MainActor public final class Store<S: State> {
    public private(set) var state: S

    public private(set) lazy var dispatch: DispatchFunction = middleware
        .reversed()
        .reduce(
            { [weak self] action in
                await self?._defaultDispatch(action: action) },

            { dispatchFunction, middleware in
                middleware(_dispatch, state)(dispatchFunction)
            }
        )

    public var middleware: [Middleware<S>]

    public init(
        state: S,
        middleware: [Middleware<S>] = []
    ) {
        self.middleware = middleware
        self.state = state

        // dispatchFunction = createDispatchFunction()
    }

    func reducer(action: Action) async {
        for state in state.observedStates.compactMap { $0 as? any ReducerProvider } {
            await state.reducer(action: action)
        }
    }

    private func createDispatchFunction() -> DispatchFunction {
        middleware
            .reversed()
            .reduce(
                { [weak self] action in
                    await self?._defaultDispatch(action: action) },

                { dispatchFunction, middleware in
                    middleware(dispatch, state)(dispatchFunction)
                }
            )
    }

    // swiftlint:disable:next identifier_name
    private func _defaultDispatch(action: Action) async {
        await reducer(action: action)
    }

    private func _dispatch(_ action: Action) async {
        await dispatch(action)
    }
}

@MainActor public protocol State: Sendable {
    var observedStates: [any ObservedProvider] { get }
}

public protocol ObservedProvider {}
