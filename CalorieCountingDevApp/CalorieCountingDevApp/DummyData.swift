import Foundation
import CoreGraphics
import CoreServices
import ImageIO

import os.log

import CalorieCountingKit

class DummyData: ObservableObject {
    @Published var foodItems: [FoodItem] = []

    private let preloadedItems = [
        FoodItem(label: "Burger", calories: 500, uuid: "burger", isDeleted: false),
        FoodItem(label: "Carrots", calories: 50, uuid: "carrots", isDeleted: false),
        FoodItem(label: "Eggs", calories: 75, uuid: "eggs", isDeleted: false),
        FoodItem(label: "Hot Dog", calories: 350, uuid: "hotdog", isDeleted: false),
        FoodItem(label: "Toast", calories: 150, uuid: "toast", isDeleted: false)
    ]

    func loadForPreview() {
        foodItems = preloadedItems
    }

    func preloadFoodItems() {
        // TODO: check if there are any food items already stored
        // and if not then create instances of models and use the images
        // in the asset catalog to store them and then load them again.
        logInfo("Preloading Food Items")

        ModelStores.foodItemStore.loadAll { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let foodItems):
                if foodItems.count > 0 {
                    self.foodItems = foodItems
                } else {
                    self.populateFoodItems { result in
                        switch result {
                        case .success(let foodItems):
                            os_log(.info, log: Logger.devApp, "Updating observed food items with %i items", foodItems.count)
                            DispatchQueue.main.sync {
                                self.foodItems = foodItems
                            }
                        case .failure(let error):
                            logError(error)
                        }
                    }
                }
            case .failure(let error):
                logError(error)
            }
        }
    }

    private func populateFoodItems(index: Int = 0, closure: @escaping (Result<[FoodItem], Error>) -> Void) {
        os_log(.info, log: Logger.devApp, "preloadedItems [%i]", index)
        assert(index < preloadedItems.count, "Index should not exceed bounds")
        let foodItemStore = ModelStores.foodItemStore
        let foodItem = preloadedItems[index]
        do {
            let image = loadImage(name: foodItem.uuid)
            try foodItemStore.store(image: image, foodItem: foodItem)
            foodItemStore.store(foodItem: foodItem) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    os_log(.info, log: Logger.devApp, "Stored Food Item: %s", foodItem.label)
                    if index < self.preloadedItems.count - 1 {
                        self.populateFoodItems(index: index + 1, closure: closure)
                    } else {
                        os_log(.info, log: Logger.devApp, "Returning: %i food items", self.preloadedItems.count)
                        closure(.success(self.preloadedItems))
                    }
                case .failure(let error):
                    logError(error)
                    closure(.failure(error))
                }
            }
        } catch {
            closure(.failure(error))
        }
    }

    func loadImage(name: String) -> CGImage {
        guard
            let url = Bundle.main.url(forResource: name, withExtension: "jpg"),
            let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
            let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            fatalError("Couldn't load image \(name).jpg from main bundle.")
        }
        return image
    }

}
