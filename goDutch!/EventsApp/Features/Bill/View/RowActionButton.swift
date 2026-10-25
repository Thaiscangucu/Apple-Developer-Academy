import SwiftUI

/// Tipo de ação disponível para um `RowActionButton`.
///
/// Cada caso define a cor de fundo e o símbolo (SF Symbol) exibidos no
/// botão — a ação executada ao tocar não faz parte do enum, é passada
/// separadamente por quem usa o componente (`RowActionButton.action`).
enum RowActionKind {
    case edit
    case delete

    /// Símbolo exibido no botão.
    var symbolName: String {
        switch self {
        case .edit:
            return "pencil"
        case .delete:
            return "trash"
        }
    }

    /// Cor de fundo do botão.
    var backgroundColor: Color {
        switch self {
        case .edit:
            return .accentSlate
        case .delete:
            return Color(red: 0.97, green: 0.33, blue: 0.33)
        }
    }

    /// Cor do símbolo exibido sobre o fundo acima.
    var foregroundColor: Color {
        switch self {
        case .edit:
            return .white
        case .delete:
            return .white
        }
    }
}

/// Botão circular de ação (editar, excluir, ...), usado nas linhas com
/// swipe da comanda e dos participantes — ex: `ServiceFeeRow`,
/// `OldUserRow`. A cor de fundo e o símbolo vêm de `kind`; a ação
/// executada ao tocar é escolhida por quem usa o componente.
///
/// Visual igual em todo lugar que usa esse componente: circular, com
/// a dupla de sombras usada nos cards da comanda. O tamanho (56 por
/// padrão, o mesmo já usado em ServiceFeeRow e OldUserRow) pode ser
/// ajustado por quem usa o componente através de `size`.
struct RowActionButton: View {

    /// Define a cor de fundo e o símbolo do botão.
    let kind: RowActionKind

    /// Tamanho (largura e altura) do frame do botão. 56 por padrão,
    /// para não exigir esse argumento em quem já usa o componente.
    let size: CGFloat

    // `action` precisa ser o ÚLTIMO parâmetro declarado: no Swift, os
    // argumentos de uma chamada têm que seguir a mesma ordem em que
    // foram declarados na struct, mesmo sendo todos nomeados — por
    // isso `RowActionButton(kind:, size:, action:)` (ou com trailing
    // closure, `RowActionButton(kind:, size:) { ... }`) só compila se
    // `size` vier antes de `action` aqui.

    /// Ação executada ao tocar no botão.
    let action: () -> Void

    /// Quanto o botão cresce com o tamanho de texto (1 = tamanho normal).
    /// Limitado a `RowActionButton.maxScale`.
    @ScaledMetric(relativeTo: .body) private var rawScale: CGFloat = 1
    private var scale: CGFloat { min(rawScale, Self.maxScale) }

    /// Até quantas vezes o botão pode crescer nos tamanhos de acessibilidade.
    /// As linhas com swipe usam o mesmo valor para a largura das ações.
    static let maxScale: CGFloat = 2

    private var scaledSize: CGFloat { size * scale }

    // Init explícito: com a propriedade privada acima, o init automático
    // do Swift viraria privado e as outras telas não conseguiriam criar
    // o botão.
    init(kind: RowActionKind, size: CGFloat, action: @escaping () -> Void) {
        self.kind = kind
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: scaledSize, height: scaledSize)
                    .background(kind.backgroundColor)
                    // Metade do tamanho garante um círculo perfeito
                    // seja qual for o `size` escolhido.
                    .cornerRadius(scaledSize / 2)
                    .shadow(color: .black.opacity(0.2), radius: 1.99716, x: 0, y: 1.99716)
                    .shadow(color: Color(red: 0.43, green: 0.43, blue: 0.43).opacity(0.1), radius: 1.99716, x: 0, y: -0.99858)

                Image(systemName: kind.symbolName)
                    .font(.system(size: 18 * scale, weight: .bold))
                    .foregroundColor(kind.foregroundColor)
            }
        }
        .buttonStyle(.plain)
    }
}
