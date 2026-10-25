//
//  LiquidGlassCompat.swift
//  EventsApp
//
//  Camada de compatibilidade para rodar o app em iOS anteriores ao 26.
//  No iOS 26+ usa Liquid Glass; nas versões anteriores, um visual
//  equivalente com materiais/estilos clássicos — os botões continuam
//  existindo e funcionando, só com aparência diferente.
//

import SwiftUI

extension View {

    /// Liquid Glass no iOS 26+. Em versões anteriores, aplica um material
    /// translúcido com uma borda clara, imitando o "vidro".
    @ViewBuilder
    func adaptiveGlass<S: Shape>(clear: Bool = false, in shape: S) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(clear ? .clear : .regular, in: shape)
        } else {
            self
                .background(
                    clear ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.regularMaterial),
                    in: shape
                )
                .overlay(
                    shape
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        .allowsHitTesting(false)
                )
        }
    }

    /// `.glassProminent` no iOS 26+. Em versões anteriores, um botão
    /// preenchido com a cor de destaque e formato circular.
    @ViewBuilder
    func adaptiveProminentButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
        }
    }
}

/// SF Symbols que mudaram de nome entre versões do iOS.
enum CompatSymbol {

    /// "document.viewfinder.fill" só existe a partir do iOS 18;
    /// antes disso o mesmo símbolo se chama "doc.viewfinder.fill".
    static var documentViewfinderFill: String {
        if #available(iOS 18.0, *) {
            return "document.viewfinder.fill"
        }
        return "doc.viewfinder.fill"
    }
}
