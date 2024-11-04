import Foundation
import SwiftUI

public protocol DebouncerProvider {
    func delay(action: any Action, by: String, timeout: TimeInterval?, repeats: Bool)
    func setDispatcher(to dispatch: @escaping DispatchFunction)
    func cancel(id: String)
}

public extension DebouncerProvider {
    func delay(action: any Action, by: String, repeats: Bool = false) {
        delay(action: action, by: by, timeout: nil, repeats: repeats)
    }

    func delay(action: any Action, by: String, timeout: TimeInterval? = nil, repeats: Bool = false) {
        delay(action: action, by: by, timeout: timeout, repeats: repeats)
    }
}

public final class Debouncer: DebouncerProvider, Sendable {
    public init(debouncerTimout: TimeInterval = 1) {
        self.debouncerTimout = debouncerTimout
    }

    public func cancel(id: String) {
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
            Task { @MainActor [weak self] in
                guard let self = self, let action = self.actions[id] else { return }
                await dispatch?(action)
                if !repeats {
                    self.actions.removeValue(forKey: id)
                    self.timers.removeValue(forKey: id)
                }
            }
        }
    }
}

public final class DebouncerMock: DebouncerProvider, Sendable {
    public init() {}
    private var dispatch: DispatchFunction?
    public func delay(action: any Action, by _: String, timeout _: TimeInterval?, repeats _: Bool) {
        Task { @MainActor [weak self] in
            await self?.dispatch?(action)
        }
    }

    public func cancel(id _: String) {}
    public func setDispatcher(to dispatch: @escaping SwiftUIRedux.DispatchFunction) {
        self.dispatch = dispatch
    }
}
