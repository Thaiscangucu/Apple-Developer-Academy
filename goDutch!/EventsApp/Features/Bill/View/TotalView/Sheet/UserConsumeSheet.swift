import SwiftUI

struct UserConsumeSheet: View {
    @Environment(BillViewModel.self) private var billViewModel

    var user: User

    /// Pessoas cujo consumo `user` também vai pagar (cards juntados).
    var coveredUsers: [User] = []

    /// Quem `user` ainda pode passar a cobrir (menu "Pagar também por…").
    var coverCandidates: [User] = []

    /// `user` passa a pagar também o consumo da pessoa escolhida.
    var onCover: ((User) -> Void)? = nil

    /// A pessoa sai do grupo e volta a pagar só o dela.
    var onSplit: ((User) -> Void)? = nil

    /// Marca a pessoa como paga sem arrastar o card (usado quando o
    /// VoiceOver ou o Controle Assistivo estão ligados).
    var onMarkAsPaid: (() -> Void)? = nil

    /// `false` quando o card da pessoa já aparece em destaque acima da
    /// sheet (TotalView): o nome não se repete no topo da sheet.
    var showsTitle: Bool = true

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.accessibilitySwitchControlEnabled) private var switchControlEnabled

    /// Arrastar o card até "Pago" não funciona com VoiceOver/Controle
    /// Assistivo nem na versão em lista (texto grande), então aparece um botão.
    private var showsMarkAsPaidButton: Bool {
        // Com texto grande a TotalView vira lista (sem arrasto), então
        // o botão também aparece.
        onMarkAsPaid != nil && (voiceOverEnabled || switchControlEnabled || typeSize.isAccessibilitySize)
    }
    
    /// `user` e quem ele cobre: todo mundo cujo consumo entra nesta conta.
    private var members: [User] { [user] + coveredUsers }

    var body: some View {
        NavigationStack {
            VStack{
                ScrollView {
                    LazyVStack(spacing: 21) {
                        if coveredUsers.isEmpty {
                            // Usa bill.items (fonte da verdade) em vez de user.items,
                            // que pode ter cópias desatualizadas dos itens.
                            ForEach(billViewModel.items(for: user)) { item in
                                ConsumeDetails(item: item)
                            }
                        } else {
                            // Cards juntados: o consumo de cada pessoa
                            // aparece separado, com o nome em cima.
                            ForEach(members) { member in
                                memberSection(member)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 8)
                    .padding(.bottom, 8)

                    if typeSize.isAccessibilitySize {
                        footer
                    }
                }
                
                // Taxa e total ficam fixos embaixo; com texto grande eles
                // entram na rolagem (senão ocupam a sheet quase inteira).
                if !typeSize.isAccessibilitySize {
                    footer
                }
            }
            // Nome do usuário no topo da sheet (inline pra não ocupar
            // espaço da sheet, que tem altura fixa de 514).
            .navigationTitle(showsTitle ? user.name : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                if !showsTitle {
                    // Sem nome visível, mas o VoiceOver ainda lê de quem é.
                    ToolbarItem(placement: .principal) {
                        Color.clear
                            .frame(width: 1, height: 1)
                            .accessibilityElement()
                            .accessibilityLabel(user.name)
                            .accessibilityAddTraits(.isHeader)
                    }
                }

//                if let onCover, !coverCandidates.isEmpty {
//                    ToolbarItem(placement: .topBarLeading) {
//                        Menu {
//                            Section("Pagar também por…") {
//                                ForEach(coverCandidates) { other in
//                                    Button {
//                                        onCover(other)
//                                    } label: {
//                                        Text(verbatim: "\(other.emoji) \(other.name)")
//                                    }
//                                }
//                            }
//                        } label: {
//                            Image(systemName: "person.crop.circle.badge.plus")
//                                .font(.system(size: 17, weight: .semibold))
//                                .foregroundColor(.secondary)
//                        }
//                        .accessibilityLabel("Pagar também por outra pessoa")
//                    }
//                }

                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        dismiss()}
                    label:{
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Fechar")
                }
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 20) {
            ServiceFeeCardView(
                percentage: billViewModel.bill.isServiceFeeRemoved ? 0 : billViewModel.bill.serviceFeePercentage,
                total: members.reduce(0) { $0 + billViewModel.total(for: $1) }
            )
            TotalCardView(
                value: members.reduce(0) { $0 + billViewModel.totalWithServiceFee(for: $1) }
            )

            if showsMarkAsPaidButton {
                RecButton(
                    title: "Marcar como pago",
                    backgroundColor: Color("accentSlate"),
                    foregroundColor: .white
                ) {
                    onMarkAsPaid?()
                }
                .accessibilityHint("Conta o valor desta pessoa como pago e fecha esta tela.")
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
        .padding(.top, 4)
    }

    // MARK: - Cards juntados

    @ViewBuilder
    private func memberSection(_ member: User) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Circle()
                    .fill(member.color)
                    .frame(width: 36, height: 36)
                    .overlay {
                        Text(member.emoji)
                            .font(.system(size: 22))
                    }
                    .accessibilityHidden(true)

                Text(member.name)
                    .font(.app(.subheadline, weight: .semibold))
                    .foregroundStyle(Color("textSecondary"))
                    .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 8)

                // Quem foi juntado pode sair do grupo e voltar a pagar só o
                // dele (o total de cada um aparece nos cards acima da sheet).
                if member.id != user.id, let onSplit {
                    Button {
                        onSplit(member)
                    } label: {
                        Image(systemName: "person.crop.circle.badge.minus")
                            .font(.system(size: 22))
                            .foregroundStyle(Color("textSecondary").opacity(0.6))
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("Remover \(member.name) do grupo"))
                    .accessibilityHint("\(member.name) volta a pagar só o próprio consumo.")
                }
            }
            // Bolinha e nome alinhados com o texto dos itens; o botão de
            // remover alinhado com o valor à direita.
            .padding(.leading, 16)
            .padding(.trailing, 4)

            let items = billViewModel.items(for: member)
            if items.isEmpty {
                Text("Sem itens")
                    .font(.app(.footnote))
                    .foregroundStyle(Color("textSecondary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(items) { item in
                    ConsumeDetails(item: item)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Consumo do usuário") {
    // Usuários mockados
    var thais = User(name: "Thais", emoji: "🌈", color: .yellow)
    let motta = User(name: "Motta", emoji: "🎈", color: .green)

    // Itens mockados (alguns divididos, outros só da Thais)
    let items: [Product] = [
        Product(name: "Cerveja", price: 16.50, quantity: 7, assignedUserIDs: [thais.id, motta.id]),
        Product(name: "Batata frita", price: 70, quantity: 1, assignedUserIDs: [thais.id]),
        Product(name: "Refrigerante", price: 8, quantity: 2, assignedUserIDs: [thais.id]),
        Product(name: "Porção de pastel", price: 45, quantity: 1, assignedUserIDs: [thais.id, motta.id])
    ]
    thais.items = items.filter { $0.assignedUserIDs.contains(thais.id) }

    // Conta mockada
    let billViewModel = BillViewModel()
    billViewModel.bill.users = [thais, motta]
    billViewModel.bill.items = items
    billViewModel.bill.serviceFeePercentage = 10

    // Apresenta como sheet, com os mesmos modificadores da TotalView
    return Color("surfaceLight")
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            UserConsumeSheet(user: thais)
                .presentationDetents([.height(514)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(34)
                .presentationBackgroundInteraction(.disabled)
                .presentationBackground(.regularMaterial)
        }
        .environment(billViewModel)
}

