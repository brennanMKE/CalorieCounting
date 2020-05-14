import SwiftUI
import CalorieCountingKit

struct ContentView: View {
    var body: some View {
        FoodItemListView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
            .environmentObject(DummyData().loadForPreview())
    }
}
