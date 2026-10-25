import SwiftUI
import UIKit

/// Campo de texto para valores monetários que replica o comportamento do
/// campo de preço do app do Nubank: o valor começa em "0,00" e cada dígito
/// digitado entra pela direita, empurrando os demais dígitos para a
/// esquerda.
///
/// Diferente de um `TextField` comum com um `Binding<String>` calculado,
/// aqui o texto e o cursor do `UITextField` são controlados manualmente.
/// Isso evita um problema conhecido do SwiftUI: ao reformatar o texto a
/// cada tecla digitada, o cursor pode "saltar" para o início do campo,
/// fazendo com que o próximo dígito entre no lugar errado e o valor
/// resultante fique incorreto.
struct CurrencyTextField: UIViewRepresentable {

    /// Valor em centavos (inteiro). É a fonte da verdade do campo — a
    /// exibição ("0,00", "1,23"...) é sempre calculada a partir dele.
    @Binding var cents: Int

    /// Quantidade máxima de dígitos aceitos, para evitar valores
    /// absurdamente grandes (9 dígitos = até R$ 9.999.999,99).
    var maxDigits: Int = 9

    /// Fonte usada no campo. Como o `UITextField` não herda a fonte do
    /// ambiente do SwiftUI automaticamente, ela precisa ser passada aqui.
    var font: UIFont = .systemFont(ofSize: 17)

    /// Estilo de texto usado para escalar `font` com o Dynamic Type.
    var textStyle: UIFont.TextStyle = .body

    /// Cor do texto digitado. Assim como a fonte, o `UITextField` não herda
    /// o `.foregroundColor()`/`.foregroundStyle()` do SwiftUI, então a cor
    /// precisa ser passada explicitamente aqui.
    var textColor: UIColor = .label

    /// Nome do campo lido pelo VoiceOver (ex.: "Valor do item"). O valor é
    /// anunciado já em reais ("R$ 12,50"), não só como "12,50".
    var voiceOverLabel: String? = nil

    /// Quando `true`, a largura do campo acompanha o texto digitado (até o
    /// limite oferecido pelo layout). Útil para deixar um rótulo como "R$"
    /// sempre colado ao número, em vez de preso numa caixa de largura fixa.
    var fitsTextWidth: Bool = false

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.textAlignment = .right
        textField.font = scaledFont(for: textField.traitCollection)
        textField.adjustsFontForContentSizeCategory = true
        textField.textColor = textColor
        // Sem isso, quando o número digitado fica mais largo do que a caixa
        // do campo, o UIKit pode desenhar o texto que não coube fora dos
        // limites da view (por exemplo, por baixo do "R$" ao lado) em vez
        // de simplesmente cortar/rolar o conteúdo internamente.
        textField.clipsToBounds = true
        textField.delegate = context.coordinator
        textField.text = format(cents)
        textField.accessibilityLabel = voiceOverLabel
        updateAccessibilityValue(of: textField, cents: cents)
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textDidChange),
            for: .editingChanged
        )
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        // Mantém a coordinator sempre com a referência mais recente da
        // struct, já que o SwiftUI recria `self` a cada atualização de View.
        context.coordinator.parent = self

        uiView.font = scaledFont(for: uiView.traitCollection)
        uiView.textColor = textColor
        uiView.accessibilityLabel = voiceOverLabel
        updateAccessibilityValue(of: uiView, cents: cents)

        let formatted = format(cents)

        // Só toca no texto/cursor se o valor exibido estiver desatualizado
        // (por exemplo, quando `cents` muda por outro motivo que não seja
        // a digitação neste próprio campo).
        guard uiView.text != formatted else { return }
        uiView.text = formatted
        moveCursorToEnd(of: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /// Fixa a altura do campo com base na fonte, independente do tamanho do
    /// texto digitado.
    ///
    /// Sem isso, o SwiftUI deixa o próprio `UITextField` decidir sua altura
    /// através do auto layout do UIKit — e essa conta considera a largura
    /// fixa de 60pt (`.frame(width: 60)`) como se o texto fosse quebrar em
    /// múltiplas linhas quando ele fica mais largo que a caixa (por exemplo,
    /// ao digitar "1.234,56"). Isso faz a altura reportada crescer conforme
    /// se digita, empurrando as outras linhas do card para baixo. Ao
    /// devolver uma altura fixa aqui, o texto que não couber apenas rola
    /// dentro do campo (como em qualquer campo de valor de largura fixa),
    /// sem afetar o layout ao redor.
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: UITextField,
        context: Context
    ) -> CGSize? {
        let currentFont = uiView.font ?? font
        let height = ceil(currentFont.lineHeight) + 4

        if fitsTextWidth {
            // Mede o texto formatado a partir de `cents` (e não de
            // `uiView.text`), para a largura já refletir o valor novo.
            let text = format(cents) as NSString
            let textWidth = ceil(text.size(withAttributes: [.font: currentFont]).width) + 2
            // Nunca passa do espaço disponível: se o valor for enorme, o
            // texto rola dentro do campo em vez de estourar o card.
            let width = min(textWidth, proposal.width ?? textWidth)
            return CGSize(width: width, height: height)
        }

        let width = proposal.width ?? uiView.intrinsicContentSize.width
        return CGSize(width: width, height: height)
    }

    /// `font` escalada para o tamanho de texto atual.
    private func scaledFont(for traits: UITraitCollection) -> UIFont {
        UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font, compatibleWith: traits)
    }

    fileprivate func format(_ cents: Int) -> String {
        CurrencyHelper.format(Double(cents) / 100)
    }

    fileprivate func updateAccessibilityValue(of textField: UITextField, cents: Int) {
        textField.accessibilityValue = CurrencyHelper.accessibilityFormat(Double(cents) / 100)
    }

    fileprivate func moveCursorToEnd(of textField: UITextField) {
        let end = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: end, to: end)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {

        var parent: CurrencyTextField

        init(_ parent: CurrencyTextField) {
            self.parent = parent
        }

        /// Chamado a cada alteração no texto do campo. Extrai somente os
        /// dígitos digitados até agora, recalcula o valor em centavos e já
        /// corrige o texto exibido e a posição do cursor imediatamente —
        /// sem depender do próximo ciclo de atualização do SwiftUI.
        @objc func textDidChange(_ textField: UITextField) {
            let digitsOnly = (textField.text ?? "").filter(\.isNumber)

            // Mantém só os dígitos mais recentes (os menos significativos),
            // consistente com o comportamento de "empurrar pela direita".
            let capped = String(digitsOnly.suffix(parent.maxDigits))
            let newCents = Int(capped) ?? 0

            parent.cents = newCents
            textField.text = parent.format(newCents)
            parent.updateAccessibilityValue(of: textField, cents: newCents)
            parent.moveCursorToEnd(of: textField)
        }
    }
}
