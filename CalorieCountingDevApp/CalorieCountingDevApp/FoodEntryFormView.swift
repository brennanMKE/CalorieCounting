import SwiftUI
import CalorieCountingKit

struct FoodEntryFormView: View {
    @Binding var presentationMode: PresentationMode
    @EnvironmentObject private var dummyData: DummyData

    @State private var selectedDate: Date = Date()
    @State private var timePeriodTag: Int = TimePeriod.morning.tag

    var label: String {
        dummyData.selectedFoodItem?.label ?? "None"
    }

    var image: Image? {
        dummyData.selectedFoodItem?.image
    }

    var body: some View {
        VStack {
            HStack {
                FoodImageView(image: image)
                Text(label)
            }
            Spacer()
            DatePicker(selection: $selectedDate, label: { Text("Date") })
//            TimePeriodPicker(pickerTag: $timePeriodTag, title: "")

            Spacer()
            Button(action: {
                self.save()
            }) {
                Text("Save")
                    .font(.largeTitle)
            }
        }
        .padding()
    }

    func save() {
        print("Save")
        self.presentationMode.dismiss()
    }
}

struct FoodEntryView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyData = DummyData().loadForPreview()
        let foodItem = dummyData.foodItems.first!
        dummyData.selectedFoodItem = foodItem
        return FoodEntryModalView()
            .environmentObject(DummyData().loadForPreview())
    }
}
