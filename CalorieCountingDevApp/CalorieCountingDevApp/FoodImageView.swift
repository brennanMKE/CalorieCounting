import SwiftUI

struct FoodImageView: View {
    var image: Image?
    let strokeColor = Color("ImageStroke")

    var body: some View {
        (image ?? Image("Missing"))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .overlay(Circle().stroke(strokeColor, lineWidth: 4))
            .frame(width: 50, height: 50, alignment: .center)
            .clipShape(Circle())
            .onAppear {
                logInfo("displaying FoodEntryModalView")
                if self.image == nil {
                    logInfo("image is nil")
                } else {
                    logInfo("image is not nil")
                }
            }
    }
}

struct FoodImageView_Previews: PreviewProvider {
    static var previews: some View {
        FoodImageView(image: Image("Missing"))
    }
}
