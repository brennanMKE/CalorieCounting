import Foundation
import os.log

public struct FoodItem: JSONRepresentable, Equatable {
    let label: String
    let calories: Int
    let uuid: String
    let isDeleted: Bool

    public init(label: String,
                calories: Int,
                uuid: String = UUID().uuidString,
                isDeleted: Bool = false) {
        self.label = label
        self.calories = calories
        self.uuid = uuid
        self.isDeleted = isDeleted
    }
}

public protocol FoodItemStore {}

public struct JSONFoodItemStore: FoodItemStore {
    enum Failure: Error {
        case failedToLoadFoodItem
        case unknown
    }

    func load(closure: @escaping (Result<[FoodItem], Failure>) -> Void) {
        let files = Files(basePath: Store.foodItemsDirectoryURL.path)
        let jsonFilter: (String) -> Bool = {
            let result = $0.hasSuffix(".json")
            return result
        }
        // run the work with async behavior
        DispatchQueue.global().async {
            let jsonFiles = files.collectFiles(url: Store.foodItemsDirectoryURL, filter: jsonFilter)
            do {
                let foodItems = try jsonFiles.map { url -> FoodItem in
                    let result: FoodItem
                    do {
                        result = try FoodItem(fileURL: url)
                    } catch {
                        os_log(.error, log: Logger.dataStore, "Failed to load FoodItem json file")
                        throw Failure.failedToLoadFoodItem
                    }
                    return result
                }
                closure(Result.success(foodItems))
            } catch Failure.failedToLoadFoodItem {
                closure(Result.failure(Failure.failedToLoadFoodItem))
            } catch {
                closure(Result.failure(Failure.unknown))
            }
        }
    }
}
