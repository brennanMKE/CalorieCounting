import PlaygroundSupport
import SwiftUI

let DatePickerMaxDaysBack = 30

struct DayPicker: View {
    @State var value: Int = DatePickerMaxDaysBack

//    private var bindableDate: Binding<Date> { Binding (
//        get: { self.model.usernameResult.isVisibleError },
//        set: { if !$0 { self.model.dismissUsernameResultError() } }
//        )
//    }

    let dateChanged: (Date) -> Void

    var daysBack: Int {
        // Note: 0 is today
        let result = DatePickerMaxDaysBack - value
        return result
    }

    var date: Date {
        let result: Date

        let date = Date()
        let calendar = Calendar(identifier: .iso8601)
        let day  = calendar.ordinality(of: .day, in: .year, for: date) ?? 0
        let year = calendar.component(.year, from: date)
        let components = DateComponents(calendar: calendar, year: year, day: day - (daysBack))
        if let date = components.date {
            result = date
        } else {
            fatalError("Failed to get date")
        }

        return result
    }

    var text: String {
        let result: String
        if daysBack == 0 {
            result = "Today"
        } else if daysBack == 1 {
            result = "Yesterday"
        } else {
            result = getDayString(value: daysBack)
        }
        dateChanged(date)

        return result
    }

    var weekRange: ClosedRange<Int> {
        0...DatePickerMaxDaysBack
    }

    func getDayString(value: Int) -> String {
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
        Stepper(value: $value, in: weekRange) {
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
                DayPicker { date in
                    print("Date Changed:", date)
                    self.date = date
                }
                Text(dateString)
            }
            Spacer()
        }
    }

}

let liveView = LiveView(date: Date())

PlaygroundPage.current.liveView = UIHostingController(rootView: liveView)
