//
//  UserCircleForm.swift
//  EventsApp
//
//  Created by Thais Cangucu on 24/09/26.
//

import SwiftUI

/// Participante já salvo exibido na grade do AddUserForm:
/// círculo colorido com o emoji e o nome embaixo.
///
/// - Toque: adiciona o participante à conta.
/// - Toque longo: menu com "Editar" e "Excluir".
struct UserCircleForm: View {
    let user: User
    let isAlreadyAdded: Bool

    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    let isFlying: Bool

    @Environment(\.dynamicTypeSize) private var typeSize
    let onCircleFrameChange: (CGRect) -> Void

    // MARK: - TAMANHOS (ajuste aqui)

    /// Diâmetro do círculo no tamanho de texto normal (vem do init, padrão 80).
    /// O iOS multiplica esse valor conforme o tamanho de texto escolhido
    /// nos Ajustes (é isso que o @ScaledMetric faz).
    @ScaledMetric private var scaledDiameter: CGFloat

    /// Diâmetro MÁXIMO do círculo nos tamanhos de acessibilidade.
    /// A grade tem 3 colunas, então acima de ~100 os círculos se encostam.
    private let maxDiameter: CGFloat = 100

    /// Tamanho do emoji em relação ao círculo (0.56 = 56% do círculo,
    /// que dá os 45pt de antes num círculo de 80).
    private let emojiScale: CGFloat = 0.50

    /// Diâmetro final: o escalado, limitado pelo máximo.
    private var diameter: CGFloat { min(scaledDiameter, maxDiameter) }

    // MARK: -
    
    init(
        user: User,
        isAlreadyAdded: Bool,
        onTap: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        isFlying: Bool = false,
        onCircleFrameChange: @escaping (CGRect) -> Void = { _ in },
        diameter: CGFloat = 80
    ) {
        self.user = user
        self.isAlreadyAdded = isAlreadyAdded
        self.onTap = onTap
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.isFlying = isFlying
        self.onCircleFrameChange = onCircleFrameChange
        self._scaledDiameter = ScaledMetric(wrappedValue: diameter, relativeTo: .body)
    }

    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(user.color)
                .frame(width: diameter, height: diameter)
                .overlay {
                    Text(user.emoji)
                        .font(.system(size: diameter * emojiScale))
                }
                .onGeometryChange(for: CGRect.self) { proxy in
                    proxy.frame(in: .global)
                } action: { frame in
                    onCircleFrameChange(frame)
                }

            Text(user.name)
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color(red: 0.36, green: 0.36, blue: 0.36))
                // Texto grande: o nome pode quebrar em 2 linhas e, se ainda
                // não couber, diminui um pouco — em vez de mostrar só "Ana…".
                .lineLimit(typeSize.isAccessibilitySize ? 2 : 1)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(typeSize.isAccessibilitySize ? 0.6 : 1)
        }
        // Participante que já está na conta fica apagado.
        .opacity(isFlying || isAlreadyAdded ? 0.4 : 1)
        .allowsHitTesting(!isFlying)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        // Editar/excluir no toque longo (o arrasto lateral da antiga
        // OldUserRow não funciona bem numa grade).
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Editar", systemImage: "pencil")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Excluir", systemImage: "trash")
            }
        }
        // VoiceOver: um botão por participante salvo; editar e excluir
        // (que ficam no toque longo) viram ações de deslizar.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(user.accessibilityName)
        .accessibilityValue(isAlreadyAdded ? Text("Já está na conta") : Text(verbatim: ""))
        .accessibilityHint(isAlreadyAdded ? Text(verbatim: "") : Text("Toque duas vezes para adicionar à conta."))
        .accessibilityAddTraits(.isButton)
        .accessibilityAction {
            onTap()
        }
        .accessibilityAction(named: "Editar") {
            onEdit()
        }
        .accessibilityAction(named: "Excluir") {
            onDelete()
        }
    }
}

#Preview("Normal e texto grande (AX5)") {
    let user = User(name: "Ana", emoji: "🌈", color: .yellow)

    VStack(spacing: 40) {
        UserCircleForm(user: user, isAlreadyAdded: false, onTap: {}, onEdit: {}, onDelete: {})

        UserCircleForm(user: user, isAlreadyAdded: false, onTap: {}, onEdit: {}, onDelete: {})
            .dynamicTypeSize(.accessibility5)
    }
}
