import Foundation
import CoreGraphics

public struct FoodItem: JSONRepresentable, SoftDeletable, Equatable {
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

extension FoodItem: CustomStringConvertible {
    public var description: String {
        let result = "\(label) - \(calories) [\(uuid), \(isDeleted))]"
        return result
    }
}

public extension Array where Element == FoodItem {
    func sortedByLabel() -> Self {
        self.sorted { (lhs, rhs) -> Bool in
            lhs.label < rhs.label
        }
    }

    func sortedByCalories() -> Self {
        self.sorted { (lhs, rhs) -> Bool in
            lhs.calories < rhs.calories
        }
    }
}
