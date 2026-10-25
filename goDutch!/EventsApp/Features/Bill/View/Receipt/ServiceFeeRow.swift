import SwiftUI

/// Exibe a taxa de serviço da conta, permitindo alterar a porcentagem
/// e mostrando o valor correspondente calculado.
///
/// Segue o mesmo padrão de swipe usado em `OldUserRow`/`ReceiptItemRow`:
/// deslizar a linha para a esquerda revela os botões circulares de
/// editar e excluir; tocar em excluir remove a taxa (o cálculo do total
/// passa a considerá-la como 0), e tocar em editar abre a sheet com o
/// stepper da porcentagem.
struct ServiceFeeRow: View {

    /// Porcentagem da taxa que pode ser alterada pelo usuário.
    @Binding var percentage: Double

    /// Valor da taxa calculado com base na porcentagem informada.
    let calculatedFee: Double

    let round: CGFloat = 32

    /// Opções de porcentagem disponíveis para seleção no Picker
    let options: [Double] = [0, 5, 10, 12, 15, 18, 20]

    /// Ação executada quando o usuário toca no botão de editar revelado
    /// pelo swipe — abre a sheet de edição da taxa.
    let onEdit: () -> Void

    /// Ação executada quando o usuário toca no botão de excluir revelado
    /// pelo swipe.
    let onRemove: () -> Void

    // Controlam a posição horizontal da linha durante o gesto de swipe
    // e se ela permanece aberta após o gesto terminar — mesmo padrão
    // usado em ReceiptItemRow/OldUserRow.
    @State private var dragOffset: CGFloat = 0
    @State private var isSwiped: Bool = false

    /// Escala dos botões de ação com o tamanho de texto (mesma regra do
    /// RowActionButton), para a área revelada caber os botões maiores.
    @ScaledMetric(relativeTo: .body) private var rawScale: CGFloat = 1

    // MARK: Botões de ação
    /// Tamanho de cada botão (editar / excluir).
    private let actionButtonSize: CGFloat = 40
    /// Espaço entre os dois botões.
    private let actionButtonSpacing: CGFloat = 8
    /// Distância entre o retângulo da taxa e o primeiro botão quando aberto.
    /// Diminua para os botões ficarem ainda mais colados.
    private let actionsGap: CGFloat = 6
    /// Recuo do botão de excluir em relação à borda direita, para ele não
    /// ser cortado pela curva do recorte arredondado da linha.
    private let actionsTrailingInset: CGFloat = 3

    /// Largura da área de ações revelada ao deslizar a linha (editar + excluir).
    /// Calculada a partir dos botões, para o retângulo parar logo antes deles.
    private var actionsWidth: CGFloat {
        let scale = min(rawScale, RowActionButton.maxScale)
        return (actionButtonSize * 2 + actionButtonSpacing) * scale + actionsGap + actionsTrailingInset
    }

    var body: some View {
        ZStack(alignment: .trailing) {

            // MARK: Ações (escondidas atrás do pill, reveladas pelo arrasto)
            // Mesmo visual usado em OldUserRow: botões circulares 56x56
            // com dupla sombra, em vez do retângulo nativo do .swipeActions.
            HStack(spacing: actionButtonSpacing * min(rawScale, RowActionButton.maxScale)) {
    
                RowActionButton(kind: .edit, size: actionButtonSize) {
                    closeSwipe()
                    onEdit()
                }

                // Ao contrário do editar, excluir não fecha o swipe antes —
                // a linha some direto de onde estava (ela é removida da
                // comanda em ReceiptPaper), o que fica mais natural do que
                // "fechar" e só depois desaparecer.
                RowActionButton(kind: .delete, size: actionButtonSize, action: onRemove)
            }
            .padding(.trailing, actionsTrailingInset)
            // Só aparece depois que a linha começou a deslizar — senão o
            // canto arredondado do pill branco por cima deixa um triângulo
            // dos botões vazando o tempo todo.
            .opacity(dragOffset == 0 ? 0 : 1)
            // No VoiceOver, editar/excluir viram ações da própria linha.
            .accessibilityHidden(true)

            // Conteúdo principal (o pill da taxa de serviço).
            AdaptiveStack {

                Text("Taxa Serviço")
                    .font(.app(.footnote, weight: .bold))

                Spacer()

                // Picker
                ServicePicker(percentage: $percentage)

                
                // Exibe o valor da taxa calculado a partir da porcentagem informada.
                Text(CurrencyHelper.formatWithSymbol(calculatedFee))
                  .font(.app(.footnote, weight: .bold))
            }
            // Texto alinhado com o cabeçalho da notinha e com os valores
            // dos itens.
            .padding(.horizontal, ReceiptPaper.cardContentPadding)
            .padding(.vertical, 4)
            .frame(minHeight: 45)
            .foregroundColor(.appText)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: round, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: round, style: .continuous).stroke(Color.gray.opacity(0.18), lineWidth: 1))
            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
            .contentShape(Rectangle())
            // VoiceOver: a linha inteira é um botão que abre a edição da taxa
            // (onde fica o seletor de porcentagem), com "Remover" como ação.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Taxa de serviço")
            .accessibilityValue("\(Int(percentage))%, \(CurrencyHelper.accessibilityFormat(calculatedFee))")
            .accessibilityHint("Toque duas vezes para editar a porcentagem. Mais ações disponíveis.")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction {
                onEdit()
            }
            .accessibilityAction(named: "Remover taxa de serviço") {
                onRemove()
                AccessibilityAnnouncer.announce(String(localized: "Taxa de serviço removida"))
            }

            // Desloca a linha horizontalmente conforme o usuário desliza
            // para revelar ou esconder os botões de ação.
            .offset(x: dragOffset)

            // Gesto de swipe personalizado para controlar a abertura das
            // ações — idêntico ao usado em ReceiptItemRow/OldUserRow.
            .simultaneousGesture(
                DragGesture(
                    minimumDistance: 15,
                    coordinateSpace: .local
                )
                .onChanged { value in

                    if value.translation.width < 0 {

                        // Ao continuar deslizando uma linha já aberta,
                        // considera também a largura da área de ações.
                        let translation = isSwiped
                            ? value.translation.width - actionsWidth
                            : value.translation.width

                        dragOffset = max(
                            translation,
                            -actionsWidth - 10
                        )

                    } else if isSwiped {

                        // Permite deslizar de volta para fechar as ações.
                        let translation =
                            -actionsWidth + value.translation.width

                        dragOffset = min(translation, 0)
                    }
                }
                .onEnded { value in

                    withAnimation(
                        .spring(
                            response: 0.3,
                            dampingFraction: 0.8
                        )
                    ) {
                        // Um deslize suficientemente longo mantém
                        // as ações visíveis.
                        if value.translation.width < -35 {
                            dragOffset = -actionsWidth
                            isSwiped = true

                        } else {
                            // Caso contrário, retorna a linha à posição original.
                            dragOffset = 0
                            isSwiped = false
                        }
                    }
                }
            )
        }
        // Recorta a linha inteira (conteúdo + botões atrás) no mesmo
        // arredondamento do pill branco, evitando que os botões apareçam
        // fora do contorno durante o pequeno overshoot da mola.
        .clipShape(RoundedRectangle(cornerRadius: round, style: .continuous))
        // Achata o ZStack numa única camada para a transição de remoção
        // aplicada em ReceiptPaper não separar o pill branco dos botões.
        .compositingGroup()
    }

    /// Fecha a área de ações revelada pelo swipe, usada ao tocar em editar
    /// para não deixar a linha aberta atrás da sheet.
    private func closeSwipe() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = 0
            isSwiped = false
        }
    }

}
#Preview {
    ServiceFeeRow(percentage: .constant(10.0), calculatedFee: 10, onEdit: {}, onRemove: {})
}
