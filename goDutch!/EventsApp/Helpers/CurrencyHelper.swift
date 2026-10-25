import Foundation
import SwiftUI

// MARK: - Moeda de acordo com o idioma

/// Centraliza a moeda e a formatação de valores do app, de acordo com o
/// idioma em que o app está rodando:
///
/// | Idioma    | Moeda                                   | Exemplo     |
/// |-----------|-----------------------------------------|-------------|
/// | Português | Real (BRL)                              | R$ 15,00    |
/// | Inglês    | Dólar americano (USD)                   | $15.00      |
/// | Espanhol  | Moeda do país do aparelho, se hispânico | $ 15,00 (AR)|
/// |           | Euro (EUR) nos demais países            | 15,00 €     |
///
/// Os valores são calculados uma vez só: quando a pessoa troca o idioma do
/// app nos Ajustes, o iOS reinicia o app.
enum CurrencyHelper {

    // MARK: Idioma e locale

    /// Idioma em que o app está rodando ("pt", "en" ou "es"). Vem da
    /// localização escolhida pelo iOS entre as que o app oferece.
    static let languageCode: String = {
        let identifier = Bundle.main.preferredLocalizations.first ?? "pt-BR"
        return Locale(identifier: identifier).language.languageCode?.identifier ?? "pt"
    }()

    /// Países de língua espanhola. Com o app em espanhol e o iPhone
    /// configurado num desses países, usamos a moeda local.
    private static let spanishSpeakingRegions: Set<String> = [
        "AR", "BO", "CL", "CO", "CR", "CU", "DO", "EC", "ES", "GQ", "GT",
        "HN", "MX", "NI", "PA", "PE", "PR", "PY", "SV", "UY", "VE"
    ]

    /// Locale usado para formatar valores: define a moeda, o símbolo, a
    /// posição dele (antes ou depois do número) e os separadores
    /// ("15,00" ou "15.00").
    static let locale: Locale = {
        switch languageCode {
        case "en":
            return Locale(identifier: "en_US")

        case "es":
            if let region = Locale.current.region?.identifier,
               spanishSpeakingRegions.contains(region) {
                return Locale(identifier: "es_\(region)")
            }
            return Locale(identifier: "es_ES")

        default:
            return Locale(identifier: "pt_BR")
        }
    }()

    // MARK: Moeda

    /// Código ISO da moeda (ex.: "BRL", "USD", "EUR", "MXN").
    static let currencyCode: String = locale.currency?.identifier ?? "BRL"

    /// Formatter de moeda completo (com símbolo).
    private static let currencyWithSymbolFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.currencyCode = currencyCode
        return formatter
    }()

    /// Símbolo da moeda (ex.: "R$", "$", "€").
    static let symbol: String = currencyWithSymbolFormatter.currencySymbol ?? "R$"

    /// No app o símbolo fica sempre à esquerda do valor, em todos os
    /// idiomas ("R$ 15,00", "$15.00", "€ 15,00"), mesmo quando o padrão do
    /// idioma é depois do número (como o euro).
    static let symbolIsPrefix: Bool = true

    /// `true` quando o padrão do idioma já é símbolo antes do número.
    private static let localeSymbolIsPrefix: Bool = {
        let sample = currencyWithSymbolFormatter.string(from: 1) ?? ""
        return !sample.trimmingCharacters(in: .whitespaces).hasSuffix(symbol)
    }()

    /// O que vai entre o símbolo e o número: o mesmo do idioma quando ele
    /// já usa o símbolo antes ("R$ 15,00" → espaço, "$15.00" → nada).
    /// Para o euro, que vem depois no padrão, usamos um espaço ("€ 15,00").
    static let symbolSeparator: String = {
        guard localeSymbolIsPrefix,
              let sample = currencyWithSymbolFormatter.string(from: 1),
              let symbolRange = sample.range(of: symbol) else {
            return "\u{00A0}"
        }
        let afterSymbol = sample[symbolRange.upperBound...]
        let separator = afterSymbol.prefix { !$0.isNumber }
        return separator.isEmpty ? "" : "\u{00A0}"
    }()

    /// Espaço (em pontos) entre o símbolo e o número quando os dois são
    /// textos separados na tela: pequeno para "$15.00", maior para "R$ 15,00".
    static var symbolSpacing: CGFloat {
        symbolSeparator.isEmpty ? 1 : 4
    }

    // MARK: Formatação

    /// Formatter reutilizado para exibir valores com duas casas decimais,
    /// sem símbolo, com os separadores do idioma.
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = locale
        return formatter
    }()

    /// Valor sem símbolo (ex.: "15,00" ou "15.00"). Use junto com `symbol`
    /// quando o símbolo tem estilo próprio na tela.
    static func format(_ value: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: value))
            ?? String(format: "%.2f", value)
    }

    /// Valor com símbolo, sempre à esquerda
    /// (ex.: "R$ 15,00", "$15.00", "€ 15,00").
    static func formatWithSymbol(_ value: Double) -> String {
        let sign = value < 0 ? "-" : ""
        return sign + symbol + symbolSeparator + format(abs(value))
    }

    /// Valor no formato padrão do idioma (ex.: "15,00 €"). Usado só para
    /// o VoiceOver, que lê esse formato de forma mais natural.
    static func formatInLocaleStyle(_ value: Double) -> String {
        value.formatted(.currency(code: currencyCode).locale(locale))
    }

    /// Estilo para usar direto no SwiftUI:
    /// `Text(value, format: CurrencyHelper.formatStyle)`.
    static var formatStyle: AppCurrencyFormatStyle {
        AppCurrencyFormatStyle()
    }
}

/// Formata valores com o símbolo da moeda sempre à esquerda
/// (veja `CurrencyHelper.formatWithSymbol`).
struct AppCurrencyFormatStyle: FormatStyle {
    func format(_ value: Double) -> String {
        CurrencyHelper.formatWithSymbol(value)
    }
}
