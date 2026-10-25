import SwiftUI

/// Tela somente-leitura com o detalhe de uma conta já fechada: os itens
/// que a compunham e quanto cada participante pagou.
struct HistoryDetailView: View {
    let savedBill: SavedBill

    /// Imagem PNG gerada sob demanda ao abrir a tela. Fica em `nil` só
    /// durante o instante da renderização — como cada conta costuma ter
    /// poucos itens, isso não chega a ser perceptível, mas o botão de
    /// compartilhar (na toolbar) só aparece depois de pronto.
    @State private var imageURL: URL?

    private var sortedItems: [SavedBillItem] {
        savedBill.items.sorted { $0.name < $1.name }
    }

    private var sortedUsers: [SavedBillUser] {
        savedBill.users.sorted { $0.amountPaid > $1.amountPaid }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dMMMMyyyyHHmm")
        return formatter
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(Self.dateFormatter.string(from: savedBill.date))
                    .font(.app(.footnote))
                    .foregroundColor(.gray)

                itemsCard

                if !sortedUsers.isEmpty {
                    participantsCard
                }

                totalsCard
            }
            .padding(20)
        }
        .background(Color("background").ignoresSafeArea())
        .navigationTitle("Detalhe da conta")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Gera a imagem aqui (não numa Task) porque ImageRenderer
            // precisa rodar na main thread.
            if imageURL == nil {
                imageURL = BillImageExporter.export(savedBill)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let imageURL {
                    ShareLink(
                        item: imageURL,
                        preview: SharePreview(
                            String(localized: "Conta - \(Self.dateFormatter.string(from: savedBill.date))")
                        )
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Compartilhar imagem da conta")
                } else {
                    ProgressView()
                        .accessibilityLabel("Gerando imagem")
                }
            }
        }
    }

    // MARK: - Itens

    private var itemsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ITENS")
                .font(.app(.caption2, weight: .medium))
                .foregroundColor(Color.gray.opacity(0.8))
                .padding(.bottom, 10)
                .accessibilityLabel("Itens")
                .accessibilityAddTraits(.isHeader)

            ForEach(Array(sortedItems.enumerated()), id: \.element.id) { index, item in
                AdaptiveStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.app(.subheadline, weight: .semibold))
                            .foregroundColor(Color(red: 0.25, green: 0.30, blue: 0.35))

                        Text("\(item.quantity) Un. x \(CurrencyHelper.format(item.price))")
                            .font(.app(.caption, weight: .medium))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Text(CurrencyHelper.format(item.total))
                        .font(.app(.subheadline, weight: .bold))
                        .foregroundColor(Color(red: 0.20, green: 0.25, blue: 0.30))
                }
                .padding(.vertical, 8)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: item.name))
                .accessibilityValue(Text("Quantidade \(item.quantity), \(CurrencyHelper.accessibilityFormat(item.price)) cada, total \(CurrencyHelper.accessibilityFormat(item.total))"))

                if index != sortedItems.count - 1 {
                    Divider()
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 2)
    }

    // MARK: - Participantes

    private var participantsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("QUEM PAGOU O QUÊ")
                .font(.app(.caption2, weight: .medium))
                .foregroundColor(Color.gray.opacity(0.8))
                .padding(.bottom, 10)
                .accessibilityLabel("Quem pagou o quê")
                .accessibilityAddTraits(.isHeader)

            ForEach(Array(sortedUsers.enumerated()), id: \.element.id) { index, user in
                AdaptiveStack(spacing: 10) {
                    HStack(spacing: 10) {
                        Text(user.emoji)
                            .font(.system(size: 16))
                            .frame(width: 30, height: 30)
                            .background(user.color)
                            .clipShape(Circle())

                        Text(user.name)
                            .font(.app(.subheadline, weight: .semibold))
                            .foregroundColor(Color(red: 0.25, green: 0.30, blue: 0.35))
                    }

                    Spacer()

                    Text(CurrencyHelper.format(user.amountPaid))
                        .font(.app(.subheadline, weight: .bold))
                        .foregroundColor(Color(red: 0.20, green: 0.25, blue: 0.30))
                }
                .padding(.vertical, 8)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: user.name))
                .accessibilityValue(Text("Pagou \(CurrencyHelper.accessibilityFormat(user.amountPaid))"))

                if index != sortedUsers.count - 1 {
                    Divider()
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 2)
    }

    // MARK: - Totais

    private var totalsCard: some View {
        VStack(spacing: 10) {
            AdaptiveStack {
                Text("Subtotal")
                    .font(.app(.footnote, weight: .bold))
                    .foregroundColor(Color("textSecondary"))

                Spacer()

                Text(CurrencyHelper.format(savedBill.subtotal))
                    .font(.app(.footnote, weight: .bold))
                    .foregroundColor(Color("textSecondary"))
            }
            .accessibilityElement(children: .combine)

            AdaptiveStack {
                Text("Taxa Serviço (\(Int(savedBill.serviceFeePercentage))%)")
                    .font(.app(.footnote, weight: .bold))
                    .foregroundColor(Color("textSecondary"))

                Spacer()

                Text(CurrencyHelper.format(savedBill.grandTotal - savedBill.subtotal))
                    .font(.app(.footnote, weight: .bold))
                    .foregroundColor(Color("textSecondary"))
            }
            .accessibilityElement(children: .combine)

            AdaptiveStack {
                Text("TOTAL")
                    .font(.app(.footnote, weight: .bold))
                    .foregroundColor(Color("textSecondary"))

                Spacer()

                Text(CurrencyHelper.format(savedBill.grandTotal))
                    .font(.app(.footnote, weight: .bold))
                    .foregroundColor(Color("textSecondary"))
            }
            .accessibilityElement(children: .combine)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2).foregroundStyle(Color("surfaceMuted")))
    }
}

#Preview {
    NavigationStack {
        HistoryDetailView(
            savedBill: SavedBill(
                serviceFeePercentage: 10,
                subtotal: 100,
                grandTotal: 110
            )
        )
    }
}
