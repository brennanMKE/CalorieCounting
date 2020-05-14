import SwiftUI
import CalorieCountingKit

import os.log

struct DebuggingView: View {
    @EnvironmentObject private var dummyData: DummyData

    func populateFoodEntries() {
        dummyData.populateRandomFoodEntries() { result in
            switch result {
            case .success(let count):
                os_log(.info, log: Logger.devApp, "Populated %i food entries", count)
            case .failure(let error):
                logError(error)
            }
        }
    }

    func purgeFoodEntries() {
        dummyData.purgeFoodEntries { result in
            switch result {
            case .success(let count):
                os_log(.info, log: Logger.devApp, "Purged %i items", count)
            case .failure(let error):
                logError(error)
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                Button(action: { self.populateFoodEntries() }) {
                    Text("Populate Food Entries")
                        .font(.title)
                }
                Button(action: { self.purgeFoodEntries() }) {
                    Text("Purge All Food Entries")
                        .font(.title)
                }
            }
            .navigationBarTitle(Text("Debugging"))
        }
    }
}

struct DebuggingView_Previews: PreviewProvider {
    static var previews: some View {
        DebuggingView()
            .environmentObject(DummyData().loadForPreview())
    }
}
