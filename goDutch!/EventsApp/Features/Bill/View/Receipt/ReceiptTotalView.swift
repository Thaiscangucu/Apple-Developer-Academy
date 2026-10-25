import SwiftUI

// MARK: - Componente: Card Total

/// Exibe o valor total da conta em um card destacado no final da comanda.
struct ReceiptTotalView: View {

    /// Valor total que será exibido no card.
    let total: Double

    var body: some View {
        AdaptiveStack {

            // Identifica visualmente o valor como o total da conta.
            Text("TOTAL")
                .font(.app(.footnote, weight: .bold))

            Spacer()

            // Total com o símbolo da moeda do idioma (ex.: "R$ 120,00").
            Text(CurrencyHelper.formatWithSymbol(total))
                .font(.app(.footnote, weight: .bold))
            
        }
        .frame(minHeight: 25)
        .foregroundColor(.appText)
        // Texto alinhado com o cabeçalho da notinha.
        .padding(.horizontal, ReceiptPaper.cardContentPadding)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2).foregroundStyle(Color("surfaceMuted")))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Total da conta")
        .accessibilityValue(CurrencyHelper.accessibilityFormat(total))
        
    }
}
