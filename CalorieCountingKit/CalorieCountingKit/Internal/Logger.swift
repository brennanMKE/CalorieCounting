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
