import PlaygroundSupport
import SwiftUI

struct Item: Identifiable {
    let name: String
    let number: Int
    let color: Color

    var id: Int {
        number
    }
}

class DataModel: ObservableObject {
    @Published var items: [Item]
    @Published var selectedItem: Item?
    private var currentItemState: ItemState = .original
    private var allItems: [Item] = []

    init() {
        self.items = allItems
    }

    func add(item: Item) {
        allItems.append(item)
        self.items = allItems
    }

    func add(items: [Item]) {
        allItems.append(contentsOf: items)
        self.items = allItems
    }

    func remove(indexSet: IndexSet) {
        indexSet.forEach { index in
            items.remove(at: index)
        }
    }

    func process(itemState: ItemState) {
        guard currentItemState != itemState else { return }
        currentItemState = itemState
        switch itemState {
        case .original:
            items = allItems
        case .sortByName:
            items = items.sorted { $0.name < $1.name }
        case .sortByNumber:
            items = items.sorted { $0.number < $1.number }
        case .filterOdd:
            items = items.filter { $0.number % 2 == 1 }
        }
    }
}

enum ItemState: Int, CaseIterable, RawRepresentable {
    case original = 0
    case sortByName = 1
    case sortByNumber = 2
    case filterOdd = 3

    var tag: Int {
        return rawValue
    }

    var name: String {
        switch self {
        case .original:
            return "Original"
        case .sortByName:
            return "Name"
        case .sortByNumber:
            return "Number"
        case .filterOdd:
            return "Odds"
        }
    }
}

struct ItemStatePicker: View {
    @Binding var pickerTag: Int

    var body: some View {
        Picker(selection: $pickerTag, label: Text("State"), content: {
            ForEach(ItemState.allCases, id: \.self) { itemState in
                Text(itemState.name).tag(itemState.tag)
            }
        })
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct RowView: View {
    let item: Item

    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            Text("\(item.number)")
        }
        .foregroundColor(item.color)
        .padding()
    }
}

struct SheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var dataModel: DataModel

    var name: String {
        dataModel.selectedItem?.name ?? "None"
    }

    var body: some View {
        NavigationView {
            VStack {
                Text(name)
            }
            .navigationBarTitle(Text(name), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done").bold()
            })
        }
    }
}

struct LiveView: View {
    @EnvironmentObject private var dataModel: DataModel
    @State private var pickerTag = ItemState.original.tag
    @State var isSheetPresented = false

    var items: [Item] {
        if let itemState = ItemState(rawValue: pickerTag) {
            dataModel.process(itemState: itemState)
        }
        return dataModel.items
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    ItemStatePicker(pickerTag: $pickerTag)
                }
                Section {
                    ForEach(items) { item in
                        RowView(item: item)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("Tapped:", item.name)
                                self.dataModel.selectedItem = item
                                self.isSheetPresented.toggle()
                            }
                    }
                    .onDelete { indexSet in
                        self.dataModel.remove(indexSet: indexSet)
                    }
                }
            }
            .sheet(isPresented: $isSheetPresented) {
                SheetView()
                    .environmentObject(self.dataModel)
            }
            .navigationBarTitle(Text("Items"), displayMode: .inline)
        }
    }
}

let dataModel = DataModel()
let liveView = LiveView()

PlaygroundPage.current.liveView = UIHostingController(rootView: liveView.environmentObject(dataModel))

let items = [
    Item(name: "Black", number: 99, color: Color(red: 0.0, green: 0.0, blue: 0.0)),
    Item(name: "Red", number: 66, color: Color(red: 1.0, green: 0.0, blue: 0.0)),
    Item(name: "Green", number: 33, color: Color(red: 0.0, green: 1.0, blue: 0.0)),
    Item(name: "Blue", number: 44, color: Color(red: 0.0, green: 0.0, blue: 1.0))
]

DispatchQueue.concurrentPerform(iterations: 4) { index in
    DispatchQueue.global().asyncAfter(deadline: .now() + (0.5 * Double(index))) {
        DispatchQueue.main.sync {
            dataModel.add(item: items[index])
        }
    }
}
