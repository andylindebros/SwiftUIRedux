import SwiftUI
import SwiftUIRedux

@MainActor
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
        VStack {
            Text(state.name)
            Button(action: {
                dispatch(SomeAction(payload: randomStrings.randomElement()!))
            }) {
                Text("Update")
            }
        }
    }
}
