import SwiftUI

import CalorieCountingKit

struct FoodItemRowView: View {
    let foodItem: FoodItem

    var body: some View {
        HStack {
            FoodImageView(image: foodItem.image)
            Text(foodItem.label)
            Spacer()
            Text("\(foodItem.calories)")
                .foregroundColor(.gray)
        }
    }
}

struct FoodItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        let foodItem = FoodItem(label: "Burger", calories: 250)
        return FoodItemRowView(foodItem: foodItem)
    }
}
