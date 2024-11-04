import SwiftUIRedux

public enum LoggerMiddleware {
    static func createMiddleware() -> Middleware<AppState> {
        { _, _ in
            { next in
                { action in
                    print(
                        "⚡️",
                        action
                    )
                    return await next(action)
                }
            }
        }
    }
}

