import Combine
import Foundation
import SwiftUI
import SwiftUIRedux

import XCTest

public struct AsyncWaiter<Object: SubState> {
    public init(for obj: Observed<Object>, toBeTrue condition: @escaping (Object) -> Bool) {
        self.obj = obj
        self.condition = condition
    }

    let obj: Observed<Object>
    let condition: (Object) -> Bool

    @MainActor func wait(file: StaticString = #filePath, line: UInt = #line) async throws {
        try await AsyncObserver().wait(for: obj.$observedState, toBeTrue: { _ in
            self.condition(self.obj.state)
        }, file: file, line: line)
    }
}

@MainActor public class ActionRecorder: ObservableObject {
    init() {
        actions = []
    }

    @Published private(set) var actions: [any Action] = []

    func reset() {
        actions = []
    }

    func createMiddleware<AppState>() -> Middleware<AppState> {
        { _, _ in
            { next in
                { [weak self] action in
                    let nextAction: Void = await next(action)

                    await self?.append(action)

                    return nextAction
                }
            }
        }
    }

    private func append(_ action: Action) async {
        actions.append(action)
    }
}

public class AsyncObserver {
    public init() {}

    private var subscriber: Cancellable?
    private var resumed: Bool = false
    private var timer: Timer?

    @MainActor public func wait<Value>(
        for model: Published<Value>.Publisher,
        toBeTrue condition: @escaping (Value) -> Bool,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self = self else {
                return continuation.resume(throwing: WaitError.timeout)
            }
            self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
                guard let self = self, self.resumed == false else {
                    return continuation.resume(throwing: WaitError.timeout)
                }
                self.resumed = true
                XCTFail(
                    "Async timout",
                    file: file,
                    line: line
                )
                continuation.resume(throwing: WaitError.timeout)
                self.subscriber?.cancel()
            }

            self.subscriber = model.sink { [weak self] value in
                print("⏸️ AsyncObserver: received value", value)
                guard
                    let self = self,
                    self.resumed == false,
                    condition(value)
                else { return }
                self.resumed = true
                self.timer?.invalidate()
                self.timer = nil
                self.subscriber?.cancel()
                continuation.resume()
            }
        }
    }

    public enum WaitError: Error {
        case timeout
    }
}

public class AsyncSubscriber<T> {
    @Published public private(set) var events = [T]()
    private var subscriber: Cancellable?
    public init(publisher: PassthroughSubject<T, Never>) {
        subscriber = publisher.sink { [weak self] newEvent in
            self?.events.append(newEvent)
        }
    }

    public func reset() {
        events = []
    }
}
