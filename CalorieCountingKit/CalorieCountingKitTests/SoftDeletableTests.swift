import XCTest

@testable import CalorieCountingKit

struct Item: SoftDeletable {
    let name: String
    let isDeleted: Bool
}

class SoftDeletableTests: XCTestCase {

    func testSoftDeletableArray() throws {
        let items = [
            Item(name: "One", isDeleted: false),
            Item(name: "Two", isDeleted: false),
            Item(name: "Three", isDeleted: false),
            Item(name: "Four", isDeleted: false),
            Item(name: "Five", isDeleted: true)
        ]

        let visibleItems: [Item] = items.visibleItems

        XCTAssertEqual(items.count, 5)
        XCTAssertEqual(visibleItems.count, 4)
    }

}
