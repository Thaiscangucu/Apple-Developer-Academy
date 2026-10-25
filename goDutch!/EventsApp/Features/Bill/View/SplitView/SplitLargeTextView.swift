//
//  SplitLargeTextView.swift
//  EventsApp
//
//  Versão da tela de divisão para os tamanhos de texto de acessibilidade.
//
//  O honeycomb (SpriteKit) e os cards têm geometria fixa e não conseguem
//  crescer com o texto. Nesses tamanhos a tela vira uma lista simples:
//  cada item mostra as pessoas como botões de marcar/desmarcar — o mesmo
//  resultado de arrastar as bolhas até o card.
//

import SwiftUI

struct SplitLargeTextView: View {
    @Environment(BillViewModel.self) private var billViewModel

    /// Chamado ao tocar em "Concluir divisão" (a SplitView mostra o
    /// mesmo alerta de confirmação do botão de check).
    let onConclude: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Hora de **dividir** os valores!")
                    .font(.app(.title))
                    .accessibilityAddTraits(.isHeader)

                Text("Marque quem consumiu cada item.")
                    .font(.app(.subheadline))
                    .foregroundStyle(Color("textSecondary"))

                ForEach(Array(billViewModel.bill.items.enumerated()), id: \.element.id) { index, product in
                    itemSection(product, number: index + 1)
                }

                RecButton(
                    title: "Concluir divisão",
                    backgroundColor: Color("accentSlate"),
                    foregroundColor: .white,
                    action: onConclude
                )
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(Color("background").ignoresSafeArea())
    }

    // MARK: - Item

    private func itemSection(_ product: Product, number: Int) -> some View {
        let users = billViewModel.bill.users
        let everyoneIn = !users.isEmpty && users.allSatisfy { product.assignedUserIDs.contains($0.id) }

        return VStack(alignment: .leading, spacing: 12) {
            // Cabeçalho do item: nome, quantidade e valor.
            VStack(alignment: .leading, spacing: 4) {
                Text("\(number). \(product.name)")
                    .font(.app(.title3, weight: .semibold))

                Text("\(product.quantity) Un. x \(CurrencyHelper.format(product.price))")
                    .font(.app(.footnote, weight: .medium))
                    .foregroundStyle(.gray)

                Text(CurrencyHelper.format(product.total))
                    .font(.app(.body, weight: .bold))
            }
            .foregroundStyle(Color("textSecondary"))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(product.accessibilitySummary(number: number))
            .accessibilityAddTraits(.isHeader)

            // Uma linha por pessoa.
            ForEach(users) { user in
                personRow(user, in: product)
            }

            // Atalho: todo mundo dividiu esse item.
            Button {
                toggleEveryone(in: product, everyoneIn: everyoneIn)
            } label: {
                Text(everyoneIn ? "Remover todas as pessoas" : "Todas as pessoas")
                    .font(.app(.subheadline, weight: .semibold))
                    .foregroundStyle(Color("accentSlate"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
    }

    // MARK: - Pessoa

    private func personRow(_ user: User, in product: Product) -> some View {
        let isAssigned = product.assignedUserIDs.contains(user.id)

        return Button {
            toggle(user, in: product, isAssigned: isAssigned)
        } label: {
            HStack(spacing: 12) {
                LargeTextAvatar(user: user)

                Text(user.name)
                    .font(.app(.body, weight: .medium))
                    .foregroundStyle(Color("textSecondary"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: isAssigned ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isAssigned ? Color("accentSlate") : Color.gray.opacity(0.5))
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(verbatim: user.accessibilityName))
        .accessibilityAddTraits(isAssigned ? .isSelected : [])
        .accessibilityHint(isAssigned ? Text("Toque duas vezes para tirar do item.") : Text("Toque duas vezes para colocar no item."))
    }

    // MARK: - Ações

    private func toggle(_ user: User, in product: Product, isAssigned: Bool) {
        if isAssigned {
            billViewModel.unassignUser(user.id, fromProductID: product.id)
        } else {
            billViewModel.assignUser(user.id, toProductID: product.id)
        }
    }

    private func toggleEveryone(in product: Product, everyoneIn: Bool) {
        if everyoneIn {
            billViewModel.unassignAllUsers(fromProductID: product.id)
        } else {
            for user in billViewModel.bill.users where !product.assignedUserIDs.contains(user.id) {
                billViewModel.assignUser(user.id, toProductID: product.id)
            }
        }
    }
}

#Preview {
    let vm = BillViewModel()
    let ana = User(name: "Ana", emoji: "🌈", color: .yellow)
    let bruno = User(name: "Bruno", emoji: "🎈", color: .green)
    vm.bill.users = [ana, bruno]
    vm.bill.items = [
        Product(name: "Cerveja", price: 16.50, quantity: 7, assignedUserIDs: [ana.id]),
        Product(name: "Batata frita", price: 70.00, quantity: 1)
    ]

    return NavigationStack {
        SplitLargeTextView(onConclude: {})
    }
    .environment(vm)
    .dynamicTypeSize(.accessibility5)
}
