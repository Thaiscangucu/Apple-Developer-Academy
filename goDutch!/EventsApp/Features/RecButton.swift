import SwiftUI

/// Botão reutilizável do aplicativo, permitindo definir o texto,
/// as cores e a ação executada ao ser pressionado.
struct RecButton: View {

    /// Texto exibido no botão.
    let title: LocalizedStringKey

    /// Cor de fundo do botão.
    let backgroundColor: Color

    /// Cor do texto do botão.
    let foregroundColor: Color

    /// Ação executada quando o botão é pressionado.
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Text(title)
                .font(.system(.callout, design: .rounded, weight: .semibold))
                .foregroundStyle(foregroundColor)
                .multilineTextAlignment(.center)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                // Altura mínima, não fixa: com texto grande o botão cresce.
                .frame(minHeight: 54)
                .modifier(ButtonWidth())
                .background(backgroundColor)
                .clipShape(Capsule())
                .shadow(color: backgroundColor.opacity(0.4), radius: 6, x: 0, y: 3)
        }
    }
}

/// Largura do botão: 80% da tela nos tamanhos normais. Com texto grande o
/// botão costuma ficar dentro de um ScrollView, onde o
/// `containerRelativeFrame` não mede a largura direito (encolhe a quase
/// zero) — então ele ocupa a largura disponível.
private struct ButtonWidth: ViewModifier {
    @Environment(\.dynamicTypeSize) private var typeSize

    func body(content: Content) -> some View {
        if typeSize.isAccessibilitySize {
            content.frame(maxWidth: .infinity)
        } else {
            content.containerRelativeFrame(.horizontal) { width, _ in
                width * 0.8
            }
        }
    }
}

#Preview {
        RecButton(
            title: "Botão",
            backgroundColor: .accent,
            foregroundColor: .white
        ) {
            print("Próximo")
        }
}
