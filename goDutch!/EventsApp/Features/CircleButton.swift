//
//  PhotoLibraryButton.swift
//  EventsApp
//
//  Created by Thais Cangucu on 17/09/26.
//

import SwiftUI

/// Botão que abre o seletor de fotos do sistema, como alternativa a
/// escanear a nota na hora — pra notas já fotografadas antes ou mandadas
/// por outra pessoa.
struct CircleButton: View {
    var text: LocalizedStringResource
    var symbol: String
    var CircleSize: CGFloat
    var SymbolFont: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .shadow(color: .black.opacity(0.2), radius: 1.6878, x: 0, y: 1.6878)
                .shadow(color: Color("shadowSoft").opacity(0.1), radius: 1.6878, x: 0, y: -0.8439)
                .frame(width: CircleSize)
                .foregroundStyle(.white)
                .adaptiveGlass(clear: true, in: .circle)
                // Contorno com texto grande.
                .largeTextStroke(diameter: CircleSize)

            Image(systemName: symbol)
                .font(.system(size: SymbolFont, weight: .semibold))
                .foregroundStyle(.accentSlate)
        }
        // Um único elemento: o círculo e o ícone são decorativos, e o texto
        // curvo vira o nome do botão (quem usa pode sobrescrever o label).
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(text))
    }
}

#Preview {
//    ScanButtons(text: "Add foto galeria", symbol: "photo.on.rectangle")
}
