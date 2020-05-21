import SwiftUI
import CalorieCountingKit

struct FoodEntryModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var dummyData: DummyData

    var body: some View {
        NavigationView {
            VStack {
                FoodEntryFormView(presentationMode: presentationMode)
                    .environmentObject(dummyData)
            }
            .navigationBarTitle(Text("Food Log"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done").bold()
            })
        }
    }
}

struct FoodEntryModalView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyData = DummyData().loadForPreview()
        let foodItem = dummyData.foodItems.first!
        dummyData.selectedFoodItem = foodItem
        return FoodEntryModalView()
            .environmentObject(DummyData().loadForPreview())
    }
}
