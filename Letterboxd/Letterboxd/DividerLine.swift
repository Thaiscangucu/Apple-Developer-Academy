import SwiftUI

struct DividerLine : View {
    var width: CGFloat
    var body: some View {
        Rectangle()
            .frame(width: width, height: 1)
    }
}
