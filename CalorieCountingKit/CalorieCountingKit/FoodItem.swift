import Foundation
import CoreGraphics

public struct FoodItem: JSONRepresentable, Equatable {
    public let label: String
    public let calories: Int
    public let uuid: String
    public let isDeleted: Bool

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
