import Foundation
import os.log

public struct FoodEntry: JSONRepresentable, Equatable {
    public let date: Date
    public let timePeriod: TimePeriod
    public let foodItemUuid: String
    public let uuid: String
    public let isDeleted: Bool

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
