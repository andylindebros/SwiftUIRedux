import SwiftUI
import SwiftUIRedux

@MainActor
struct ContentView: View {
    let store = AppState.createStore()

    var body: some View {
        HelloWorldView(main: store.state.main, dispatch: store.dispatch)
    }
}

struct HelloWorldView: View {
    @ObservedObject var main: Observed<Main.State>
    var dispatch: DispatchFunction
    var randomStrings = ["Andy", "Hanna", "Moa", "Peter", "Ruby", "Tom", "Marcus", "Simon", "Jenny", "Mary", "Zlatan"]

    var body: some View {
        VStack {
            Text(main.state.observed.name)
            Button(action: {
                if let name = randomStrings.randomElement() {
                    Task {
                        await dispatch(Main.Action.setName(to: name))
                    }
                }
            }) {
                Text("Update")
            }
        }
    }
}
