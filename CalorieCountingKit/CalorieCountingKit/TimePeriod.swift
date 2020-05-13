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
}

extension TimePeriod: CustomStringConvertible {
    public var description: String {
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
