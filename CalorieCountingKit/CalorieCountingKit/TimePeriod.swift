import Foundation

typealias TimePeriods = [TimePeriod]

@frozen
public enum TimePeriod: Int, CaseIterable, JSONRepresentable {
    case morning = 0
    case midDay
    case evening
    case afternoon
    case lateNight

    public init(date: Date) {
        let hour = Calendar.current.component(.hour, from: date)

        switch hour {
        case 5...10:
            self = .morning
        case 10...13:
            self = .midDay
        case 13...16:
            self = .afternoon
        case 16...21:
            self = .evening
        default:
            self = .lateNight
        }
    }

    public static var range: ClosedRange<Int> {
        let result = TimePeriod.morning.rawValue ... TimePeriod.lateNight.rawValue
        return result
    }

    public var tag: Int {
        rawValue
    }

    public var name: String {
        let result: String
        switch self {
            case .morning:
            result = "Morning"
            case .midDay:
            result = "Mid-day"
            case .afternoon:
                result = "Afternoon"
            case .evening:
                result = "Evening"
            case .lateNight:
                result = "Late Night"
        }

        return result
    }
}

extension TimePeriod: CustomStringConvertible {
    public var description: String {
        name
    }

}
