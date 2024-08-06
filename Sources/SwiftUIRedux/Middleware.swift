import Foundation

public typealias DispatchFunction = @MainActor (Action) -> Void
public typealias Middleware<State> = @MainActor (@escaping DispatchFunction, @MainActor @escaping () -> State?)
    -> (@escaping DispatchFunction) -> DispatchFunction
