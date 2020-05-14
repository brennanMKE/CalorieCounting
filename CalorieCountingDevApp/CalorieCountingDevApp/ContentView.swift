import SwiftUI
import CalorieCountingKit

struct ContentView: View {
    @EnvironmentObject private var dummyData: DummyData

    var body: some View {
        NavigationView {
            List {
                ForEach(dummyData.foodItems, id: \.uuid) { foodItem in
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

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        let dummyData = DummyData()
        dummyData.loadForPreview()
        return ContentView()
            .environmentObject(dummyData)
    }
}
