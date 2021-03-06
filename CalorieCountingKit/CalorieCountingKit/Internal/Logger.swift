import Foundation
import os.log

let LogSubSystem = "com.acme.CalorieCountingKit"

enum LogCategory: CustomStringConvertible {
    case dataStore

    var description: String {
        let result: String
        switch self {
        case .dataStore:
            result = "Data Store"
        }
        return result
    }
}

struct Logger {
    static let dataStore = Self.logger(category: .dataStore)

    static func logger(category: LogCategory) -> OSLog {
        let logger = OSLog(subsystem: LogSubSystem, category: String(describing: category))
        return logger
    }
}

func logInfo(_ message: StaticString) {
    os_log(.info, log: Logger.dataStore, message)
}

func logDebug(_ message: StaticString) {
    os_log(.debug, log: Logger.dataStore, message)
}

func logError(_ message: StaticString) {
    os_log(.error, log: Logger.dataStore, message)
}

func logError(_ error: Error) {
    os_log(.error, log: Logger.dataStore, "Error: %s", String(describing: error))
}

func logFault(_ message: StaticString) {
    os_log(.fault, log: Logger.dataStore, message)
}
