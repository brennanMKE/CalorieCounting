import Foundation
import CoreGraphics
import CoreServices
import ImageIO

import os.log

import CalorieCountingKit

extension TimePeriod {
    static var max: Int {
        let result = Self.allCases.map { $0.rawValue }.max() ?? 0
        return result
    }

    static func randomCase() -> TimePeriod {
        let value = Int.random(in: 0..<Self.max)
        let result = TimePeriod(rawValue: value) ?? .morning
        return result
    }
}

class DummyData: ObservableObject {
    @Published var foodItems: [FoodItem] = []

    private let preloadedItems = [
        FoodItem(label: "Burger", calories: 500, uuid: "burger", isDeleted: false),
        FoodItem(label: "Carrots", calories: 50, uuid: "carrots", isDeleted: false),
        FoodItem(label: "Eggs", calories: 75, uuid: "eggs", isDeleted: false),
        FoodItem(label: "Hot Dog", calories: 350, uuid: "hotdog", isDeleted: false),
        FoodItem(label: "Toast", calories: 150, uuid: "toast", isDeleted: false)
    ]

    func loadForPreview() -> Self {
        foodItems = preloadedItems
        return self
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

    func preloadFoodItems() {
        // check if there are any food items already stored
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

    private func randomFoodEntry(date: Date) -> FoodEntry? {
        guard let foodItem = foodItems.randomElement() else { return nil }
        let timePeriod = TimePeriod.randomCase()
        let foodEntry = FoodEntry(date: date, timePeriod: timePeriod, foodItem: foodItem)
        return foodEntry
    }

    private func generateRandomFoodEntries(days: Int, entriesPerDay: Int) -> [FoodEntry] {
        // enter up to a total of entries per day selecting a random food item and time period for each day
        var foodEntries: [FoodEntry] = []

        let date = Date()
        let calendar = Calendar(identifier: .iso8601)
        let day  = calendar.ordinality(of: .day, in: .year, for: date) ?? 0
        let year = calendar.component(.year, from: date)
        for value in 0..<days {
            let components = DateComponents(calendar: calendar, year: year, day: day - (value))
            if let date = components.date {
                let entriesCount = Int.random(in: 0..<entriesPerDay)
                for _ in 0..<entriesCount {
                    if let foodEntry = randomFoodEntry(date: date) {
                        foodEntries.append(foodEntry)
                    }
                }
            }
        }

        return foodEntries
    }

    func populateRandomFoodEntries(days: Int, entriesPerDay: Int, closure: @escaping (Result<Int, Error>) -> Void) {
        let foodEntries = generateRandomFoodEntries(days: days, entriesPerDay: entriesPerDay)
        os_log(.info, log: Logger.devApp, "Generated %i food entries", foodEntries.count)

        var index = 0
        var advanceNext: () -> Void = {}
        let storeEntry: () -> Void = {
            assert(index < foodEntries.count)
            let foodEntry = foodEntries[index]
            ModelStores.foodEntryStore.store(foodEntry: foodEntry) { result in
                switch result {
                case .success:
                    if index < foodEntries.count - 1 {
                        advanceNext()
                    } else {
                         os_log(.info, log: Logger.devApp, "Stored %i food entries", foodEntries.count)
                        closure(.success(foodEntries.count))
                    }
                case .failure(let error):
                    logError(error)
                    closure(.failure(error))
                }
            }
        }

        advanceNext = {
            index += 1
            storeEntry()
        }

        storeEntry()
    }

    func populateRandomFoodEntries(closure: @escaping (Result<Int, Error>) -> Void) {
        populateRandomFoodEntries(days: 30, entriesPerDay: 10, closure: closure)
    }

    func purgeFoodEntries(closure: @escaping (Result<Int, Error>) -> Void) {
        // completely delete the Food Item files
        ModelStores.foodEntryStore.purge(closure: closure)
    }

}
