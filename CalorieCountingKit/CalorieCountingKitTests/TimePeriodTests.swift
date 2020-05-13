import XCTest
@testable import CalorieCountingKit

class TimePeriodTests: XCTestCase {

    func testLoadingTimePeriods() throws {
        let json = "[" + TimePeriod.allCases.map {
            String(describing: $0.rawValue)
        }.joined(separator: ", ") + "]"

        print("json:", json)

        guard let data = json.data(using: .utf8) else {
            XCTFail("Failed to initialize data")
            return
        }

        var result: [TimePeriod]?
        XCTAssertNoThrow(result = try [TimePeriod].decode(data: data))
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count ?? 0, TimePeriod.allCases.count)

        result?.forEach({
            print("Time Period:", $0)
        })
    }

    func testInitializingTimePeriodWithDate() {
        let values: [(TimePeriod, Int)] = [
            (.morning, 9),
            (.midDay, 12),
            (.afternoon, 15),
            (.evening, 18),
            (.lateNight, 22)
        ]

        values.forEach { (expected, hour) in
            let date = getDate(at: hour)
            let actual = TimePeriod(date: date)
            XCTAssertEqual(expected, actual)
        }
    }

    private func getDate(at hour: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 5
        dateComponents.day = 12
        dateComponents.timeZone = TimeZone(abbreviation: "PST")
        dateComponents.hour = hour
        dateComponents.minute = 05

        let date = Calendar.current.date(from: dateComponents)!
        return date
    }

}
