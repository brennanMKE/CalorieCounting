import XCTest
@testable import CalorieCountingKit

class FoodEntryTests: XCTestCase {

    func testFoodEntryEncodingAndDecoding() throws {
        let foodItem = FoodItem(label: "Toast", calories: 75)
        let expected = FoodEntry(date: Date(), timePeriod: .morning, foodItemUuid: foodItem.uuid)

        var data: Data!
        XCTAssertNoThrow(data = try expected.getData())

        let json = String(data: data, encoding: .utf8) ?? ""
        print("json:", json)

        var actual: FoodEntry!
        XCTAssertNoThrow(actual = try FoodEntry(data: data))
        XCTAssertNotNil(actual)
        XCTAssertEqual(actual.date.timeIntervalSince1970, expected.date.timeIntervalSince1970, accuracy: 1.0)
        XCTAssertEqual(actual.timePeriod, expected.timePeriod)
        XCTAssertEqual(actual.foodItemUuid, expected.foodItemUuid)
        XCTAssertEqual(actual.uuid, expected.uuid)
        XCTAssertEqual(actual.isDeleted, expected.isDeleted)
    }

    func testFoodEntryDecoding() throws {
        let foodItem = FoodItem(label: "Toast", calories: 75)
        let expected = FoodEntry(date: Date(), timePeriod: .morning, foodItemUuid: foodItem.uuid)
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: expected.date)
        let json = """
                   {
                     "uuid": "\(expected.uuid)",
                     "isDeleted": \(expected.isDeleted),
                     "date": "\(dateString)",
                     "timePeriod": \(expected.timePeriod.rawValue),
                     "foodItemUuid": "\(expected.foodItemUuid)"
                   }
                   """

        print("json:", json)

        guard let data = json.data(using: .utf8) else {
            XCTFail("Failed to initalize data")
            return
        }

        var actual: FoodEntry!
        XCTAssertNoThrow(actual = try FoodEntry(data: data))
        XCTAssertNotNil(actual)
        XCTAssertEqual(actual.date.timeIntervalSince1970, expected.date.timeIntervalSince1970, accuracy: 1.0)
        XCTAssertEqual(actual.timePeriod, expected.timePeriod)
        XCTAssertEqual(actual.foodItemUuid, expected.foodItemUuid)
        XCTAssertEqual(actual.uuid, expected.uuid)
        XCTAssertEqual(actual.isDeleted, expected.isDeleted)
    }

}
