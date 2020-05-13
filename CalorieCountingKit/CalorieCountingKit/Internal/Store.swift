import Foundation
import os.log

let FoodItemsDirectoryName = "FoodItems"
let FoodEntriesDirectoryName = "FoodEntries"

class Store {
    enum Failure: Error {
        case fileExistsAtDirectoryPath
        case failedToCreateDirectory(Error)
    }

    static var baseDocumentURL: URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url
    }

    static var foodItemsDirectoryURL: URL {
        let result = Self.baseDocumentURL.appendingPathComponent(FoodItemsDirectoryName)
        return result
    }

    static var foodEntriesDirectoryURL: URL {
        let result = Self.baseDocumentURL.appendingPathComponent(FoodEntriesDirectoryName)
        return result
    }

    static func createDirectoryIfNotExists(_ directoryURL: URL) throws {
        var isDir : ObjCBool = false

        let exists = FileManager.default.fileExists(atPath: directoryURL.path, isDirectory:&isDir)
        if !exists {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                os_log(.error, log: Logger.dataStore, "Failed to create directory")
                throw Failure.failedToCreateDirectory(error)
            }
        } else if exists && !isDir.boolValue {
            os_log(.error, log: Logger.dataStore, "File does not exist")
            throw Failure.fileExistsAtDirectoryPath
        }
    }

    // closure is called with a result of zero items when is nothing let to be loaded
    static func loadFoodItems(at index: Int, closure: @escaping (Result<[FoodItem], Error>) -> Void) {}

    // closure is called with a result of zero items when is nothing left to be loaded
    static func loadFoodEntries(at date: Date, closure: @escaping (Result<[FoodEntry], Error>) -> Void) {}

}
