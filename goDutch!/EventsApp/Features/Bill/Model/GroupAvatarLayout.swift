//
//  GroupAvatarLayout.swift
//  EventsApp
//
//  Desenho da bolinha de um card juntado: um círculo branco com as
//  bolinhas de cada pessoa dentro (2 a 5) e um selo com a quantidade.
//
//  Usado pela CardsScene (SpriteKit) e pelo card em destaque da
//  TotalView (SwiftUI), para os dois ficarem iguais.
//

import CoreGraphics
import UIKit

enum GroupAvatarLayout {

    // MARK: - Tamanho e sombra do círculo branco

    /// Quanto o círculo do grupo é maior que a bolinha de um card normal.
    /// 1.0 = mesmo tamanho; 1.3 = 30% maior. É só mudar aqui: a cena, o
    /// card em destaque e a colisão entre os cards acompanham.
    static let circleScale: CGFloat = 1.3

    /// Sombra do círculo branco — equivale a
    /// `.shadow(color: .black.opacity(0.25), radius: 2.20811, x: 0, y: 1.16216)`.
    static let shadowOpacity: CGFloat = 0.25
    static let shadowRadius: CGFloat = 2.20811
    /// Deslocamento da sombra (y para BAIXO, como no SwiftUI).
    static let shadowOffset = CGSize(width: 0, height: 1.16216)

    /// Posição de uma bolinha dentro do círculo branco.
    struct Slot {
        /// Centro da bolinha, em frações do raio do círculo branco,
        /// a partir do centro. Eixo y para BAIXO (como no SwiftUI);
        /// a CardsScene inverte o y.
        let center: CGPoint
        /// Diâmetro da bolinha em frações do raio do círculo branco.
        let diameter: CGFloat
    }

    /// Ordem das pessoas: quem paga primeiro (bolinha de cima), depois
    /// quem foi juntado, na ordem em que entrou no grupo.
    static func slots(for count: Int) -> [Slot] {
        switch count {
        case 2:
            return [
                Slot(center: CGPoint(x: -0.29, y: -0.30), diameter: 0.84),
                Slot(center: CGPoint(x: 0.29, y: 0.32), diameter: 0.84)
            ]
        case 3:
            return [
                Slot(center: CGPoint(x: -0.06, y: -0.45), diameter: 0.74),
                Slot(center: CGPoint(x: 0.44, y: 0.25), diameter: 0.74),
                Slot(center: CGPoint(x: -0.37, y: 0.40), diameter: 0.74)
            ]
        case 4:
            return [
                Slot(center: CGPoint(x: -0.05, y: -0.46), diameter: 0.62),
                Slot(center: CGPoint(x: 0.47, y: -0.17), diameter: 0.62),
                Slot(center: CGPoint(x: -0.52, y: -0.04), diameter: 0.62),
                Slot(center: CGPoint(x: 0.06, y: 0.36), diameter: 0.62)
            ]
        case 5:
            return [
                Slot(center: CGPoint(x: -0.05, y: -0.47), diameter: 0.58),
                Slot(center: CGPoint(x: 0.49, y: -0.15), diameter: 0.58),
                Slot(center: CGPoint(x: -0.55, y: -0.19), diameter: 0.58),
                Slot(center: CGPoint(x: -0.32, y: 0.40), diameter: 0.58),
                Slot(center: CGPoint(x: 0.34, y: 0.40), diameter: 0.58)
            ]
        default:
            return [Slot(center: .zero, diameter: 2)]
        }
    }

    /// Tamanho do emoji em relação ao diâmetro da bolinha
    /// (o card normal usa 43pt numa bolinha de 70pt).
    static let emojiScale: CGFloat = 43.0 / 70.0

    // MARK: - Selo com a quantidade

    /// Centro do selo, em frações do raio do círculo branco (y para baixo).
    static let badgeCenter = CGPoint(x: 0.82, y: -0.74)

    /// Raio do selo em frações do raio do círculo branco.
    static let badgeRadius: CGFloat = 0.27

    /// Cinza-azulado do selo (mesmo tom de "grayblue84" no modo claro),
    /// fixo para o número branco continuar legível no modo escuro.
    static let badgeColor = UIColor(red: 0.518, green: 0.655, blue: 0.710, alpha: 1)

    /// Número do selo: arredondado e bem grosso, como no desenho.
    static func badgeFont(size: CGFloat) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: .heavy)
        guard let rounded = base.fontDescriptor.withDesign(.rounded) else {
            return base
        }
        return UIFont(descriptor: rounded, size: size)
    }
}
