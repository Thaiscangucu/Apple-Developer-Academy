//
//  ColorPickerView.swift
//  EventsApp
//
//  Created by Thais Cangucu on 24/08/26.
//

import SwiftUI

/// Exibe as cores disponíveis para representar um participante
/// e permite selecionar uma delas.
struct ColorPickerView: View {

    /// Cores que serão apresentadas no seletor.
    let colors: [Color]

    /// Cor atualmente selecionada pelo usuário.
    @Binding var selectedColor: Color

    /// Quantidade de cores exibidas em cada página.
    var colorsPerPage: Int = 6

    /// Página visível no momento (alimenta os pontinhos embaixo).
    @State private var currentPage: Int? = 0

    /// Divide as cores em páginas de `colorsPerPage` cores.
    private var pages: [[Color]] {
        stride(from: 0, to: colors.count, by: colorsPerPage).map {
            Array(colors[$0..<min($0 + colorsPerPage, colors.count)])
        }
    }

    var body: some View {

        // Rolagem horizontal com paginação: cada página ocupa a largura
        // inteira do cartão, então nenhuma cor fica cortada ao meio.
        ScrollView(.horizontal, showsIndicators: false) {

            HStack(spacing: 0) {

                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in

                    // Espaçamento de 7pt entre as cores (igual ao Figma).
                    HStack(spacing: 9) {

                        // Cria um botão para cada cor da página.
                        ForEach(Array(page.enumerated()), id: \.offset) { _, color in
                            colorButton(color)
                        }

                        // Completa a última página com espaços vazios para as
                        // cores ficarem nas mesmas posições das outras páginas.
                        ForEach(0..<(colorsPerPage - page.count), id: \.self) { _ in
                            Color.clear
                                .frame(width: 36, height: 36)
                        }
                    }
                    .padding(.horizontal, 16)
                    // Só na horizontal! Com `.vertical` a página pegava a altura
                    // da sheet inteira e a área invisível dela cobria o
                    // TextField de nome, bloqueando o toque.
                    .containerRelativeFrame(.horizontal)
                    .frame(height: 90)
                    .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollBounceBehavior(.basedOnSize)
        // Sabe em qual página o usuário está para acender o pontinho certo.
        .scrollPosition(id: $currentPage)
        .containerRelativeFrame(.horizontal) { width, _ in
            width * 0.9
        }
        .frame(height: 90)
        // Pontinhos de página: mostram que dá para rolar para o lado.
        .overlay(alignment: .bottom) {
            if pages.count > 1 {
                pageDots
                    .padding(.bottom, 8)
            }
        }
        .background {
            Rectangle()
                .foregroundStyle(.white)
                .cornerRadius(20)
        }
        // Recorta o conteúdo que rola nos cantos arredondados do cartão.
        .clipShape(RoundedRectangle(cornerRadius: 20))
        // Toque também limitado ao cartão (clipShape só recorta o desenho).
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Cores")
    }

    /// Indicador de página (igual ao da tela de início do iPhone). Tocar
    /// num pontinho leva àquela página.
    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(pages.indices, id: \.self) { index in
                Circle()
                    .fill(index == (currentPage ?? 0) ? Color.gray : Color.gray.opacity(0.3))
                    .frame(width: 6, height: 6)
                    .onTapGesture {
                        withAnimation { currentPage = index }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentPage)
        // O VoiceOver já rola as páginas sozinho; os pontinhos são visuais.
        .accessibilityHidden(true)
    }

    /// Botão de uma cor, com destaque quando está selecionada.
    private func colorButton(_ color: Color) -> some View {
        Button {
            // Atualiza a seleção quando o usuário toca na cor.
            selectedColor = color

        } label: {

            Circle()
                .fill(color)
                .frame(width: 36, height: 36)
                .overlay {

                    // Destaca visualmente a cor atualmente selecionada.
                    if selectedColor == color {
                        // padding negativo afasta o contorno da cor.
                        Circle()
                            .stroke(.blue, lineWidth: 3)
                            .padding(-4)
                    }
                }
        }
        .buttonStyle(.plain)
        // O VoiceOver lê o nome da cor dado pelo sistema (ex.: "vermelho vivo").
        .accessibilityLabel(Text(verbatim: color.spokenName))
        .accessibilityHint("Cor do participante")
        .accessibilityAddTraits(selectedColor == color ? .isSelected : [])
    }
}

#Preview {
    ColorPickerView(
        colors: [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple,
            .pink,
            .mint,
            .teal,
            .cyan,
            .indigo,
            .brown
        ],
        selectedColor: .constant(.blue)
    )
}
