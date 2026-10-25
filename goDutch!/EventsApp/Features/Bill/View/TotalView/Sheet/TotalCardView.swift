import SwiftUI
 
struct TotalCardView: View {
    let value: Double
 
    var body: some View {
        AdaptiveStack {
            Text("Total")
              .font(.app(.subheadline))
            Spacer()
            Text(value, format: CurrencyHelper.formatStyle)
                .font(.app(.subheadline))
        }
        .bold()
        .padding(.horizontal, 25)
        .adaptiveRelativeHeight(0.15)
        .background(Color("surfaceMuted").cornerRadius(31.42857).shadow(color: .black.opacity(0.2), radius: 2.61905, x: 0, y: 2.61905).shadow(color: Color("shadowSoft").opacity(0.1), radius: 2.61905, x: 0, y: -1.30952))
        .foregroundColor(Color("textSecondary"))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Total")
        .accessibilityValue(CurrencyHelper.accessibilityFormat(value))
    }
}
