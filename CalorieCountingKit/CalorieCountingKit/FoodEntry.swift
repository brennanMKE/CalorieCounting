import Foundation

public struct FoodEntry: JSONRepresentable, Equatable {
    let date: Date
    let timePeriod: TimePeriod
    let foodItemUuid: String
    let uuid: String
    let isDeleted: Bool

    public init(date: Date,
                timePeriod: TimePeriod,
                foodItemUuid: String,
                uuid: String = UUID().uuidString,
                isDeleted: Bool = false) {
        self.date = date
        self.timePeriod = timePeriod
        self.foodItemUuid = foodItemUuid
        self.uuid = uuid
        self.isDeleted = isDeleted
    }

    public init(date: Date,
                timePeriod: TimePeriod,
                foodItem: FoodItem,
                uuid: String = UUID().uuidString,
                isDeleted: Bool = false) {
        self.date = date
        self.timePeriod = timePeriod
        self.foodItemUuid = foodItem.uuid
        self.uuid = uuid
        self.isDeleted = isDeleted
    }
}

public protocol FoodEntryStore {}

public struct JSONFoodEntryStore: FoodEntryStore {
    enum Failure: Error {
        case failedToLoadFoodItem
        case unknown
    }


}
