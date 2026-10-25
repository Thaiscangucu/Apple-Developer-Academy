//
//  OnOffToggle.swift
//  EventsApp
//

import SwiftUI

/// Toggle personalizado em formato de cápsula com as opções "On" / "Off".
/// O indicador colorido desliza para o lado selecionado.
struct OnOffToggle: View {

    /// Estado do toggle (true = On, false = Off).
    @Binding var isOn: Bool

    /// Textos exibidos em cada lado.
    var onTitle: String = "On"
    var offTitle: String = "Off"

    /// Nome do ajuste lido pelo VoiceOver (ex.: "Notificações").
    /// Sem ele, o VoiceOver só diria "On"/"Off", sem contexto.
    var accessibilityTitle: LocalizedStringKey? = nil

    /// Cores do componente.
    var trackColor: Color = .white
    var thumbColor: Color = Color(red: 0.52, green: 0.65, blue: 0.70)   // #85A7B3
    var selectedTextColor: Color = .white
    var unselectedTextColor: Color = Color(red: 0.74, green: 0.74, blue: 0.74) // #BDBDBD

    /// Dimensões.
    var height: CGFloat = 44
    var padding: CGFloat = 3
    /// Estilo de texto dos rótulos (acompanha o Dynamic Type).
    var textStyle: Font.TextStyle = .body

    /// Posição do indicador enquanto o usuário arrasta (nil = sem arrasto).
    @State private var dragX: CGFloat?

    var body: some View {
        GeometryReader { geo in
            let thumbWidth = geo.size.width / 2 - padding
            let onX = padding                     // posição do indicador em "On"
            let offX = geo.size.width / 2         // posição do indicador em "Off"
            let currentX = dragX ?? (isOn ? onX : offX)
            // Durante o arrasto, o texto destacado acompanha o lado do indicador.
            let showsOn = currentX < (onX + offX) / 2

            ZStack(alignment: .leading) {

                // Trilho
                Capsule()
                    .fill(trackColor)
                    .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 3)

                // Indicador deslizante
                Capsule()
                    .fill(thumbColor)
                    .frame(width: thumbWidth, height: geo.size.height - padding * 2)
                    .offset(x: currentX)
                    // Anima pelo valor, e não só pelo withAnimation: assim funciona
                    // mesmo quando o binding vem de @AppStorage (que perde a transação).
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isOn)

                // Rótulos
                HStack(spacing: 0) {
                    label(onTitle, selected: showsOn)
                        .onTapGesture { set(true) }
                    label(offTitle, selected: !showsOn)
                        .onTapGesture { set(false) }
                }
            }
            // MARK: - Arrastar
            // minimumDistance > 0 para não roubar os toques simples dos rótulos.
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { value in
                        let start = isOn ? onX : offX
                        dragX = min(max(start + value.translation.width, onX), offX)
                    }
                    .onEnded { value in
                        let start = isOn ? onX : offX
                        // Usa a posição prevista para aceitar também um "peteleco" rápido.
                        let predicted = start + value.predictedEndTranslation.width
                        let newValue = predicted < (onX + offX) / 2
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isOn = newValue
                            dragX = nil
                        }
                    }
            )
        }
        .frame(width: 274, height: height)
        .sensoryFeedback(.selection, trigger: isOn)
        // Para o VoiceOver, o componente se comporta como um Toggle nativo:
        // lê "Notificações, interruptor, ativado" e alterna com toque duplo.
        .accessibilityRepresentation {
            Toggle(isOn: Binding(get: { isOn }, set: { set($0) })) {
                if let accessibilityTitle {
                    Text(accessibilityTitle)
                } else {
                    Text(verbatim: "\(onTitle) / \(offTitle)")
                }
            }
        }
    }

    private func label(_ text: String, selected: Bool) -> some View {
        Text(text)
            .font(.app(textStyle, weight: .bold))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .foregroundStyle(selected ? selectedTextColor : unselectedTextColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
    }

    private func set(_ value: Bool) {
        dragX = nil
        guard value != isOn else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            isOn = value
        }
    }
}

#Preview {
    @Previewable @State var isOn = false

    ZStack {
        Color(red: 0.80, green: 0.87, blue: 0.90).ignoresSafeArea()
        OnOffToggle(isOn: $isOn)
            .frame(width: 274)
    }
}
