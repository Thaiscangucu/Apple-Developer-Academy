import SwiftUI

// MARK: - Componente: Papel da Comanda

/// Componente que representa o papel da comanda.
/// Exibe os itens da conta em uma área rolável e mantém a taxa de serviço
/// e o total geral fixos na parte inferior.
struct ReceiptPaper: View {
    
    @Binding var items: [Product]
    @Binding var serviceFeePercentage: Double
    
    /// Valores já calculados pela View responsável pela comanda.
    let serviceFee: Double
    let grandTotal: Double

    /// Indica se a taxa de serviço foi removida (swipe na linha da taxa).
    /// Enquanto for `true`, a linha some da comanda.
    let isServiceFeeRemoved: Bool
    
    /// Ações executadas quando um item é excluído ou editado, ou quando
    /// a taxa de serviço é editada ou removida.
    let onDelete: (Product) -> Void
    let onEdit: (Product) -> Void
    let onEditServiceFee: () -> Void
    let onRemoveServiceFee: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        
        VStack{
            
            // MARK: - Área Rolável
            // Com texto grande as linhas ficam empilhadas e o cabeçalho de
            // colunas deixa de fazer sentido.
            if !typeSize.isAccessibilitySize {
                header
            }
            // Somente a lista de itens rola. A taxa de serviço e o total
            // permanecem fixos na parte inferior da comanda.
            
            ZStack{
                ScrollView(showsIndicators: false) {

                    if !typeSize.isAccessibilitySize {
                        HStack{
                            Text("Item")
                            Text("Qtd. x Un.")
                            Spacer()
                            Text("Vl. Item")
                        }
                        .font(.app(.caption2, weight: .medium))
                        .foregroundColor(.textSecondary)
                        // Alinhado com o texto dentro dos cards.
                        .padding(.horizontal, Self.textHorizontalInset)
                        .padding(.top, 70)
//                        .padding(.bottom, 40)
                        // Cabeçalho de colunas: cada linha já lê seus próprios valores.
                        .accessibilityHidden(true)
                    }

                        // Lista dos produtos
                        VStack(spacing: 16) {
                            ForEach($items) { $item in
                                
                                // Calcula a posição atual do item para exibir
                                // sua numeração no recibo.
                                let index =
                                (items.firstIndex(
                                    where: { $0.id == item.id }
                                ) ?? 0) + 1
                                
                                ReceiptItemRow(
                                    item: $item,
                                    index: index,
                                    onDelete: {
                                        onDelete(item)
                                    },
                                    onEdit: {
                                        onEdit(item)
                                    }
                                )
                                .transition(.asymmetric(insertion: .scale(scale: 0.95).combined(with: .opacity), removal: .opacity.combined(with: .move(edge: .leading))))
                            }
                        }
                        .padding(.horizontal, Self.rowHorizontalInset)
                        
                        // Espaço após o último item para separá-lo da área fixa
                        // de taxa e total.
                        .padding(.bottom, 14)
                        .padding(.top, 14)

                    // Texto grande: taxa e total entram na rolagem, senão
                    // a área fixa ocupa quase todo o papel.
                    if typeSize.isAccessibilitySize {
                        footer
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            
            
            // MARK: - Área Fixa

            // Taxa de serviço e total permanecem fora do ScrollView,
            // garantindo que continuem visíveis enquanto os itens rolam.
            if !typeSize.isAccessibilitySize {
                footer
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
        // Define a largura visual do papel da comanda. O degradê do topo
        // (BillView) e a fenda da impressora (PrinterBar) usam a mesma medida.
        .padding(.horizontal, Self.paperHorizontalInset)
        
        // Anima alterações na lista de itens, como adição e remoção.
        .animation(.easeInOut(duration: 0.3), value: items)
    }
    
    /// Distância entre a borda da tela e a borda do papel da notinha.
    /// Também define a largura do degradê do topo e da fenda da impressora,
    /// para os três ficarem sempre alinhados.
    static let paperHorizontalInset: CGFloat = 29

    /// Quanto a fenda da impressora passa do papel de cada lado (o papel
    /// "sai de dentro" da fenda).
    static let printerSlotOverhang: CGFloat = 5

    /// Espaço entre as bordas da notinha e os retângulos dos itens, da
    /// taxa de serviço e do total. Um valor só para os três ficarem alinhados.
    static let rowHorizontalInset: CGFloat = 14

    /// Distância entre a borda da notinha e o texto — tanto dos cabeçalhos
    /// ("Item  Qtd. x Un. … Vl. Item") quanto do texto dentro dos cards.
    /// É o que deixa as colunas alinhadas de cima a baixo.
    static let textHorizontalInset: CGFloat = 30

    /// Espaço entre a borda do card e o texto dentro dele, calculado para o
    /// texto cair exatamente em `textHorizontalInset`.
    static var cardContentPadding: CGFloat = 25

    var footer: some View {
        VStack(spacing: 10) {

            if !isServiceFeeRemoved {
                ServiceFeeRow(
                    percentage: $serviceFeePercentage,
                    calculatedFee: serviceFee,
                    onEdit: onEditServiceFee,
                    onRemove: onRemoveServiceFee
                )
                .padding(.horizontal, Self.rowHorizontalInset)
                .padding(.bottom, 10)
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            ReceiptTotalView(total: grandTotal)
                .padding(.horizontal, Self.rowHorizontalInset)
                .padding(.bottom, 37)
        }
        .padding(.top, 14)
    }

    var header: some View {
        // Cabeçalho que identifica as informações apresentadas
        // em cada linha do recibo.
        HStack {
            Text("Item   Qtd. x Un.")
                .font(.app(.caption2, weight: .medium))
            
            Spacer()
            
            Text("Vl. Item")
                .font(.app(.caption2, weight: .medium))
        }
        .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65)
.opacity(0.8))
        // Alinhado com o texto dentro dos cards.
        .padding(.horizontal, Self.textHorizontalInset)
        .padding(.top, 20)
        .padding(.bottom, 10)
        .accessibilityHidden(true)
    }
}
