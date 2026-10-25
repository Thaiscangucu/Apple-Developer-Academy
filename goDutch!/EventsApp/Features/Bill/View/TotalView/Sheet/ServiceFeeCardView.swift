import SwiftUI
 
struct ServiceFeeCardView: View {
    let percentage: Double
    let total: Double
 
    var body: some View {
        AdaptiveStack {
            Text("Taxa Serviço")
              .font(.app(.subheadline, weight: .bold))
            Spacer()
            // Porcentagem e valor ficam juntos mesmo quando a linha empilha.
            HStack(spacing: 6) {
                Text("\(percentage.formatted(.number.precision(.fractionLength(0))))%")
                    .font(.app(.subheadline))
                let userTotal = total * (percentage / 100)
                Text("\(userTotal.formatted(.number.precision(.fractionLength(2))))")
                    .font(.app(.subheadline, weight: .bold))
            }
        }
        .padding(.horizontal, 25)
        .adaptiveRelativeHeight(0.12)
        .background(Color.white.cornerRadius(31.42857).shadow(color: .black.opacity(0.2), radius: 2.61905, x: 0, y: 2.61905).shadow(color: Color("shadowSoft").opacity(0.1), radius: 2.61905, x: 0, y: -1.30952))
        .foregroundColor(Color("textSecondary"))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Taxa de serviço")
        .accessibilityValue("\(Int(percentage.rounded()))%, \(CurrencyHelper.accessibilityFormat(total * (percentage / 100)))")
    }
}
