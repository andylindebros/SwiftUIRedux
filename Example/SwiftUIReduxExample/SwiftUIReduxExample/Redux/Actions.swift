import Foundation
import SwiftUIRedux

struct SomeAction: Action, Codable {
    var payload: String
}

struct SetState: Action {
    var payload: AppState
}
