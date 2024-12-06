import SwiftUI
import SwiftUIRedux

struct ContentView: View {
    let store = AppState.createStore()

    var body: some View {
        HelloWorldView(main: store.state.main, dispatch: store.dispatch)
    }
}

struct HelloWorldView: View, Sendable {
    @ObservedObject var main: Observed<Main.State>
    let dispatch: DispatchFunction
    static let randomStrings = ["Andy", "Hanna", "Moa", "Peter", "Ruby", "Tom", "Marcus", "Simon", "Jenny", "Mary", "Zlatan"]

    var body: some View {
        VStack {
            Text(main.state.observed.name)
            Button(action: {
                if let name = Self.randomStrings.randomElement() {
                    dispatch(Main.Action.setName(to: name))
                }
            }) {
                Text("Update")
            }
        }
    }
}
