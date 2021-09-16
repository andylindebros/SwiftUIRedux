# SwiftUIRedux

Based on [ReSwift](https://github.com/ReSwift/ReSwift) but with support for SwiftUI only.

SwiftUIRedux provides a redux state for your SwiftUI project. The state gets updated by dispatching actions using the dispatch function within the store.

## Installation
Install SwiftUIRedux using Swift Package Manager

```Swift
dependencies: [
    .package(url: "https://github.com/andylindebros/SwiftUIRedux", from: "0.0.0"),
]
```

## Implementation example

Create a file named `Redux.swift` and add following content

```Swift
import SwiftUI
import SwiftUIRedux

class AppState: ObservableObject {
    @Published fileprivate(set) var name = "Andy"

    static func reducer(action: Action, state: AppState?) -> AppState {
        let state = state ?? AppState()
        switch action {
        case let a as SomeAction:
            state.name = a.payload
        default:
            break
        }
        return state
    }

    static func createStore(
        initState: AppState? = nil
    ) -> Store<AppState> {
        var middlewares = [Middleware<AppState>]()

        let store = Store<AppState>(reducer: AppState.reducer, state: initState, middleware: middlewares)

        return store
    }
}
```
Implement ContentView in your SwiftUI App:
```Swift

@main
struct ContentView: View {
    let store = AppState.createStore()

    init() {
        store = AppState.createStore()
    }
    var body: some Scene {
        WindowGroup {
            HelloWorldView(state: store.state, dispatch: store.dispatch)
        }
    }
}

struct HelloWorldView: View {
    @ObservedObject var state: AppState
    var dispatch: DispatchFunction
    var randomStrings = ["Andy", "Hanna", "Moa", "Peter", "Ruby", "Tom", "Marcus", "Simon", "Jenny", "Mary", "Zlatan"]
    var body: some View {
        Button(action: {
            dispatch(SomeAction(payload: randomStrings.filter { $0 != state.name }.randomElement()!))
        }) {
            Text("Hello \(state.name)!").font(.system(size: 40))
        }
    }
}
```
