import SwiftUI

import CalorieCountingKit

extension FoodItem {
    var image: Image? {
        guard let cgImage = cgImage else { return nil }
        let result = Image(cgImage, scale: CGFloat(2), label: Text(label))
        return result
    }
}
