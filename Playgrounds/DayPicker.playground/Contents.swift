import PlaygroundSupport
import SwiftUI

let DayPickerMaxDaysBack = 30

struct DayPicker: View {
    @State var stepperValue: Int
    @Binding var date: Date

    private let maxDaysBack: Int

    init(maxDaysBack: Int = DayPickerMaxDaysBack, date: Binding<Date>) {
        // ensure the range is valid
        let safeMaxDaysBack = max(maxDaysBack, 1)
        self.maxDaysBack = safeMaxDaysBack
        _stepperValue = State(initialValue: safeMaxDaysBack)
        _date = date
    }

    private func calculateDate(for daysBack: Int) -> Date {
        let result = Calendar.current.date(byAdding: .day, value: daysBack * -1, to: Date())!
        return result
    }

    private var daysBack: Int {
        let result = maxDaysBack - stepperValue
        return result
    }

    private var text: String {
        let result: String
        switch daysBack {
        case 0:
            result = "Today"
        case 1:
            result = "Yesterday"
        default:
            result = getDayString(value: daysBack)
        }

//        date = calculateDate(for: daysBack)

        return result
    }

    private var daysRange: ClosedRange<Int> {
        0...maxDaysBack
    }

    private func getDayString(value: Int) -> String {
        let result: String
        let dateFormatter = DateFormatter()
        if value < 7 {
            dateFormatter.dateFormat = "cccc"
        } else {
            dateFormatter.dateStyle = .medium
        }
        result = dateFormatter.string(from: date)

        return result
    }

    var body: some View {
        Stepper(value: $stepperValue, in: daysRange) {
            Text(text)
        }
    }
}

struct LiveView: View {
    @State var date: Date

    var dateString: String {
        let result = "\(date)"
        return result
    }

    var body: some View {
        HStack {
           Spacer()
           VStack {
                DayPicker(maxDaysBack: 7, date: $date)
                Text(dateString)
            }
            Spacer()
        }
    }
}

let liveView = LiveView(date: Date())

PlaygroundPage.current.liveView = UIHostingController(rootView: liveView)
