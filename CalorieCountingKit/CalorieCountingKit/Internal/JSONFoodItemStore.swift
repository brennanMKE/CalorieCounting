import Foundation
import CoreGraphics
import os.log

public class JSONFoodItemStore: FoodItemStore {
    enum Failure: Error {
        case failedToLoadFoodItem
        case unknown
    }

    let FoodItemsDirectoryName = "FoodItems"
    static let FoodEntriesFilterPattern = #".+\d+/\d+/\d+/.+\.json$"#

    let fileStore: FileStore
    let imageStore: ImageStore
    let filterRegex: NSRegularExpression

    var foodEntriesDirectoryURL: URL {
        let result = fileStore.baseURL.appendingPathComponent(FoodItemsDirectoryName)
        return result
    }

    init(fileStore: FileStore = FileStore(), imageStore: ImageStore? = nil) {
        self.fileStore = fileStore
        self.imageStore = imageStore ?? ImageStore(fileStore: fileStore)
        self.filterRegex = try! NSRegularExpression(pattern: Self.FoodEntriesFilterPattern)
    }

    func filesFilter(path: String) -> Bool {
        guard path.hasPrefix(fileStore.baseURL.path) else {
            return false
        }
        let nsrange = NSRange(path.startIndex..<path.endIndex, in: path)
        let result = filterRegex.matches(in: path, options: [], range: nsrange).count > 0
        return result
    }

    func imageURL(foodItem: FoodItem) -> URL {
        let filename = "\(foodItem.uuid).jpg"
        let fileURL = foodEntriesDirectoryURL.appendingPathComponent(filename)
        return fileURL
    }

    // MARK: - Public -

    public func loadAll(closure: @escaping (Result<[FoodItem], Error>) -> Void) {
        // run the work with async behavior
        os_log(.debug, log: Logger.dataStore, "Loading Food Item files")
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let jsonFiles = self.fileStore.collectFiles(url: self.foodEntriesDirectoryURL, filter: self.filesFilter)
            do {
                let foodItems = try jsonFiles.map { url -> FoodItem in
                    let result: FoodItem
                    do {
                        result = try FoodItem(fileURL: url)
                    } catch {
                        os_log(.error, log: Logger.dataStore, "Failed to load FoodItem json file")
                        throw Failure.failedToLoadFoodItem
                    }
                    return result
                }
                closure(Result.success(foodItems))
            } catch Failure.failedToLoadFoodItem {
                closure(Result.failure(Failure.failedToLoadFoodItem))
            } catch {
                closure(Result.failure(Failure.unknown))
            }
        }
    }

    public func loadImage(foodItem: FoodItem) throws -> CGImage {
        let result: CGImage
        let fileURL = imageURL(foodItem: foodItem)
        result = try imageStore.loadImage(url: fileURL)

        return result
    }

    public func store(foodItem: FoodItem, closure: @escaping (Result<Bool, Error>) -> Void) {
        let filename = "\(foodItem.uuid).json"
        let fileURL = foodEntriesDirectoryURL.appendingPathComponent(filename)
        DispatchQueue.global().async {
            do {
                try foodItem.writeJSON(fileURL: fileURL)
                closure(.success(true))
            } catch {
                closure(.failure(error))
            }
        }
    }

    public func store(image: CGImage, foodItem: FoodItem) throws {
        let fileURL = imageURL(foodItem: foodItem)
        try imageStore.store(image: image, url: fileURL)
    }
}
