import SwiftUI

struct FiveStars : View {
    
    var body: some View {
        HStack(spacing: -7){
            Label("", systemImage: "star.fill")
            Label("", systemImage: "star.fill")
            Label("", systemImage: "star.fill")
            Label("", systemImage: "star.fill")
            Label("", systemImage: "star.fill")

        }
        .font(.caption2)

    }
}
