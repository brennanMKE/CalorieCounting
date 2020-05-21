import SwiftUI
import CalorieCountingKit

extension TimePeriod: Identifiable {
    public var id: Int {
        return rawValue
    }
}

struct TimePeriodPicker: View {
    @Binding var pickerTag: Int

    var body: some View {
        Picker(selection: $pickerTag, label: Text("Time")) {
            ForEach(TimePeriod.allCases, id: \.self) { timePeriod in
                Text(timePeriod.name).tag(timePeriod.tag)
            }
        }
        .pickerStyle(WheelPickerStyle())
    }
}

struct TimePeriodPickerView_Previews: PreviewProvider {
    static var previews: some View {
        TimePeriodPicker(pickerTag: .constant(0))
    }
}
