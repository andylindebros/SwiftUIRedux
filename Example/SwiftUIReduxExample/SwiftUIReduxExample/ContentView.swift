import SwiftUI
import SwiftUIRedux

struct ContentView: View {
    let store = AppState.createStore()

    var body: some View {
        HelloWorldView(state: store.state, dispatch: store.dispatch)
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
