//
//  Haptics.swift
//  EventsApp
//

import UIKit

/// Haptics curtos (toques) para as ações do app. Todos respeitam a opção
/// "Animações & Haptics" dos ajustes: desligada, nada vibra.
///
/// Para vibrações contínuas que acompanham uma animação (nota descendo),
/// veja `PrintHaptics`.
@MainActor
enum Haptics {

    // MARK: - Itens da comanda

    /// Item adicionado à comanda: toque leve e "macio".
    static func itemAdded() {
        impact(.soft, intensity: 0.8)
    }

    /// Item removido da comanda: toque mais seco que o de adicionar, para
    /// as duas ações serem diferentes ao toque.
    static func itemRemoved() {
        impact(.rigid, intensity: 0.7)
    }

    /// Valor de um stepper mudou (ex.: quantidade do item): "clique" leve,
    /// como o de girar um seletor do iOS.
    static func stepperChanged() {
        guard AppSettings.isAnimationsOn else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Pagamento (cards no círculo)

    /// Card entrou no círculo de "Pago".
    static func cardPaid() {
        impact(.medium, intensity: 0.9)
    }

    /// Card arrastado passou por cima de outro card (vai juntar se soltar).
    static func cardMergeHover() {
        guard AppSettings.isAnimationsOn else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    /// Dois cards foram juntados (um paga pelo outro).
    static func cardMerged() {
        impact(.soft, intensity: 1.0)
    }

    /// Soltou um card em cima de um grupo que já está cheio (5 pessoas).
    static func cardMergeRejected() {
        guard AppSettings.isAnimationsOn else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Último card entrou no círculo: todo mundo pagou.
    static func allPaid() {
        guard AppSettings.isAnimationsOn else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // MARK: - Base

    private static func impact(
        _ style: UIImpactFeedbackGenerator.FeedbackStyle,
        intensity: CGFloat
    ) {
        guard AppSettings.isAnimationsOn else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred(intensity: intensity)
    }
}
