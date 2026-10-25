import SwiftUI

// MARK: - Componente: Barra da Impressora

/// Componente visual que representa a parte frontal da impressora,
/// incluindo o corpo principal e a abertura por onde o recibo é impresso.
struct PrinterBar: View {

    /// Distância entre a borda da tela e o corpo da impressora.
    private let bodyInset: CGFloat = 16

    /// Altura do corpo da impressora.
    static let bodyHeight: CGFloat = 85

    /// Distância do topo da impressora até o meio da fenda. A fenda fica
    /// na parte de cima do corpo (e não no centro), como no protótipo.
    static let slotCenterY: CGFloat = 30

    /// Onde o papel começa a aparecer (logo abaixo do meio da fenda).
    /// Usado pela máscara do papel e pelo gradiente de sombra na BillView.
    static let paperExitY: CGFloat = slotCenterY + 1

    /// Distância entre o corpo da impressora e a fenda, calculada para a
    /// fenda ficar um pouco mais larga que o papel da notinha
    /// (`ReceiptPaper.printerSlotOverhang` de cada lado).
    private var slotInset: CGFloat {
        max(ReceiptPaper.paperHorizontalInset - ReceiptPaper.printerSlotOverhang - bodyInset, 0)
    }

    var body: some View {
        ZStack {

            // Corpo externo da impressora, com gradiente para criar
            // profundidade e sombra para destacá-lo do fundo.
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(colors: [Color("printerBarTop"), Color("printerBarBottom")], startPoint: .top, endPoint: .bottom))
                .frame(height: PrinterBar.bodyHeight)
                .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)

            // Abertura escura da impressora, simulando a ranhura
            // por onde o papel do recibo sai.
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(LinearGradient(colors: [Color("printerSlotTop"), Color("printerSlotBottom")], startPoint: .top, endPoint: .bottom))
                .frame(height: 24)
                .padding(.horizontal, slotInset)
                // Borda escura reforça visualmente a profundidade da abertura.
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(Color.black.opacity(0.5), lineWidth: 1).padding(.horizontal, slotInset))
                // Sobe a fenda do centro do corpo para `slotCenterY`.
                .offset(y: PrinterBar.slotCenterY - PrinterBar.bodyHeight / 2)
        }
        .padding(.horizontal, bodyInset)
        // Puramente decorativo.
        .accessibilityHidden(true)
    }
}
