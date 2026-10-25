import SwiftUI

/// Representa uma linha de produto dentro do recibo.
/// Permite visualizar os dados do item, tocar para editá-lo e deslizar
/// para revelar a ação de exclusão.
struct ReceiptItemRow: View {

    @Binding var item: Product

    /// Posição do item no recibo, utilizada para exibir sua numeração.
    let index: Int

    /// Ações executadas quando o usuário exclui ou edita o item.
    let onDelete: () -> Void
    let onEdit: () -> Void

    // Controlam a posição horizontal da linha durante o gesto de swipe
    // e se ela permanece aberta após o gesto terminar.
    @State private var dragOffset: CGFloat = 0
    @State private var isSwiped: Bool = false

    /// Escala dos botões de ação com o tamanho de texto (mesma regra do
    /// RowActionButton).
    @ScaledMetric(relativeTo: .body) private var rawScale: CGFloat = 1
    private var actionScale: CGFloat { min(rawScale, RowActionButton.maxScale) }

    /// Largura da área de ações exibida ao deslizar o item (editar + excluir).
    private var actionsWidth: CGFloat { 126 * actionScale }

    var body: some View {
        ZStack(alignment: .trailing) {

            HStack(spacing: 8) {
                Spacer()

                Button {
                    closeSwipe()
                    onEdit()
                }
                label: {
                    ZStack {
                        RoundedRectangle(
                            cornerRadius: 18,
                            style: .continuous
                        )
                        .fill(Color("accentSlate"))
                        .frame(width: 58 * actionScale)

                        Image(systemName: "pencil")
                            .font(.system(size: 18 * actionScale, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    ZStack {
                        RoundedRectangle(
                            cornerRadius: 18,
                            style: .continuous
                        )
                        .fill(Color(red: 0.95, green: 0.28, blue: 0.28))
                        .frame(width: 58 * actionScale)

                        Image(systemName: "trash")
                            .font(.system(size: 18 * actionScale, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                .padding(.trailing, 2)
            }
            .opacity(dragOffset == 0 ? 0 : 1)
            .accessibilityHidden(true)

            // Conteúdo principal do item.
            VStack(alignment: .leading, spacing: 5) {

                // Número e nome do produto.
                HStack(alignment: .top, spacing: 4) {
                    Text(String(format: "%02d.", index))
                        .font(.app(.subheadline, weight: .bold))
                    
                    VStack(alignment: .leading, spacing: 4){
                        Text(item.name)
                            .font(.app(.subheadline, weight: .medium))
                        
                        // Quantidade, preço unitário e total do produto.
                        // Texto grande: quantidade e total ficam um embaixo do outro.
                        AdaptiveStack {
                            Text(
                                "\(item.quantity) Un. x \(CurrencyHelper.formatWithSymbol(item.price))"
                            )
                            .font(.app(.caption, weight: .regular))
                            
                            Spacer()
                            
                            // Mostra o valor total considerando a quantidade do item.
                            Text(CurrencyHelper.formatWithSymbol(item.total))
                                .font(.app(.subheadline, weight: .bold))
                                .foregroundColor(Color(red: 0.20, green: 0.25, blue: 0.30))
                        }
                    }
                }
            }
            .foregroundColor(.appText)
            // Texto alinhado com o cabeçalho da notinha.
            .padding(.horizontal, ReceiptPaper.cardContentPadding)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).stroke(Color.gray.opacity(0.18), lineWidth: 1))
            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
            .contentShape(Rectangle())

            // Um toque simples abre a edição, mas apenas quando
            // a ação de exclusão não estiver aberta.
            .onTapGesture {
                if !isSwiped {
                    onEdit()
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(item.accessibilitySummary(number: index))
            .accessibilityHint("Toque duas vezes para editar. Mais ações disponíveis.")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction {
                closeSwipe()
                onEdit()
            }
            .accessibilityAction(named: "Editar") {
                closeSwipe()
                onEdit()
            }
            .accessibilityAction(named: "Excluir") {
                // Lê o nome antes: depois de excluído, o binding deixa de existir.
                let name = item.name
                onDelete()
                AccessibilityAnnouncer.announce(String(localized: "Item excluído: \(name)"))
            }

            // Desloca a linha horizontalmente conforme o usuário desliza
            // para revelar ou esconder o botão de exclusão.
            .offset(x: dragOffset)

            // Gesto de swipe personalizado para controlar a abertura
            // da ação de exclusão.
            .simultaneousGesture(
                DragGesture(
                    minimumDistance: 15,
                    coordinateSpace: .local
                )
                .onChanged { value in

                    if value.translation.width < 0 {

                        // Ao continuar deslizando uma linha já aberta,
                        // considera também a largura do botão de exclusão.
                        let translation = isSwiped
                            ? value.translation.width - actionsWidth
                            : value.translation.width

                        dragOffset = max(
                            translation,
                            -actionsWidth - 10
                        )

                    } else if isSwiped {

                        // Permite deslizar de volta para fechar a ação.
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
                        // o botão de exclusão visível.
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
        // arredondamento do card branco. Sem isso, durante o "quique" final
        // da mola (dampingFraction 0.8 dá um pequeno overshoot) o retângulo
        // vermelho de excluir podia aparecer levemente fora do contorno
        // arredondado da linha por uma fração de segundo.
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        // Achata o ZStack (conteúdo branco + botões vermelho/azul) numa
        // única camada. Sem isso, a transição de inserção/remoção aplicada
        // em ReceiptPaper (.scale + .opacity) podia animar o botão vermelho
        // separado do card branco, causando um leve "pisca" do vermelho ao
        // adicionar ou excluir itens.
        .compositingGroup()
    }

    /// Fecha a área de ações revelada pelo swipe, usada ao tocar em editar
    /// para não deixar a linha aberta atrás do formulário.
    private func closeSwipe() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = 0
            isSwiped = false
        }
    }
}
