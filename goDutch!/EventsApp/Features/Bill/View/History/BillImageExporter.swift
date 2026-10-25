import SwiftUI
import UIKit

/// Gera uma imagem PNG de uma conta já finalizada, no estilo de um recibo,
/// para o usuário exportar/compartilhar (ex.: mandar no WhatsApp ou salvar
/// nas Fotos).
enum BillImageExporter {

    /// Renderiza a `savedBill` como PNG (a altura se ajusta à quantidade
    /// de itens/participantes) e escreve num arquivo temporário.
    ///
    /// Precisa rodar na main thread porque `ImageRenderer` é `@MainActor`
    /// — por isso é chamado a partir de `.onAppear`, não de uma `Task`.
    @MainActor
    static func export(_ savedBill: SavedBill) -> URL? {
        let pageWidth: CGFloat = 380

        let page = BillExportPage(savedBill: savedBill)
            .frame(width: pageWidth, alignment: .leading)

        let renderer = ImageRenderer(content: page)
        renderer.proposedSize = ProposedViewSize(width: pageWidth, height: nil)
        // Pelo menos 3x para a imagem ficar nítida ao dar zoom.
        renderer.scale = max(UIScreen.main.scale, 3)
        renderer.isOpaque = true

        guard let data = renderer.uiImage?.pngData() else { return nil }

        let fileName = "conta-\(savedBill.id.uuidString).png"
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)

        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            print("Erro ao salvar imagem da conta: \(error)")
            return nil
        }
    }
}

// MARK: - Layout da imagem

/// Layout da conta exportada: cabeçalho, itens, totais e quem pagou o
/// quê. Separado da `HistoryDetailView` de propósito — essa aqui não
/// tem sombra/cards, é pensada pra ficar legível como imagem compartilhada.
private struct BillExportPage: View {
    let savedBill: SavedBill

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dMMMMyyyyHHmm")
        return formatter
    }()

    private var sortedItems: [SavedBillItem] {
        savedBill.items.sorted { $0.name < $1.name }
    }

    private var sortedUsers: [SavedBillUser] {
        savedBill.users.sorted { $0.amountPaid > $1.amountPaid }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            // MARK: Cabeçalho
            VStack(alignment: .leading, spacing: 4) {
                Text("go**Dutch!**")
                    .font(Font.custom("MontserratAlternates-Medium", size: 22))

                Text(Self.dateFormatter.string(from: savedBill.date))
                    .font(Font.custom("MontserratAlternates-Regular", size: 12))
                    .foregroundColor(.gray)
            }

            Divider()

            // MARK: Itens
            VStack(alignment: .leading, spacing: 10) {
                Text("ITENS")
                    .font(Font.custom("Montserrat Alternates", size: 11).weight(.medium))
                    .foregroundColor(.gray)

                ForEach(sortedItems) { item in
                    HStack(alignment: .top) {
                        Text("\(item.quantity)x \(item.name)")
                            .font(Font.custom("Montserrat Alternates", size: 13))

                        Spacer()

                        Text(CurrencyHelper.format(item.total))
                            .font(Font.custom("Montserrat Alternates", size: 13).weight(.semibold))
                    }
                }
            }

            Divider()

            // MARK: Totais
            VStack(spacing: 6) {
                totalRow("Subtotal", CurrencyHelper.format(savedBill.subtotal))
                totalRow(
                    "Taxa de serviço (\(Int(savedBill.serviceFeePercentage))%)",
                    CurrencyHelper.format(savedBill.grandTotal - savedBill.subtotal)
                )
                totalRow("TOTAL", CurrencyHelper.format(savedBill.grandTotal), emphasized: true)
            }

            // MARK: Participantes
            if !sortedUsers.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("QUEM PAGOU O QUÊ")
                        .font(Font.custom("Montserrat Alternates", size: 11).weight(.medium))
                        .foregroundColor(.gray)

                    ForEach(sortedUsers) { user in
                        HStack {
                            Text("\(user.emoji) \(user.name)")
                                .font(Font.custom("Montserrat Alternates", size: 13))

                            Spacer()

                            Text(CurrencyHelper.format(user.amountPaid))
                                .font(Font.custom("Montserrat Alternates", size: 13).weight(.semibold))
                        }
                    }
                }
            }
        }
        .padding(28)
        .frame(alignment: .leading)
        .background(Color.white)
        .foregroundColor(.black)
    }

    private func totalRow(_ label: LocalizedStringKey, _ value: String, emphasized: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(Font.custom("Montserrat Alternates", size: emphasized ? 14 : 13).weight(emphasized ? .bold : .regular))

            Spacer()

            Text(value)
                .font(Font.custom("Montserrat Alternates", size: emphasized ? 14 : 13).weight(emphasized ? .bold : .regular))
        }
    }
}
