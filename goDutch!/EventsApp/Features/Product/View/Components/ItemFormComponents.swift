import SwiftUI
import UIKit


/// Botão do canto esquerdo da barra de navegação do formulário.
enum ItemFormLeadingAction {
    /// "✕": fecha a sheet sem salvar.
    case cancel
    /// Lixeira vermelha. A ação (normalmente abrir um alerta de
    /// confirmação) fica por conta de quem usa o formulário.
    case delete(accessibilityLabel: LocalizedStringKey, action: () -> Void)
}

/// Estrutura completa da sheet de formulário de item: cabeçalho "Item",
/// cartão branco com as linhas do formulário e barra com os botões de
/// cancelar/excluir e confirmar. As linhas vão no `content`.
struct ItemFormSheet<Content: View>: View {

    @Environment(\.dismiss) private var dismiss

    /// Texto pequeno acima do cartão. `nil` não mostra cabeçalho.
    var header: LocalizedStringKey? = "Item"

    /// Como o VoiceOver anuncia o cabeçalho (ex.: "Novo item").
    /// `nil` esconde o cabeçalho do VoiceOver.
    var headerAccessibilityLabel: LocalizedStringKey? = nil

    var leadingAction: ItemFormLeadingAction = .cancel

    /// Rótulo do VoiceOver para o botão "✓" (ex.: "Salvar alterações").
    var confirmAccessibilityLabel: LocalizedStringKey

    /// Chamado ao tocar no "✓". Quem usa decide se valida, salva e fecha.
    let onConfirm: () -> Void

    @ViewBuilder let content: () -> Content

    init(
        header: LocalizedStringKey? = "Item",
        headerAccessibilityLabel: LocalizedStringKey? = nil,
        leadingAction: ItemFormLeadingAction = .cancel,
        confirmAccessibilityLabel: LocalizedStringKey,
        onConfirm: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.headerAccessibilityLabel = headerAccessibilityLabel
        self.leadingAction = leadingAction
        self.confirmAccessibilityLabel = confirmAccessibilityLabel
        self.onConfirm = onConfirm
        self.content = content
    }

    var body: some View {
        NavigationStack {
            VStack {
                headerView

                ItemFormCard(content: content)

                Spacer()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 8)
            // Texto grande: o formulário rola dentro da sheet. Precisa vir
            // ANTES do containerRelativeFrame: dentro do ScrollView ele não
            // consegue medir a largura e o formulário encolhe a quase zero.
            .scrollsAtAccessibilitySizes()
            // Mantém o formulário proporcional à largura disponível da tela.
            .containerRelativeFrame(.horizontal) { width, _ in
                width * 0.87
            }
            .foregroundStyle(.appText)
            // Altura aproximada da sheet que apresenta o formulário.
            .adaptivePresentationDetents([.fraction(0.40)])
            .toolbar {
                ToolbarItem(placement: leadingPlacement) {
                    leadingButton
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(action: onConfirm) {
                        Image(systemName: "checkmark")
                    }
                    .accessibilityLabel(confirmAccessibilityLabel)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }

    @ViewBuilder
    private var headerView: some View {
        if let header {
            headerText(header)
        }
    }

    @ViewBuilder
    private func headerText(_ header: LocalizedStringKey) -> some View {
        let text = Text(header)
            .font(.app(.caption, weight: .medium))
            .foregroundStyle(Color("textSecondary"))
            // Mesma largura do conteúdo do cartão (ver `ItemFormCard`), para
            // o "Item" começar alinhado com o nome do item logo abaixo.
            .containerRelativeFrame(.horizontal, alignment: .leading) { width, _ in
                width * ItemFormCard<EmptyView>.contentWidthRatio
            }

        if let headerAccessibilityLabel {
            text
                .accessibilityLabel(headerAccessibilityLabel)
                .accessibilityAddTraits(.isHeader)
        } else {
            text.accessibilityHidden(true)
        }
    }

    private var leadingPlacement: ToolbarItemPlacement {
        switch leadingAction {
        case .cancel: return .cancellationAction
        case .delete: return .topBarLeading
        }
    }

    @ViewBuilder
    private var leadingButton: some View {
        switch leadingAction {
        case .cancel:
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
            .accessibilityLabel("Cancelar")

        case .delete(let label, let action):
            Button(action: action) {
                Image(systemName: "trash")
            }
            .tint(.red)
            .accessibilityLabel(label)
        }
    }
}

// MARK: - Cartão

/// Cartão branco de cantos arredondados que agrupa as linhas do formulário.
struct ItemFormCard<Content: View>: View {

    /// Largura do conteúdo do cartão, em proporção à largura da sheet.
    /// O cabeçalho "Item" usa a mesma proporção para ficar alinhado.
    static var contentWidthRatio: CGFloat { 0.73 }

    /// Largura do cartão (fundo branco), em proporção à largura da sheet.
    static var cardWidthRatio: CGFloat { 0.85 }

    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 22) {
            content()
        }
        .containerRelativeFrame(.horizontal) { width, _ in
            width * Self.contentWidthRatio
        }
        .padding(.vertical, 24)
        .containerRelativeFrame(.horizontal) { width, _ in
            width * Self.cardWidthRatio
        }
        .background {
            RoundedRectangle(cornerRadius: 31)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                .shadow(color: Color(red: 0.43, green: 0.43, blue: 0.43).opacity(0.1), radius: 2, x: 0, y: -1)
        }
    }
}

// MARK: - Nome

/// Nome editável do item, com o lápis à direita. Tocar no lápis coloca
/// o cursor no campo.
struct ItemNameField: View {

    @Binding var name: String
    var placeholder: LocalizedStringKey = "Nome"
    var accessibilityLabel: LocalizedStringKey = "Nome do item"

    @FocusState private var isFocused: Bool

    init(
        name: Binding<String>,
        placeholder: LocalizedStringKey = "Nome",
        accessibilityLabel: LocalizedStringKey = "Nome do item"
    ) {
        _name = name
        self.placeholder = placeholder
        self.accessibilityLabel = accessibilityLabel
    }

    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $name)
                .font(.app(.title3, weight: .semibold))
                .focused($isFocused)
                .accessibilityLabel(accessibilityLabel)

            Button {
                isFocused = true
            } label: {
                Image(systemName: "pencil")
                    .font(.app(.title3, weight: .regular))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .buttonStyle(.plain)
            // O próprio campo já é focável pelo VoiceOver.
            .accessibilityHidden(true)
        }
    }
}

/// Nome fixo, sem edição (ex.: "Taxa de Serviço"). Mesmo estilo do
/// `ItemNameField`, mas sem o lápis.
struct ItemFormTitle: View {

    let title: LocalizedStringKey

    init(_ title: LocalizedStringKey) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.app(.title3, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Linha "rótulo … valor"

/// Linha com o rótulo à esquerda e um controle à direita. Nos tamanhos de
/// texto de acessibilidade, o controle desce para baixo do rótulo.
struct ItemFormRow<Trailing: View>: View {

    let label: LocalizedStringKey

    /// Esconde o rótulo do VoiceOver quando o controle à direita já se
    /// anuncia sozinho (ex.: "Quantidade: 2"). Padrão: escondido.
    var hidesLabelFromAccessibility: Bool

    @ViewBuilder let trailing: () -> Trailing

    init(
        _ label: LocalizedStringKey,
        hidesLabelFromAccessibility: Bool = true,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.label = label
        self.hidesLabelFromAccessibility = hidesLabelFromAccessibility
        self.trailing = trailing
    }

    var body: some View {
        AdaptiveStack {
            Text(label)
                .font(.app(.subheadline, weight: .medium))
                .accessibilityHidden(hidesLabelFromAccessibility)

            Spacer()

            trailing()
        }
    }
}

// MARK: - Quantidade

/// Stepper em pílula cinza: "−  1  +".
struct QuantityStepper: View {

    @Binding var quantity: Int
    var range: ClosedRange<Int> = 1...50

    var body: some View {
        HStack {
            Button {
                if quantity > range.lowerBound {
                    quantity -= 1
                    Haptics.stepperChanged()
                }
            } label: {
                Image(systemName: "minus")
                    .font(.body.weight(.bold))
                    .foregroundStyle(.black)
            }
            .disabled(quantity <= range.lowerBound)
            // VoiceOver: "Diminuir quantidade, 2, botão". O valor é lido junto
            // para a pessoa ouvir o número novo logo depois de tocar.
            .accessibilityLabel("Diminuir quantidade")
            .accessibilityValue("\(quantity)")

            // Exibe a quantidade atual mantendo os números alinhados.
            Text("\(quantity)")
                .font(.app(.title3))
                .monospacedDigit()
                .frame(minWidth: 40)
                .padding(.horizontal, 7)
                .accessibilityLabel("Quantidade: \(quantity)")

            Button {
                if quantity < range.upperBound {
                    quantity += 1
                    Haptics.stepperChanged()
                }
            } label: {
                Image(systemName: "plus")
                    .font(.body.weight(.bold))
                    .foregroundStyle(.black)
            }
            .disabled(quantity >= range.upperBound)
            .accessibilityLabel("Aumentar quantidade")
            .accessibilityValue("\(quantity)")
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 6)
        .background(Color(.quaternarySystemFill))
        .clipShape(Capsule())
    }
}

// MARK: - Valor em reais

/// Símbolo da moeda ("R$", "$", "€"…) menor e mais leve, colado ao número
/// (como no protótipo). Fica antes ou depois do número conforme o idioma:
/// "R$ 15,00", "$15.00", "15,00 €".
private struct CurrencyPrefix<Amount: View>: View {

    @ViewBuilder let amount: () -> Amount

    var body: some View {
        HStack(spacing: CurrencyHelper.symbolSpacing + 2) {
            if CurrencyHelper.symbolIsPrefix {
                symbol
                amount()
            } else {
                amount()
                symbol
            }
        }
    }

    private var symbol: some View {
        Text(verbatim: CurrencyHelper.symbol)
            .font(.app(.footnote, weight: .regular))
            .accessibilityHidden(true)
    }
}

/// Valor editável em reais, digitado da direita para a esquerda (como no
/// Nubank). O campo tem a largura do próprio texto, então o "R$"
/// acompanha o número conforme ele cresce.
struct CurrencyAmountField: View {

    @Binding var cents: Int
    var accessibilityLabel: String = String(localized: "Valor do item")

    var body: some View {
        CurrencyPrefix {
            CurrencyTextField(
                cents: $cents,
                font: .appBase(.title3, weight: .bold),
                textStyle: .title3,
                textColor: .appText,
                voiceOverLabel: accessibilityLabel,
                fitsTextWidth: true
            )
            // Toque fácil mesmo quando o valor é curto ("0,00").
            .frame(minWidth: 44)
        }
    }
}

/// Valor em reais só para leitura (ex.: valor calculado da taxa).
struct CurrencyAmountText: View {

    let value: Double
    var accessibilityLabel: LocalizedStringKey = "Valor"

    var body: some View {
        CurrencyPrefix {
            Text(CurrencyHelper.format(value))
                .font(.app(.title3, weight: .bold))
                .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(CurrencyHelper.accessibilityFormat(value))
    }
}

// MARK: - Porcentagem

/// Porcentagem editável, no mesmo estilo do `CurrencyAmountField`: número
/// em negrito e o "%" menor e mais leve, colado à direita. Aceita só
/// números inteiros dentro de `range` (padrão: 0 a 100).
struct PercentAmountField: View {

    @Binding var percentage: Double
    var range: ClosedRange<Int>
    var accessibilityLabel: LocalizedStringKey

    /// Texto digitado. Fica separado de `percentage` para permitir o campo
    /// vazio enquanto a pessoa apaga e digita um número novo.
    @State private var text: String
    @FocusState private var isFocused: Bool

    init(
        percentage: Binding<Double>,
        range: ClosedRange<Int> = 0...100,
        accessibilityLabel: LocalizedStringKey = "Porcentagem"
    ) {
        _percentage = percentage
        self.range = range
        self.accessibilityLabel = accessibilityLabel
        _text = State(initialValue: String(Int(percentage.wrappedValue.rounded())))
    }

    var body: some View {
        HStack(spacing: 4) {
            TextField("0", text: $text)
                .keyboardType(.numberPad)
                .font(.app(.title3, weight: .bold))
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                // Largura do próprio número, para o "%" ficar colado nele.
                .fixedSize()
                .focused($isFocused)
                .accessibilityLabel(accessibilityLabel)
                .accessibilityValue("\(text.isEmpty ? "0" : text)%")
                .onChange(of: text) { _, newValue in
                    sanitize(newValue)
                }

            Text("%")
                .font(.app(.footnote, weight: .regular))
                .accessibilityHidden(true)
        }
        // Área de toque confortável: tocar no "%" ou ao redor também
        // coloca o cursor no campo.
        .frame(minWidth: 44, minHeight: 44, alignment: .trailing)
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }

    /// Mantém só dígitos, remove zeros à esquerda, limita ao `range` e
    /// atualiza a porcentagem.
    private func sanitize(_ newValue: String) {
        let digits = String(newValue.filter(\.isNumber).prefix(3))
        let value = min(max(Int(digits) ?? 0, range.lowerBound), range.upperBound)
        let cleaned = digits.isEmpty ? "" : String(value)

        if cleaned != newValue {
            text = cleaned
        }
        percentage = Double(value)
    }
}
