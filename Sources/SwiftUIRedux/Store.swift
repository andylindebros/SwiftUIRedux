import Combine
import Foundation

public final class Store<S: SingleState>: Sendable {
    public init(
        state: S,
        middleware: [Middleware<S>] = []
    ) {
        self.middleware = middleware
        self.state = state
    }

    public let state: S

    public private(set) lazy var dispatch: DispatchFunction = { action in
        Task { [weak self] in
            await self?.dispatchAsync(action)
        }
    }

    public private(set) lazy var dispatchAsync: DispatchAsyncFunction = middleware
        .reversed()
        .reduce(
            { [weak self] action in
                await self?._defaultDispatch(action: action) },

            { dispatchFunction, middleware in
                middleware(_dispatch, state)(dispatchFunction)
            }
        )

    public let middleware: [Middleware<S>]


    func reducer(action: Action) async {
        for state in await state.observedStates.compactMap { $0 as? any ReducerProvider } {
            await state.reducer(action: action)
        }
    }

    private func createDispatchFunction() -> DispatchAsyncFunction {
        middleware
            .reversed()
            .reduce(
                { [weak self] action in
                    await self?._defaultDispatch(action: action) },

                { dispatchFunction, middleware in
                    middleware(dispatchAsync, state)(dispatchFunction)
                }
            )
    }

    // swiftlint:disable:next identifier_name
    private func _defaultDispatch(action: Action) async {
        await reducer(action: action)
    }

    private func _dispatch(_ action: Action) async {
        await dispatchAsync(action)
    }
}

@MainActor public protocol SingleState: Sendable {
    var observedStates: [any ObservedProvider] { get }
}

public protocol ObservedProvider {}
