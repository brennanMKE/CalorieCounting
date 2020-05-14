import SwiftUI
import CalorieCountingKit

struct FoodItemListView: View {
    @State private var sortIndex = 1
    @EnvironmentObject private var dummyData: DummyData

    var sortedFoodItems: [FoodItem] {
        let items = sortIndex == 1 ?
            dummyData.foodItems.sortedByLabel() :
            dummyData.foodItems.sortedByCalories()
        return items
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $sortIndex, label: Text("Sort")) {
                    Text("Name").tag(1)
                    Text("Calories").tag(2)
                }
                    .pickerStyle(SegmentedPickerStyle())
                List {
                    ForEach(sortedFoodItems, id: \.uuid) { foodItem in
                        HStack {
                            FoodImageView(image: foodItem.image)
                            Text(foodItem.label)
                            Spacer()
                            Text("\(foodItem.calories)")
                                .foregroundColor(.gray)
                        }
                    }
                    .navigationBarTitle(Text("Food Items"))
                }
            }
        }
    }
}

struct FoodItemListView_Previews: PreviewProvider {
    static var previews: some View {
        return FoodItemListView()
            .environmentObject(DummyData().loadForPreview())
    }
}
