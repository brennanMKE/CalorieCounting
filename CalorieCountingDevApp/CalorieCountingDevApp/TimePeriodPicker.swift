import SwiftUI
import CalorieCountingKit

extension TimePeriod: Identifiable {
    public var id: Int {
        return rawValue
    }
}

struct TimePeriodPicker: View {
    @Binding var stepperValue: Int
    var title: String

    var name: String {
        if let timePeriod = TimePeriod(rawValue: stepperValue) {
            return timePeriod.name
        } else {
            return TimePeriod.morning.name
        }
    }

    var body: some View {
        HStack {
            Text(name)
            Stepper(value: $stepperValue, in: TimePeriod.range) {
                Text(name)
            }
        }
//        Picker(selection: $pickerTag, label: Text(title)) {
//            ForEach(TimePeriod.allCases, id: \.self) { timePeriod in
//                Text(timePeriod.name).tag(timePeriod.tag)
//            }
//        }
//        .pickerStyle(SegmentedPickerStyle())
    }
}

struct TimePeriodPickerView_Previews: PreviewProvider {
    static var previews: some View {
        TimePeriodPicker(stepperValue: .constant(TimePeriod.morning.tag), title: "Time Period")
    }
}
