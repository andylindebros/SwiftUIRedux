public typealias Reducer<ReducerStateType> =
    @MainActor(_ action: Action, _ state: ReducerStateType) -> ReducerStateType
