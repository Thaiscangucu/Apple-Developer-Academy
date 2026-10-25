//
//  UserCircleForm.swift
//  EventsApp
//
//  Created by Thais Cangucu on 24/09/26.
//

import SwiftUI

struct MyCardView: View {
    var user: User
    
    var circleOpacity: Double = 1
    var onCircleFrameChange: (CGRect) -> Void = { _ in }
    
    // MARK: - TAMANHOS (ajuste aqui)

    /// Diâmetro do círculo no tamanho de texto normal.
    /// O iOS multiplica esse valor conforme o tamanho de texto escolhido
    /// nos Ajustes (é isso que o @ScaledMetric faz).
    @ScaledMetric(relativeTo: .body) private var scaledCircle: CGFloat = 85

    /// Diâmetro MÁXIMO do círculo nos tamanhos de acessibilidade.
    private let maxCircle: CGFloat = 110

    /// Tamanho do emoji em relação ao círculo (0.66 = 66% do círculo,
    /// que dá os 56pt de antes num círculo de 85).
    private let emojiScale: CGFloat = 0.66

    /// Diâmetro final: o escalado, limitado pelo máximo.
    private var circleSize: CGFloat { min(scaledCircle, maxCircle) }

    /// A pílula branca cresce na mesma proporção do círculo
    /// (159 x 55 quando o círculo tem 85).
    private var pillWidth: CGFloat { 159 * circleSize / 85 }
    private var pillHeight: CGFloat { 55 * circleSize / 85 }

    // MARK: -
    
    /// Espaço visível da pílula: da borda direita do círculo até o fim do retângulo
    private var textWidth: CGFloat { pillWidth - circleSize / 2 }
    
    var body: some View {
        HStack(spacing: 0) {
            // Círculo por cima, alinhado à esquerda
            Circle()
                .fill(user.color)
                .frame(width: circleSize, height: circleSize)
                .overlay {
                    Text(user.emoji)
                        .font(.system(size: circleSize * emojiScale))
                }
                .opacity(circleOpacity)
                .onGeometryChange(for: CGRect.self) { proxy in
                    proxy.frame(in: .global)
                } action: { frame in
                    onCircleFrameChange(frame)
                }
            
            // Largura fixa: o texto nunca passa do retângulo nem empurra o círculo
            Text(user.name)
                .font(.body)
                .foregroundStyle(Color(red: 0.36, green: 0.36, blue: 0.36))
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, 8)
                .frame(width: textWidth, alignment: .leading)
            
        }
        .background(alignment: .leading) {
            // Pílula começa no meio do círculo e termina no fim do texto
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .frame(width: pillWidth, height: pillHeight)
                .shadow(color: .black.opacity(0.2), radius: 1.6, x: 0, y: 1.6)
                .shadow(color: Color.shadowSoft.opacity(0.1), radius: 1.6, x: 0, y: -0.8)
                .padding(.leading, circleSize / 2)
        }
    }
}

// MARK: - Seção "Meu Card"

/// Seção "Meu Card" da sheet de participantes: mostra o card se ele já
/// foi criado; senão, o botão de "+" para criá-lo.
///
/// - Toque: adiciona você à conta.
/// - Toque longo: menu com "Editar" e "Excluir".
struct MyCardSection: View {
    @Environment(BillViewModel.self) private var vm
    
    /// ViewModel compartilhada com o AddUserFormView.
    var addUserVm: AddUserViewModel
    
    let isFlying: Bool
    
    /// Ações recebem o "Meu Card" salvo como parâmetro.
    let onTap: (User, CGRect) -> Void
    let onEdit: (User) -> Void
    let onDelete: (User) -> Void
    
    @State private var circleFrame: CGRect = .zero
    
    var body: some View {
        if let myCard = addUserVm.myCard {
            let isAlreadyAdded = addUserVm.isUserInBill(myCard, in: vm)
            
            MyCardView(
                user: myCard,
                circleOpacity: 1,
                onCircleFrameChange: { frame in
                    circleFrame = frame
                }
            )
            // Já está na conta: fica apagado, igual aos outros participantes.
            .opacity(isFlying || isAlreadyAdded ? 0.4 : 1)
            .allowsHitTesting(!isFlying)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap(myCard, circleFrame)
            }
            .contextMenu {
                Button {
                    onEdit(myCard)
                } label: {
                    Label("Editar", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    onDelete(myCard)
                } label: {
                    Label("Excluir", systemImage: "trash")
                }
            }
            // VoiceOver: um único botão "Meu card: Ana"; editar e excluir
            // (que ficam no toque longo) viram ações de deslizar.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Meu card: \(myCard.accessibilityName)"))
            .accessibilityValue(isAlreadyAdded ? Text("Já está na conta") : Text(verbatim: ""))
            .accessibilityHint(isAlreadyAdded ? Text(verbatim: "") : Text("Toque duas vezes para entrar na conta."))
            .accessibilityAddTraits(.isButton)
            .accessibilityAction {
                onTap(myCard, circleFrame)
            }
            .accessibilityAction(named: "Editar") {
                onEdit(myCard)
            }
            .accessibilityAction(named: "Excluir") {
                onDelete(myCard)
            }
            .transition(.scale(scale: 0.8).combined(with: .opacity))
            
        } else {
            Button {
                addUserVm.startMyCardForm()
            } label: {
                ZStack {
                    Circle()
                        .frame(width: 40)
                        .foregroundStyle(Color(red: 0.89, green: 0.89, blue: 0.9))
                    Image(systemName: "plus")
                }
            }
            .accessibilityLabel("Criar meu card")
            .accessibilityHint("Salva seus dados para entrar nas próximas contas com um toque.")
        }
    }
}

#Preview("Meu Card") {
    MyCardView(user: User(name: "Motta", emoji: "🌈", color: .red))
        .dynamicTypeSize(.accessibility5)
}

