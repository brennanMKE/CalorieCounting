import Foundation
import os.log

let LogSubSystem = "com.acme.CalorieCountingDevApp"

enum LogCategory: CustomStringConvertible {
    case devApp

    var description: String {
        let result: String
        switch self {
        case .devApp:
            result = "Dev App"
        }
        return result
    }
}

struct Logger {
    static let devApp = Self.logger(category: .devApp)

    static func logger(category: LogCategory) -> OSLog {
        let logger = OSLog(subsystem: LogSubSystem, category: String(describing: category))
        return logger
    }
}

func logInfo(_ message: StaticString) {
    os_log(.info, log: Logger.devApp, message)
}

func logDebug(_ message: StaticString) {
    os_log(.debug, log: Logger.devApp, message)
}

func logError(_ message: StaticString) {
    os_log(.error, log: Logger.devApp, message)
}

func logError(_ error: Error) {
    os_log(.error, log: Logger.devApp, "Error: %s", String(describing: error))
}

func logFault(_ message: StaticString) {
    os_log(.fault, log: Logger.devApp, message)
}
