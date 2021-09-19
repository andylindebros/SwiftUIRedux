import Foundation
import SwiftUIRedux

struct SomeAction: Action {
    var payload: String
}

struct SetState: Action {
    var payload: AppState
}
