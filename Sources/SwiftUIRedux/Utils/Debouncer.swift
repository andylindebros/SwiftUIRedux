import Foundation
import SwiftUI

public protocol DebouncerProvider {
    func delay(action: any Action, by: String, timeout: TimeInterval?, repeats: Bool) async
    func setDispatcher(to dispatch: @escaping DispatchFunction) async
    func cancel(id: String) async
}

public extension DebouncerProvider {
    func delay(action: any Action, by: String, repeats: Bool = false) async {
        await delay(action: action, by: by, timeout: nil, repeats: repeats)
    }

    func delay(action: any Action, by: String, timeout: TimeInterval? = nil, repeats: Bool = false) async {
        await delay(action: action, by: by, timeout: timeout, repeats: repeats)
    }
}

public final actor Debouncer: DebouncerProvider, Sendable {
    public init(debouncerTimout: TimeInterval = 1) {
        self.debouncerTimout = debouncerTimout
    }

    public func cancel(id: String) async {
        if timers.keys.contains(id) {
            timers[id]?.invalidate()
            actions.removeValue(forKey: id)
        }
    }

    public func setDispatcher(to dispatch: @escaping DispatchFunction) {
        self.dispatch = dispatch
    }

    let debouncerTimout: TimeInterval
    public private(set) var timers: [String: Timer] = [:]
    private var dispatch: DispatchFunction?
    private var actions: [String: any Action] = [:]

    public func setDispatch(to dispatch: @escaping DispatchFunction) {
        self.dispatch = dispatch
    }

    public func delay(action: any Action, by id: String, timeout: TimeInterval? = nil, repeats: Bool = false) {
        if timers.keys.contains(id) {
            timers[id]?.invalidate()
            actions.removeValue(forKey: id)
        }

        actions[id] = action

        timers[id] = Timer.scheduledTimer(withTimeInterval: timeout ?? debouncerTimout, repeats: repeats) { [weak self] _ in
            Task { [weak self] in
                await self?.runTimer(id: id, repeats: repeats)
            }
        }
    }

    private func runTimer(id: String, repeats: Bool) async {
        guard let action = actions[id] else { return }
        await dispatch?(action)
        if !repeats {
            actions.removeValue(forKey: id)
            timers.removeValue(forKey: id)
        }
    }
}

public final actor DebouncerMock: DebouncerProvider, Sendable {
    public init() {}
    private var dispatch: DispatchFunction?
    public func delay(action: any Action, by _: String, timeout _: TimeInterval?, repeats _: Bool) async {
        await dispatch?(action)
    }

    func getDispatch() async -> DispatchFunction? {
        dispatch
    }

    public func cancel(id _: String) async {}
    public func setDispatcher(to dispatch: @escaping SwiftUIRedux.DispatchFunction) async {
        self.dispatch = dispatch
    }
}
