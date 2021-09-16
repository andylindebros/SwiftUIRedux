import Foundation

public typealias DispatchFunction = (Action) -> Void
public typealias Middleware<State> = (@escaping DispatchFunction, @escaping () -> State?)
    -> (@escaping DispatchFunction) -> DispatchFunction
