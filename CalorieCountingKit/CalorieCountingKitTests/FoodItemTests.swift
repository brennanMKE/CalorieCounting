import XCTest
@testable import CalorieCountingKit

class FoodItemTests: XCTestCase {

    func testFoodItemEncodingAndDecoding() throws {
        let expected = FoodItem(label: "Toast", calories: 75, uuid: UUID().uuidString, isDeleted: true)

        var data: Data!

        XCTAssertNoThrow(data = try expected.getData())

        let json = String(data: data, encoding: .utf8) ?? ""
        print("json:", json)
        var actual: FoodItem!
        XCTAssertNoThrow(actual = try FoodItem(data: data))
        XCTAssertNotNil(actual)
        XCTAssertEqual(actual.label, expected.label)
        XCTAssertEqual(actual.calories, expected.calories)
        XCTAssertEqual(actual.uuid, expected.uuid)
        XCTAssertEqual(actual.isDeleted, expected.isDeleted)
    }

    func testFoodItemDecoding() throws {
        let expected = FoodItem(label: "Toast",
                                calories: 75,
                                uuid: UUID().uuidString,
                                isDeleted: false)
        let json = """
                   {
                     "uuid": "\(expected.uuid)",
                     "isDeleted": \(expected.isDeleted),
                     "label": "\(expected.label)",
                     "calories": \(expected.calories)
                   }
                   """

        print("json:", json)

        guard let data = json.data(using: .utf8) else {
            XCTFail("Failed to initalize data")
            return
        }

        var actual: FoodItem!
        XCTAssertNoThrow(actual = try FoodItem(data: data))
        XCTAssertNotNil(actual)
        XCTAssertEqual(actual.label, expected.label)
        XCTAssertEqual(actual.calories, expected.calories)
        XCTAssertEqual(actual.uuid, expected.uuid)
        XCTAssertEqual(actual.isDeleted, expected.isDeleted)
    }

}
