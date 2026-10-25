//
//  CurvedText.swift
//  EventsApp
//
//  Created by Thais Cangucu on 25/09/26.
//

import SwiftUI

/// Escreve um texto num arco, centralizado no topo de um círculo de raio `radius`.
struct CurvedText: View {
    let text: String
    let radius: CGFloat
    var kerning: CGFloat = 0.5

    @State private var widths: [Int: CGFloat] = [:]
    private var chars: [Character] { Array(text) }

    var body: some View {
        ZStack {
            ForEach(chars.indices, id: \.self) { i in
                Text(String(chars[i]))
                    .font(Font.custom("Montserrat Alternates", size: 9).weight(.regular))
                    .foregroundStyle(.textSecondary)
                    .kerning(kerning)
                    .fixedSize()
                    .onGeometryChange(for: CGFloat.self) { $0.size.width } action: {
                        widths[i] = $0
                    }
                    .offset(y: -radius)          // sobe a letra até a borda do círculo
                    .rotationEffect(angle(at: i)) // e gira em volta do centro
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }

    /// Ângulo de cada letra, proporcional à largura dela (assim "i" e "m" não ficam com o mesmo espaço).
    private func angle(at i: Int) -> Angle {
        let w = chars.indices.map { widths[$0] ?? 0 }
        let total = w.reduce(0, +)
        let center = w.prefix(i).reduce(0, +) + w[i] / 2
        return .radians(Double((center - total / 2) / radius))
    }
}
