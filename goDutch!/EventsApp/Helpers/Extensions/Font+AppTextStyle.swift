//
//  Font+AppTextStyle.swift
//  EventsApp
//
//  Tipografia do app baseada nos estilos de texto da Apple (Dynamic Type).
//
//  Em vez de tamanhos fixos em pt, cada texto usa um estilo (title, body,
//  caption...). A fonte continua sendo a Montserrat Alternates, mas parte do
//  tamanho padrão do estilo e cresce/diminui junto com o tamanho de texto
//  escolhido pela pessoa nos Ajustes (até ~3x nos tamanhos de acessibilidade).
//
//  | Estilo      | Padrão |
//  |-------------|--------|
//  | largeTitle  | 34 pt  |
//  | title       | 28 pt  |
//  | title2      | 22 pt  |
//  | title3      | 20 pt  |
//  | headline    | 17 pt  |
//  | body        | 17 pt  |
//  | callout     | 16 pt  |
//  | subheadline | 15 pt  |
//  | footnote    | 13 pt  |
//  | caption     | 12 pt  |
//  | caption2    | 11 pt  |
//

import SwiftUI
import UIKit

enum AppFont {
    /// Família usada em todo o app.
    static let family = "Montserrat Alternates"
}

// MARK: - SwiftUI

extension Font {

    /// Montserrat Alternates no tamanho do estilo de texto da Apple,
    /// acompanhando o Dynamic Type.
    ///
    ///     Text("Total").font(.app(.title3, weight: .bold))
    static func app(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .custom(AppFont.family, size: style.defaultPointSize, relativeTo: style)
            .weight(weight)
    }
}

extension Font.TextStyle {

    /// Tamanho padrão (tamanho de texto "Grande", o default do iOS).
    var defaultPointSize: CGFloat {
        switch self {
        case .largeTitle:  return 34
        case .title:       return 30
        case .title2:      return 22
        case .title3:      return 20
        case .headline:    return 18
        case .body:        return 17
        case .callout:     return 16
        case .subheadline: return 14
        case .footnote:    return 13
        case .caption:     return 12
        case .caption2:    return 11
        @unknown default:  return 17
        }
    }
}

// MARK: - UIKit

extension UIFont {

    /// Montserrat Alternates no tamanho padrão do estilo, **sem** escala.
    /// Use junto com `UIFontMetrics(forTextStyle:)` (como faz o
    /// `CurrencyTextField`) para que ela acompanhe o Dynamic Type.
    static func appBase(_ style: UIFont.TextStyle, weight: UIFont.Weight = .regular) -> UIFont {
        let size = style.defaultPointSize
        return UIFont(name: postScriptName(for: weight), size: size)
            ?? .systemFont(ofSize: size, weight: weight)
    }

    /// Montserrat Alternates já escalada para o tamanho de texto atual.
    static func app(_ style: UIFont.TextStyle, weight: UIFont.Weight = .regular) -> UIFont {
        UIFontMetrics(forTextStyle: style).scaledFont(for: appBase(style, weight: weight))
    }

    private static func postScriptName(for weight: UIFont.Weight) -> String {
        switch weight {
        case .bold, .heavy, .black: return "MontserratAlternates-Bold"
        case .semibold:             return "MontserratAlternates-SemiBold"
        case .medium:               return "MontserratAlternates-Medium"
        default:                    return "MontserratAlternates-Regular"
        }
    }
}

extension UIFont.TextStyle {

    var defaultPointSize: CGFloat {
        switch self {
        case .largeTitle:  return 34
        case .title1:      return 28
        case .title2:      return 22
        case .title3:      return 20
        case .headline:    return 17
        case .body:        return 17
        case .callout:     return 16
        case .subheadline: return 15
        case .footnote:    return 13
        case .caption1:    return 12
        case .caption2:    return 11
        default:           return 17
        }
    }
}
