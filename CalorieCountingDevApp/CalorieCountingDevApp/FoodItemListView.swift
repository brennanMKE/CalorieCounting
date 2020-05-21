import SwiftUI
import CalorieCountingKit

struct FoodItemListView: View {
    @State private var sortTag = FoodItemSort.default.tag
    @State var foodEntryModalPresented = false
    @EnvironmentObject private var dummyData: DummyData

    var foodItems: [FoodItem] {
        if let sort = FoodItemSort(rawValue: sortTag) {
            dummyData.sortFoodItems(by: sort)
        }
        return dummyData.foodItems
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    Picker(selection: $sortTag, label: Text("Sort")) {
                        ForEach(FoodItemSort.allCases, id: \.self) {
                            Text($0.name).tag($0.tag)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section {
                    ForEach(foodItems, id: \.uuid) { foodItem in
                        FoodItemRowView(foodItem: foodItem)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("Tapped:", foodItem.label)
                                self.dummyData.selectedFoodItem = foodItem
                                self.foodEntryModalPresented.toggle()
                            }
                            .sheet(isPresented: self.$foodEntryModalPresented) {
                                FoodEntryModalView()
                                    .environmentObject(self.dummyData)
                            }
                    }
                    .onDelete { indexSet in
                        logInfo("onDelete")
                        self.dummyData.removeFoodItems(at: indexSet)
                    }
                }
            }
            .navigationBarTitle(Text("Calories"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                logInfo("add")
            }) {
                Image(systemName: "plus")
            })
        }
//        .sheet(isPresented: $foodEntryModalPresented) {
//            FoodEntryModalView()
//        }
    }
}

struct FoodItemListView_Previews: PreviewProvider {
    static var previews: some View {
        return FoodItemListView()
            .environmentObject(DummyData().loadForPreview())
    }
}
