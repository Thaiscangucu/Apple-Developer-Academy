//
//  DynamicTypeLayout.swift
//  EventsApp
//
//  Ferramentas de layout para os tamanhos de texto de acessibilidade
//  (Ajustes > Acessibilidade > Tela e Tamanho do Texto > Texto Maior).
//
//  Ideia geral: nos tamanhos normais nada muda. Nos tamanhos de
//  acessibilidade (AX1–AX5) o layout muda de forma — o que estava lado a
//  lado passa a ficar empilhado e as telas passam a rolar —, em vez de só
//  crescer até quebrar.
//

import SwiftUI

// MARK: - Pilha adaptável

/// `HStack` nos tamanhos normais e `VStack` (alinhada à esquerda) nos
/// tamanhos de acessibilidade.
///
/// Use em linhas "rótulo … valor", como `Taxa Serviço … R$ 12,00`:
///
///     AdaptiveStack {
///         Text("Total")
///         Spacer()
///         Text("R$ 120,00")
///     }
struct AdaptiveStack<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var typeSize

    private let horizontalAlignment: HorizontalAlignment
    private let verticalAlignment: VerticalAlignment
    private let spacing: CGFloat?
    private let content: () -> Content

    init(
        horizontalAlignment: HorizontalAlignment = .leading,
        verticalAlignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: horizontalAlignment, spacing: spacing))
            : AnyLayout(HStackLayout(alignment: verticalAlignment, spacing: spacing))

        layout { content() }
            // Empilhado, o bloco ocupa a largura toda e alinha à esquerda.
            .frame(
                maxWidth: typeSize.isAccessibilitySize ? .infinity : nil,
                alignment: .leading
            )
    }
}

// MARK: - Rolagem

private struct ScrollsAtAccessibilitySizes: ViewModifier {
    @Environment(\.dynamicTypeSize) private var typeSize
    let showsIndicators: Bool

    func body(content: Content) -> some View {
        if typeSize.isAccessibilitySize {
            ScrollView(showsIndicators: showsIndicators) {
                content
            }
            // Se mesmo assim couber, não "quica".
            .scrollBounceBehavior(.basedOnSize)
        } else {
            content
        }
    }
}

// MARK: - Altura proporcional

private struct AdaptiveRelativeHeight: ViewModifier {
    @Environment(\.dynamicTypeSize) private var typeSize
    let fraction: CGFloat
    let accessibilityPadding: CGFloat

    func body(content: Content) -> some View {
        if typeSize.isAccessibilitySize {
            // Altura livre: o card cresce junto com o texto.
            content.padding(.vertical, accessibilityPadding)
        } else {
            content.containerRelativeFrame(.vertical) { height, _ in
                height * fraction
            }
        }
    }
}

// MARK: - Contorno dos botões circulares

/// Espessura do contorno dos botões circulares com texto grande
/// (ajuste aqui — vale para todos os botões que usam `.largeTextStroke`).
enum LargeTextStroke {
    static let width: CGFloat = 2
}

private struct LargeTextStrokeModifier: ViewModifier {
    @Environment(\.dynamicTypeSize) private var typeSize
    let diameter: CGFloat

    func body(content: Content) -> some View {
        content.overlay {
            if typeSize.isAccessibilitySize {
                Circle()
                    .stroke(Color.accentColor, lineWidth: LargeTextStroke.width)
                    .frame(width: diameter, height: diameter)
                    .allowsHitTesting(false)
            }
        }
    }
}

// MARK: - Sheets

private struct AdaptivePresentationDetents: ViewModifier {
    @Environment(\.dynamicTypeSize) private var typeSize
    let detents: Set<PresentationDetent>
    let accessibilityDetents: Set<PresentationDetent>

    func body(content: Content) -> some View {
        content.presentationDetents(
            typeSize.isAccessibilitySize ? accessibilityDetents : detents
        )
    }
}

extension View {

    /// Contorno na accent color em volta de um botão circular, só nos
    /// tamanhos de texto de acessibilidade (AX1–AX5), para ele se destacar.
    func largeTextStroke(diameter: CGFloat) -> some View {
        modifier(LargeTextStrokeModifier(diameter: diameter))
    }

    /// Envolve a view num `ScrollView` só nos tamanhos de acessibilidade.
    /// Nos tamanhos normais o layout fica exatamente como era.
    func scrollsAtAccessibilitySizes(showsIndicators: Bool = true) -> some View {
        modifier(ScrollsAtAccessibilitySizes(showsIndicators: showsIndicators))
    }

    /// Altura proporcional ao container nos tamanhos normais e altura livre
    /// (com respiro vertical) nos tamanhos de acessibilidade.
    /// Substitui `.containerRelativeFrame(.vertical) { $0 * fraction }`.
    func adaptiveRelativeHeight(_ fraction: CGFloat, accessibilityPadding: CGFloat = 16) -> some View {
        modifier(AdaptiveRelativeHeight(fraction: fraction, accessibilityPadding: accessibilityPadding))
    }

    /// Detents normais da sheet, trocados por outros (por padrão,
    /// tela cheia) nos tamanhos de acessibilidade.
    func adaptivePresentationDetents(
        _ detents: Set<PresentationDetent>,
        accessibility accessibilityDetents: Set<PresentationDetent> = [.large]
    ) -> some View {
        modifier(AdaptivePresentationDetents(detents: detents, accessibilityDetents: accessibilityDetents))
    }
}
