import Foundation

public class ModelStores {
    private static var _foodItemStore: FoodItemStore?
    private static var _foodEntryStore: FoodEntryStore?

    public static var foodItemStore: FoodItemStore {
        if let store = _foodItemStore {
            return store
        } else {
            let store = JSONFoodItemStore()
            _foodItemStore = store
            return store
        }
    }

    public static var foodEntryStore: FoodEntryStore {
        if let store = _foodEntryStore {
            return store
        } else {
            let store = JSONFoodEntryStore()
            _foodEntryStore = store
            return store
        }
    }
}
