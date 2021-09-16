public typealias Reducer<ReducerStateType> =
    (_ action: Action, _ state: ReducerStateType?) -> ReducerStateType
