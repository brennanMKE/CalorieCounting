import SwiftUI
import CalorieCountingKit

struct ContentView: View {
    @State private var tabSelection = 1

    var body: some View {
        TabView(selection: $tabSelection) {
            FoodItemListView()
                .font(.title)
                .tabItem { Text("Food") }.tag(1)
            DebuggingView()
                .font(.title)
                .tabItem { Text("Debugging") }.tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
            .environmentObject(DummyData().loadForPreview())
    }
}
