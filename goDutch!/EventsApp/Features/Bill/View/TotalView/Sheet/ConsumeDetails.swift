import SwiftUI
 
struct ConsumeDetails: View {
    let item: Product
    @Environment(\.dynamicTypeSize) private var typeSize
 
    var body: some View {
        AdaptiveStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(item.quantity)x \(item.name)")
                    .font(.app(.subheadline, weight: .semibold))
                    // Texto grande: o nome pode quebrar linha em vez de cortar.
                    .lineLimit(typeSize.isAccessibilitySize ? nil : 1)
 
                // Parte do usuário no item: o valor total do item é dividido
                // igualmente entre as pessoas atribuídas (ver `pricePerAssignedUser`).
                // Ex.: 7 cervejas divididas entre 2 pessoas → "1/2 de R$ 115,50".
                HStack(spacing: 4) {
                    Text("1/\(max(item.assignedUserIDs.count, 1))")
                    Text(item.total, format: CurrencyHelper.formatStyle)

                }
                .font(.app(.footnote, weight: .medium))
            }
 
            Spacer()
 
            Text("\(item.pricePerAssignedUser.formatted(.number.precision(.fractionLength(2))))")
                .font(.app(.callout, weight: .bold))
        }
        .padding(.horizontal, 25)
        .adaptiveRelativeHeight(0.23)
        .background(Color.white.cornerRadius(31.42857).shadow(color: .black.opacity(0.2), radius: 2.61905, x: 0, y: 2.61905).shadow(color: Color("shadowSoft").opacity(0.1), radius: 2.61905, x: 0, y: -1.30952))
        .foregroundColor(Color("textSecondary"))
        // VoiceOver: "2x Cerveja. Dividido entre 2 pessoas, total R$ 33,00.
        // Sua parte: R$ 16,50" — em vez de "1/2" e números soltos.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(item.quantity)x \(item.name)"))
        .accessibilityValue(accessibilityShareDescription)
    }

    private var accessibilityShareDescription: Text {
        let share = CurrencyHelper.accessibilityFormat(item.pricePerAssignedUser)
        let people = item.assignedUserIDs.count

        guard people > 1 else {
            return Text("Sua parte: \(share)")
        }

        return Text("Dividido entre \(people) pessoas, total \(CurrencyHelper.accessibilityFormat(item.total)). Sua parte: \(share)")
    }
}
