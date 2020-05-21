import SwiftUI
import CalorieCountingKit

import os.log

struct DebuggingView: View {
    @EnvironmentObject private var dummyData: DummyData

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
                Button(action: { self.restoreDeletedFoodItems() }) {
                    Text("Restore Deleted Food Items")
                        .font(.title)
                }
            }
            .navigationBarTitle(Text("Debugging"))
        }
    }

    private func populateFoodEntries() {
        dummyData.populateRandomFoodEntries() { result in
            switch result {
            case .success(let count):
                os_log(.info, log: Logger.devApp, "Populated %i food entries", count)
            case .failure(let error):
                logError(error)
            }
        }
    }

    private func purgeFoodEntries() {
        dummyData.purgeFoodEntries { result in
            switch result {
            case .success(let count):
                os_log(.info, log: Logger.devApp, "Purged %i items", count)
            case .failure(let error):
                logError(error)
            }
        }
    }

    private func restoreDeletedFoodItems() {
        dummyData.restoreDeletedFoodItems { result in
            do {
                let count = try result.get()
                os_log(.info, log: Logger.devApp, "restored %i deleted food items", count)
                self.dummyData.reloadFoodItems()
            } catch {
                logError(error)
            }
        }
    }
}

struct DebuggingView_Previews: PreviewProvider {
    static var previews: some View {
        DebuggingView()
            .environmentObject(DummyData().loadForPreview())
    }
}
