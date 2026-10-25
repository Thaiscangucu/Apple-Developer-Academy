//
//  TotalLargeTextView.swift
//  EventsApp
//
//  Versão da tela de total para os tamanhos de texto de acessibilidade.
//
//  O círculo de progresso (tamanho fixo, valor em 60pt) e os cards em
//  SpriteKit que se arrastam até "Pago" não crescem com o texto. Nesses
//  tamanhos a tela vira um resumo do quanto já foi pago + uma lista de
//  quem falta pagar, com um botão para marcar cada pessoa.
//

import SwiftUI

struct TotalLargeTextView: View {
    let users: [User]
    let userTotals: [UUID: Double]
    let paidUserIDs: Set<UUID>

    /// Abre a sheet de consumo da pessoa.
    let onSelect: (User) -> Void
    /// Marca a pessoa como paga.
    let onMarkAsPaid: (User) -> Void
    /// Marca todo mundo que falta como pago (mesmo botão "pagar todos"
    /// da tela normal; quem chama mostra a confirmação antes).
    var onPayAll: (() -> Void)? = nil

    private var target: Double { userTotals.values.reduce(0, +) }

    private var paid: Double {
        paidUserIDs.reduce(0) { $0 + (userTotals[$1] ?? 0) }
    }

    private var unpaidUsers: [User] { users.filter { !paidUserIDs.contains($0.id) } }
    private var paidUsers: [User] { users.filter { paidUserIDs.contains($0.id) } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                progressCard

                if !unpaidUsers.isEmpty {
                    sectionTitle("Falta pagar")

                    if unpaidUsers.count > 1, let onPayAll {
                        payAllButton(action: onPayAll)
                    }

                    ForEach(unpaidUsers) { user in
                        unpaidRow(user)
                    }
                }

                if !paidUsers.isEmpty {
                    sectionTitle("Já pagaram")
                    ForEach(paidUsers) { user in
                        paidRow(user)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
    }

    // MARK: - Progresso

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pago")
                .font(.app(.subheadline))

            Text(CurrencyHelper.format(paid))
                .font(.app(.largeTitle, weight: .semibold))
                .contentTransition(.numericText())

            Text("de \(CurrencyHelper.format(target))")
                .font(.app(.body, weight: .bold))

            ProgressView(value: target > 0 ? min(paid / target, 1) : 0)
                .tint(Color("accentSlateLight"))
                .padding(.top, 4)
                .accessibilityHidden(true)
        }
        .foregroundStyle(Color("textSecondary"))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color("surfaceMuted"), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pago")
        .accessibilityValue(Text("\(CurrencyHelper.accessibilityFormat(paid)) de \(CurrencyHelper.accessibilityFormat(target))"))
    }

    private func sectionTitle(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.app(.title3, weight: .semibold))
            .foregroundStyle(Color("textSecondary"))
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Linhas

    private func unpaidRow(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tocar no nome abre o consumo da pessoa (mesmo que tocar no card).
            Button {
                onSelect(user)
            } label: {
                personLabel(user)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Toque duas vezes para ver o consumo.")

            Button {
                onMarkAsPaid(user)
            } label: {
                Text("Marcar como pago")
                    .font(.app(.subheadline, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color("accentSlate"), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Marcar \(user.accessibilityName) como pago"))
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
    }

    private func payAllButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label("Marcar todos como pago", systemImage: "checkmark.circle")
                .font(.app(.subheadline, weight: .semibold))
                .foregroundStyle(Color("accentSlate"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .overlay {
                    Capsule().strokeBorder(Color("accentSlate"), lineWidth: 2)
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityHint("Marca como pago quem ainda falta pagar.")
    }

    private func paidRow(_ user: User) -> some View {
        HStack(spacing: 12) {
            personLabel(user)
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(Color("accentSlateLight"))
                .accessibilityHidden(true)
        }
        .opacity(0.6)
        .accessibilityElement(children: .combine)
        .accessibilityValue("Pago")
    }

    private func personLabel(_ user: User) -> some View {
        HStack(spacing: 12) {
            LargeTextAvatar(user: user)

            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.app(.body, weight: .medium))
                Text(CurrencyHelper.format(userTotals[user.id] ?? 0))
                    .font(.app(.body, weight: .bold))
            }
            .foregroundStyle(Color("textSecondary"))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    let ana = User(name: "Ana", emoji: "🌈", color: .yellow)
    let bruno = User(name: "Bruno", emoji: "🎈", color: .green)

    return TotalLargeTextView(
        users: [ana, bruno],
        userTotals: [ana.id: 42.5, bruno.id: 30],
        paidUserIDs: [bruno.id],
        onSelect: { _ in },
        onMarkAsPaid: { _ in },
        onPayAll: {}
    )
    .dynamicTypeSize(.accessibility5)
}
