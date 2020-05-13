import Foundation

public protocol FoodEntryStore {

    /// Load all Food Entries
    /// - Parameter closure: result closure
    func loadAll(closure: @escaping (Result<[FoodEntry], Error>) -> Void)

    /// Store Food Entry which operates asynchronously
    /// - Parameters:
    ///   - foodEntry: food entry
    ///   - closure: result closure
    func store(foodEntry: FoodEntry, closure: @escaping (Result<Bool, Error>) -> Void)
}

var DefaultFoodEntryStore: FoodEntryStore? = nil

extension FoodEntryStore {

    /// Default instance for FoodEntryStore
    public static var `default`: FoodEntryStore {
        if let store = DefaultFoodEntryStore {
            return store
        } else {
            let store = JSONFoodEntryStore()
            DefaultFoodEntryStore = store
            return store
        }
    }

    /// Resets the default instance which releases it from memory
    public static func reset() {
        DefaultFoodEntryStore = nil
    }
}
