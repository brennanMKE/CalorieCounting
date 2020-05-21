import Foundation
import SwiftUI
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

enum FoodItemSort: Int, CaseIterable, RawRepresentable {
    case label = 1
    case calories = 2

    static var `default`: Self {
        return .label
    }

    var name: String {
        let result: String
        switch self {
        case .label:
            result = "Name"
        case .calories:
            result = "Calories"
        }
        return result
    }

    var tag: Int {
        rawValue
    }
}

class DummyData: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var selectedFoodItem: FoodItem?
    var foodItemSort: FoodItemSort = .default

    private let preloadedItems = [
        FoodItem(label: "Burger", calories: 500, uuid: "burger", isDeleted: false),
        FoodItem(label: "Carrots", calories: 50, uuid: "carrots", isDeleted: false),
        FoodItem(label: "Eggs", calories: 75, uuid: "eggs", isDeleted: false),
        FoodItem(label: "Hot Dog", calories: 350, uuid: "hotdog", isDeleted: false),
        FoodItem(label: "Toast", calories: 150, uuid: "toast", isDeleted: false)
    ]

    func loadForPreview() -> Self {
        let sorted = self.foodItemSort == .label ? preloadedItems.sortedByLabel() : preloadedItems.sortedByCalories()
        foodItems = sorted
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
                    let visibleItems = foodItems.visibleItems
                    let sorted = self.foodItemSort == .label ? visibleItems.sortedByLabel() : visibleItems.sortedByCalories()
                    self.foodItems = sorted
                } else {
                    self.populateFoodItems { result in
                        switch result {
                        case .success(let foodItems):
                            os_log(.info, log: Logger.devApp, "Updating observed food items with %i items", foodItems.count)
                            let visibleItems = foodItems.visibleItems
                            let sorted = self.foodItemSort == .label ? visibleItems.sortedByLabel() : visibleItems.sortedByCalories()
                            DispatchQueue.main.sync {
                                self.foodItems = sorted
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

    func sortFoodItems(by sort: FoodItemSort) {
        print(#function, sort.name)
        guard sort != foodItemSort else { return }
        foodItemSort = sort
        let sorted = self.foodItemSort == .label ? foodItems.sortedByLabel() : foodItems.sortedByCalories()
        print("first:", sorted.first?.label ?? "none")
        foodItems = sorted
    }

    func removeFoodItems(at indexSet: IndexSet) {
        indexSet.forEach {
            let foodItem = foodItems[$0]
            ModelStores.foodItemStore.remove(foodItem: foodItem) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    os_log(.info, log: Logger.devApp, "removed Food Item: %s", String(describing: foodItem))
                    self.reloadFoodItems()
                case .failure(let error):
                    logError(error)
                }
            }
            print("removing item:", $0)
        }
    }

    func reloadFoodItems() {
        logInfo(#function)
        ModelStores.foodItemStore.loadAll { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let foodItems):
                let visibleItems = foodItems.visibleItems
                let sorted = self.foodItemSort == .label ? visibleItems.sortedByLabel() : visibleItems.sortedByCalories()
                os_log(.info, log: Logger.devApp, "reloaded %i food items", sorted.count)
                sorted.forEach {
                    os_log(.info, log: Logger.devApp, "food item: %s", String(describing: $0))
                }
                DispatchQueue.main.sync {
                    self.foodItems = sorted
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

    func restoreDeletedFoodItems(closure: @escaping (Result<Int, Error>) -> Void ) {
        let foodItemStore = ModelStores.foodItemStore
        foodItemStore.loadAll { result in
            do {
                let deleted = try result.get().filter { $0.isDeleted }
                guard deleted.count > 0 else {
                    closure(.success(0))
                    return
                }

                deleted.forEach {
                    os_log(.info, log: Logger.devApp, "food item: %s", String(describing: $0))
                }

                // restore each deleted item in sequence
                var index = 0

                var isDone: Bool {
                    let result = index == deleted.count - 1
                    return result
                }

                var step: (() -> Void)? = nil

                let restore: () -> Void = {
                    assert(index < deleted.count)
                    let foodItem = deleted[index]
                    assert(foodItem.isDeleted)
                    let restored = FoodItem(label: foodItem.label, calories: foodItem.calories, uuid: foodItem.uuid, isDeleted: false)

                    ModelStores.foodItemStore.store(foodItem: restored) { result in
                        do {
                            // value is always true so it can be discarded
                            _ = try result.get()
                            step?()
                        } catch {
                            closure(.failure(error))
                        }
                    }
                }

                step = {
                    if !isDone {
                        index += 1
                        restore()
                    } else {
                        closure(.success(index + 1))
                    }
                }

                restore()
            }
            catch {
                logError(error)
                closure(.failure(error))
            }
        }
    }

}
