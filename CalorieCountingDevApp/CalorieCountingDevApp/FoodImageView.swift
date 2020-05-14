import SwiftUI

struct FoodImageView: View {
    var image: Image?
    let strokeColor: Color = Color(red: 0.9, green: 0.9, blue: 0.9)

    var body: some View {
        (image ?? Image("Missing"))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .overlay(Circle().stroke(strokeColor, lineWidth: 4))
            .frame(width: 50, height: 50, alignment: .center)
            .clipShape(Circle())
    }
}

struct FoodImageView_Previews: PreviewProvider {
    static var previews: some View {
        FoodImageView(image: Image("Missing"))
    }
}
