import Foundation
import os.log

class JSONFoodEntryStore: FoodEntryStore {
    enum Failure: Error {
        case failedToLoadFoodEntry
        case unknown
    }

    let FoodEntriesDirectoryName = "FoodEntries"

    let fileStore: FileStore

    var foodEntriesDirectoryURL: URL {
        let result = fileStore.baseURL.appendingPathComponent(FoodEntriesDirectoryName)
        return result
    }

    init(store: FileStore = FileStore()) {
        self.fileStore = store
    }

    func filesFilter(path: String) -> Bool {
        let result = path.hasSuffix(".json")
        return result
    }

    func getDatePath(date: Date) -> String {
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        let result = "\(year)/\(month)/\(day)"
        return result
    }

    // MARK: - Public -

    public func loadAll(closure: @escaping (Result<[FoodEntry], Error>) -> Void) {
        // run the work with async behavior
        os_log(.debug, log: Logger.dataStore, "Loading Food Entry files")
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let jsonFiles = self.fileStore.collectFiles(url: self.foodEntriesDirectoryURL, filter: self.filesFilter)
            do {
                let foodEntries = try jsonFiles.map { url -> FoodEntry in
                    let result: FoodEntry
                    do {
                        result = try FoodEntry(fileURL: url)
                    } catch {
                        os_log(.error, log: Logger.dataStore, "Failed to load FoodEntry json file")
                        throw Failure.failedToLoadFoodEntry
                    }
                    return result
                }
                closure(Result.success(foodEntries))
            } catch Failure.failedToLoadFoodEntry {
                closure(Result.failure(Failure.failedToLoadFoodEntry))
            } catch {
                closure(Result.failure(Failure.unknown))
            }
        }
    }

    public func store(foodEntry: FoodEntry, closure: @escaping (Result<Bool, Error>) -> Void) {
        let filename = "\(foodEntry.uuid).json"
        // append YEAR/MONTH/DAY without zero padding
        let datePath = getDatePath(date: foodEntry.date)
        let directoryURL = foodEntriesDirectoryURL.appendingPathComponent(datePath)
        let fileURL = directoryURL.appendingPathComponent(filename)

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            do {
                try self.fileStore.createDirectoryIfNotExists(directoryURL)
                try foodEntry.writeJSON(fileURL: fileURL)
                closure(.success(true))
            } catch {
                closure(.failure(error))
            }
        }
    }

}
