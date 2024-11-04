import Foundation

public typealias DispatchFunction = (Action) async -> Void
public typealias Middleware<State> = (@escaping DispatchFunction, State) -> (@escaping DispatchFunction) -> DispatchFunction
