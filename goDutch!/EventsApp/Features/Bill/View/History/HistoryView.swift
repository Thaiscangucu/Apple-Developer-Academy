import SwiftUI
import SwiftData

/// Tela que lista as contas já fechadas e guardadas no histórico,
/// permitindo abrir o detalhe de cada uma ou excluí-la.
///
/// Excluir várias: igual aos apps nativos do iPhone (Fotos, Arquivos,
/// Notas) — "Selecionar" no canto entra no modo de seleção, com
/// "Selecionar tudo" e o botão de excluir na barra de baixo.
///
/// É empurrada dentro do `NavigationStack` raiz (ver `ContentView`), então
/// não cria a própria stack — assim o botão de voltar padrão continua
/// funcionando normalmente, igual nas outras telas do fluxo.
struct HistoryView: View {
    @Binding var path: NavigationPath

    /// Contas salvas no SwiftData, da mais recente para a mais antiga.
    @Query(sort: \SavedBill.date, order: .reverse)
    private var savedBills: [SavedBill]

    @Environment(\.modelContext) private var modelContext

    // MARK: - Seleção múltipla

    /// Modo de seleção (o mesmo `editMode` que os apps nativos usam: mostra
    /// as bolinhas de seleção à esquerda de cada linha).
    @State private var editMode: EditMode = .inactive
    /// Contas marcadas no modo de seleção.
    @State private var selection = Set<SavedBill.ID>()
    /// Confirmação antes de excluir as contas marcadas.
    @State private var showDeleteConfirmation = false

    private var isSelecting: Bool { editMode.isEditing }

    private var allSelected: Bool {
        !savedBills.isEmpty && selection.count == savedBills.count
    }

    var body: some View {
        Group {
            if savedBills.isEmpty {
                emptyState
            } else {
                List(selection: $selection) {
                    ForEach(savedBills) { savedBill in
                        row(for: savedBill)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    delete([savedBill])
                                } label: {
                                    Label("Excluir", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.editMode, $editMode)
            }
        }
        .background(Color("background").ignoresSafeArea())
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        // No modo de seleção, o voltar dá lugar ao "Selecionar tudo".
        .navigationBarBackButtonHidden(isSelecting)
        .toolbar { toolbarContent }
        .toolbar(isSelecting ? .visible : .hidden, for: .bottomBar)
        .confirmationDialog(
            deleteConfirmationTitle,
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(deleteButtonTitle, role: .destructive) {
                deleteSelected()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Essa ação não pode ser desfeita.")
        }
        // Se a lista esvaziar (ex.: excluiu tudo), sai do modo de seleção.
        .onChange(of: savedBills.isEmpty) { _, isEmpty in
            if isEmpty { exitSelection() }
        }
    }

    // MARK: - Linha

    /// Fora do modo de seleção a linha é um botão que abre o detalhe; no
    /// modo de seleção o toque marca/desmarca (feito pela própria List).
    @ViewBuilder
    private func row(for savedBill: SavedBill) -> some View {
        if isSelecting {
            HistoryBillRow(savedBill: savedBill)
                .contentShape(Rectangle())
        } else {
            Button {
                path.append(Rota.historyDetail(savedBill))
            } label: {
                HistoryBillRow(savedBill: savedBill)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Toque duas vezes para ver os detalhes.")
        }
    }

    // MARK: - Barra de navegação

    private var navigationTitle: String {
        guard isSelecting else { return String(localized: "Histórico") }
        switch selection.count {
        case 0: return String(localized: "Selecionar contas")
        case 1: return String(localized: "1 conta selecionada")
        default: return String(localized: "\(selection.count) contas selecionadas")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if !savedBills.isEmpty {
            // Direita: "Selecionar" / "Cancelar", como em Fotos e Arquivos.
            ToolbarItem(placement: .topBarTrailing) {
                Button(isSelecting ? LocalizedStringKey("Cancelar") : LocalizedStringKey("Selecionar")) {
                    if isSelecting {
                        exitSelection()
                    } else {
                        withAnimation { editMode = .active }
                    }
                }
                .fontWeight(isSelecting ? .semibold : .regular)
            }
        }

        if isSelecting {
            // Esquerda: marcar/desmarcar todas de uma vez.
            ToolbarItem(placement: .topBarLeading) {
                Button(allSelected ? LocalizedStringKey("Desmarcar tudo") : LocalizedStringKey("Selecionar tudo")) {
                    withAnimation {
                        if allSelected {
                            selection.removeAll()
                        } else {
                            selection = Set(savedBills.map(\.id))
                        }
                    }
                }
            }

            // Barra de baixo: excluir as marcadas.
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
                .disabled(selection.isEmpty)
                .accessibilityLabel("Excluir contas selecionadas")
            }
        }
    }

    // MARK: - Estado vazio

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image("Bubble")
                .resizable()
                .scaledToFit()
                .frame(width: 160)
                .opacity(0.5)
                .accessibilityHidden(true)

            Text("Nenhuma conta por aqui ainda")
                .font(.app(.body, weight: .medium))
                .foregroundColor(Color(red: 0.22, green: 0.26, blue: 0.30))

            Text("Suas contas fechadas vão aparecer aqui, prontas pra consultar ou exportar depois.")
                .font(.app(.subheadline))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollsAtAccessibilitySizes()
        .accessibilityElement(children: .combine)
    }

    // MARK: - Ações

    private var deleteConfirmationTitle: String {
        selection.count == 1
            ? String(localized: "Excluir 1 conta?")
            : String(localized: "Excluir \(selection.count) contas?")
    }

    private var deleteButtonTitle: String {
        selection.count == 1
            ? String(localized: "Excluir 1 conta")
            : String(localized: "Excluir \(selection.count) contas")
    }

    /// Exclui as contas marcadas e sai do modo de seleção.
    private func deleteSelected() {
        let bills = savedBills.filter { selection.contains($0.id) }
        withAnimation {
            delete(bills)
        }
        exitSelection()
    }

    private func exitSelection() {
        withAnimation {
            editMode = .inactive
            selection.removeAll()
        }
    }

    /// Remove contas do histórico permanentemente.
    private func delete(_ bills: [SavedBill]) {
        guard !bills.isEmpty else { return }

        for bill in bills {
            selection.remove(bill.id)
            modelContext.delete(bill)
        }

        do {
            try modelContext.save()
        } catch {
            print("Erro ao excluir conta do histórico: \(error)")
        }

        // A linha só some da tela: o VoiceOver confirma em voz alta.
        AccessibilityAnnouncer.announce(
            bills.count == 1
                ? String(localized: "1 conta excluída")
                : String(localized: "\(bills.count) contas excluídas")
        )
    }
}

// MARK: - Card de uma conta na lista

/// Card resumido de uma conta salva: data, quantidade de itens/pessoas,
/// bolinhas dos participantes e o valor total.
private struct HistoryBillRow: View {
    let savedBill: SavedBill

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("dMMMM")
        return formatter
    }()

    var body: some View {
        AdaptiveStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(Self.dateFormatter.string(from: savedBill.date))
                    .font(.app(.subheadline, weight: .medium))
                    .foregroundColor(Color(red: 0.22, green: 0.26, blue: 0.30))

                Text("\(savedBill.items.count) itens · \(savedBill.users.count) pessoas")
                    .font(.app(.caption))
                    .foregroundColor(.gray)

                if !savedBill.users.isEmpty {
                    participantBubbles
                }
            }

            Spacer()

            Text(CurrencyHelper.format(savedBill.grandTotal))
                .font(.app(.callout, weight: .medium))
                .foregroundColor(Color(red: 0.20, green: 0.25, blue: 0.30))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.gray.opacity(0.18), lineWidth: 1))
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 2)
        // VoiceOver: "12 de setembro, 4 itens, 3 pessoas: Ana, Bruno e
        // Carla. Total R$ 180,00" — as bolinhas de emoji ficam de fora.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: Self.dateFormatter.string(from: savedBill.date)))
        .accessibilityValue(accessibilitySummary)
    }

    private var accessibilitySummary: Text {
        let names = savedBill.users.map(\.name).formatted(.list(type: .and))
        let total = CurrencyHelper.accessibilityFormat(savedBill.grandTotal)

        return Text("\(savedBill.items.count) itens, \(savedBill.users.count) pessoas: \(names). Total \(total)")
    }

    /// Bolinhas de emoji dos participantes, sobrepostas como um
    /// "stack" de avatares. Mostra no máximo 5 e resume o resto em "+N".
    private var participantBubbles: some View {
        HStack(spacing: -8) {
            ForEach(Array(savedBill.users.prefix(5))) { user in
                Text(user.emoji)
                    .font(.system(size: 12))
                    .frame(width: 24, height: 24)
                    .background(user.color)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
            }

            if savedBill.users.count > 5 {
                Text("+\(savedBill.users.count - 5)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Color.gray.opacity(0.6))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
            }
        }
        .padding(.top, 2)
    }
}

#Preview {
    NavigationStack {
        HistoryView(path: .constant(NavigationPath()))
    }
}
