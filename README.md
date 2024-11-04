# SwiftUIRedux
Welcome to SwiftUIRedux – a great library designed to integrate the Redux pattern into your SwiftUI projects. SwiftUIRedux enables you to manage your application state seamlessly by providing a centralized store that responds to dispatched actions. By dispatching actions, you can easily update your state and ensure a consistent data flow throughout your app. 

Explore how SwiftUIRedux simplifies state management, enhances code organization, and promotes predictable application behavior, making your SwiftUI development experience more efficient and robust!

## Installation
Install SwiftUIRedux using Swift Package Manager

```Swift
dependencies: [
    .package(url: "https://github.com/andylindebros/SwiftUIRedux", from: "1.0.0"),
]
```

## Implementation
SwiftUIRedux employs a unidirectional data flow, where the UI  subscribes to data and when is rerendered when the data changes.The UI triggers actions, and these actions facilitate state updates via reducers. This architecture promotes a clear separation of concerns, ensuring that the UI remains reactive to state changes while maintaining a predictable flow of data.

Begin with by defining a subState. You can add properties to the subState but it only changes to the observed struct that triggers changes in the UI.
```Swift
enum Main {
    struct State: SwiftUIRedux.State {
        var storage: String = "development"

        // The UI listens to changes in this property
        var observed = ObservedState()
    }

    struct ObservedState: Equatable, Sendable, Codable {
        var name: String = "Andy"
    }

    /// Actions that can be triggered by the dispatch Function
    enum Action: SwiftUIRedux.Action {
        case setName(to: String)
    }
    
    /// The reducer that updates the state.
    static func reducer(action: SwiftUIRedux.Action, state: Main.State) -> Main.State {
        var state = state
        switch action as? Main.Action {
        case let .setName(name):
            state.observed.name = name
        }
        return state
    }
}
```
Store the state in a common state object. Add all your subStates to this struct. 
```Swift
struct AppState: State {
   let main = Observed(initState: main)
    
    /// observedStates defines the states that should be observed by SwiftUIRedux
    public var observedStates: [any ObservedStateProvider] { [main] }
}
```
Setup the redux store in your SwiftUI App and assign the observed objects your want to observe in your view.
```Swift
@main
struct SwiftUIReduxExampleApp: App {
    init() {
        store = Store<AppState>(state: AppState())
        main = store.state.main
    }

    let store: Store<AppState>
    @ObservedObject var main: Observed<Main.State>

    var body: some Scene {
        WindowGroup {
            VStack {
                Text(main.state.observed.name)
                Button(action: {
                    Task {
                        await store.dispatch(Main.Action.setName(to: "Ruby"))
                    }
                }) {
                    Text("Update")
                }
            }
        }
    }
}
```

## SideEffects
Side effects to actions allows the app to react upon action events. This is useful when you want to make network requests and fetch data. SwiftUIRedux uses middlewares to provide side effects. You can create your own but SwiftUIRedux offers `LoggingMiddleware` and `SideEffectMiddleware` that you can easly configure in your ReduxApp. The LoggerMiddleware is useful in debug mode to log all actions that occurs in the app. The SideEffectMiddleware provides a sideEffect function for your actions.

Apply the middleware where you setup your store.
```Swift
@main
struct SwiftUIReduxExampleApp: App {
    init() {
        store = Store<AppState>(state: AppState(), middleware: [
            LoggerMiddleware.createMiddleware(),
            SideEffectMiddleware.createMiddleware(),
        ])
    }
}

enum Main {
    enum Action: SwiftUIRedux.Action: SideEffect {
        case send(name: String)
        case setResponse(to: String)
        
        // Side effects can be configured within this function
        func sideEffect<State>(dispatch: @escaping DispatchFunction, state _: State) async {
            switch self {
            case let .send(name):
                // Simulate a network request
                try? await Task.sleep(for: .seconds(1))
                await dispatch(.setResponse(to: "Some new name"))
            default:
                break
            }
        }

        // This property allows the loggerMiddleware to print this enum in a nicer.
        var debugActionName: String {
            "Main.\(type(of: self))."
        }
    }
}
```
