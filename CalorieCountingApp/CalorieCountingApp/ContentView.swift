import SwiftUI

struct ContentView: View {
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            Text("Today")
                .font(.title)
                .tabItem {
                    VStack {
                        Text("Today")
                    }
                }
                .tag(0)

            Text("Entry")
                .font(.title)
                .tabItem {
                    VStack {
                        Text("Entry")
                    }
                }
                .tag(1)

            Text("Chart")
                .font(.title)
                .tabItem {
                    VStack {
                        Text("Chart")
                    }
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
