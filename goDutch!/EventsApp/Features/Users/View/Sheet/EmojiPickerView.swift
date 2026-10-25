//
//  EmojiPickerView.swift
//  EventsApp
//
//  Created by Thais Cangucu on 24/08/26.
//

import SwiftUI

/// Exibe uma grade de emojis disponíveis e permite selecionar
/// um emoji para representar o participante.
struct EmojiPickerView: View {

    /// Emojis disponíveis para seleção.
    let emojis: [String]

    /// Emoji atualmente selecionado pelo usuário.
    @Binding var selectedEmoji: String

    // MARK: - TAMANHOS (ajuste aqui)

    /// Tamanho da bolinha de cada emoji no tamanho de texto normal.
    /// O iOS multiplica esse valor conforme o tamanho de texto escolhido
    /// nos Ajustes (é isso que o @ScaledMetric faz).
    @ScaledMetric(relativeTo: .body) private var scaledCell: CGFloat = 38

    /// Tamanho MÁXIMO da bolinha, para ela não crescer demais nos
    /// tamanhos de acessibilidade. Aumente para deixar crescer mais.
    private let maxCell: CGFloat = 64

    /// Tamanho do emoji em relação à bolinha (0.58 = 58% da bolinha).
    private let emojiScale: CGFloat = 0.58

    /// Tamanho final da bolinha: o escalado, limitado pelo máximo.
    private var cell: CGFloat { min(scaledCell, maxCell) }

    // MARK: -

    /// Colunas que se ajustam à largura do cartão: cabem quantas bolinhas
    /// couberem por linha e o resto desce para a linha de baixo. Antes eram
    /// 2 linhas fixas e, com o texto maior, os emojis passavam do cartão.
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: cell + 4), spacing: 8)]
    }

    var body: some View {

        LazyVGrid(columns: columns, spacing: 12) {

            // Cria um botão para cada emoji disponível.
            ForEach(emojis, id: \.self) { emoji in

                Button {
                    // Atualiza o emoji selecionado quando o usuário toca nele.
                    selectedEmoji = emoji

                } label: {

                    Text(emoji)
                        .font(.system(size: cell * emojiScale))
                        .frame(width: cell, height: cell)
                        .background {
                            Circle()
                                .fill(Color(red: 0.89, green: 0.89, blue: 0.89))
                        }
                        .overlay {

                            // Destaca visualmente o emoji atualmente selecionado.
                            if selectedEmoji == emoji {
                                Circle()
                                    .stroke(.blue, lineWidth: 3)
                                    .padding(-4)
                            }
                        }
                }
                .buttonStyle(.plain)
                // O VoiceOver já lê o nome do emoji; aqui só marca o escolhido.
                .accessibilityHint("Emoji do participante")
                .accessibilityAddTraits(selectedEmoji == emoji ? .isSelected : [])
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .containerRelativeFrame(.horizontal) { width, _ in
            width * 0.9
        }
        .background {
            Rectangle()
                .foregroundStyle(.white)
                .cornerRadius(20)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Emojis")
    }
}

#Preview {
    EmojiPickerView(
        emojis: [
            "🤓", "😎", "😇", "🥸", "🥳", "🧐",
            "👨🏻‍🔬", "🧑‍💻", "🎈", "🌈", "🐙", "🕹️"
        ],
        selectedEmoji: .constant("🌈")
    )
}

#Preview("Texto grande (AX5)") {
    EmojiPickerView(
        emojis: [
            "🤓", "😎", "😇", "🥸", "🥳", "🧐",
            "👨🏻‍🔬", "🧑‍💻", "🎈", "🌈", "🐙", "🕹️"
        ],
        selectedEmoji: .constant("🌈")
    )
    .dynamicTypeSize(.accessibility5)
}
