import SwiftUI
import CalorieCountingKit

let DevAppAccentColor = Color("Accent")

struct ContentView: View {
    @State private var tabSelection = 1

    var body: some View {
        TabView(selection: $tabSelection) {
            FoodItemListView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image("Star")
                        Text("Food")
                    }
            }.tag(1)
            DebuggingView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image("Diamond")
                        Text("Debugging")
                    }
            }.tag(2)
        }
        .accentColor(DevAppAccentColor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
            .environmentObject(DummyData().loadForPreview())
    }
}
