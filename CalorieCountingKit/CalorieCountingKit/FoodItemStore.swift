import Foundation
import CoreGraphics

public protocol FoodItemStore {

    /// Load all Food Items
    /// - Parameter closure: result closure
    func loadAll(closure: @escaping (Result<[FoodItem], Error>) -> Void)

    /// Load image for a Food Item
    /// - Parameter foodItem: food item
    func loadImage(foodItem: FoodItem) throws -> CGImage

    /// Store Food Item asynchronously
    /// - Parameters:
    ///   - foodItem: food item
    ///   - closure: closure
    func store(foodItem: FoodItem, closure: @escaping (Result<Bool, Error>) -> Void)

    /// Store image for a Food Item
    /// - Parameters:
    ///   - image: image
    ///   - foodItem: food item
    func store(image: CGImage, foodItem: FoodItem) throws

    /// Removes a Food Item by marking it as deleted
    /// - Parameters:
    ///   - foodItem: food item
    ///   - closure: result closure
    func remove(foodItem: FoodItem, closure: @escaping (Result<Bool, Error>) -> Void)
}

public extension FoodItem {

    // Convenience property to get the image for a Food Item
    var cgImage: CGImage? {
        let image = try? ModelStores.foodItemStore.loadImage(foodItem: self)
        return image
    }
}
