//
//  AccessibilityHelpers.swift
//  EventsApp
//
//  Utilitários compartilhados para o VoiceOver.
//

import SwiftUI
import UIKit

// MARK: - Valores monetários falados

extension CurrencyHelper {

    /// Valor formatado para o VoiceOver (ex.: "R$ 16,50"), com o símbolo
    /// da moeda do idioma — assim ele é lido como "16 reais e 50 centavos"
    /// em vez de só "16 vírgula 50".
    static func accessibilityFormat(_ value: Double) -> String {
        CurrencyHelper.formatInLocaleStyle(value)
    }
}

// MARK: - Nome das cores

extension Color {

    /// Nome descritivo da cor lido pelo VoiceOver (ex.: "vermelho vivo"),
    /// fornecido pelo próprio sistema e já traduzido para o idioma do aparelho.
    var spokenName: String {
        UIColor(self).accessibilityName
    }
}

// MARK: - Participantes

extension User {

    /// Como o participante é anunciado pelo VoiceOver: só o nome.
    /// Emoji e cor são decorativos e não são lidos (só nos seletores
    /// de emoji e de cor, onde a pessoa precisa saber o que está escolhendo).
    var accessibilityName: String {
        name
    }
}

// MARK: - Anúncios

enum AccessibilityAnnouncer {

    /// Faz o VoiceOver falar uma mensagem na hora, sem mover o foco.
    /// Usado para confirmar ações que só têm retorno visual
    /// (ex.: pessoa adicionada ao item, conta paga).
    static func announce(_ message: String) {
        guard UIAccessibility.isVoiceOverRunning else { return }
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    /// Avisa o VoiceOver que a tela mudou (ex.: uma tela de carregamento
    /// cobriu tudo), para o foco ir para o novo conteúdo e ele ser lido.
    /// O pequeno atraso dá tempo da view entrar na árvore de acessibilidade.
    static func screenChanged() {
        guard UIAccessibility.isVoiceOverRunning else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .screenChanged, argument: nil)
        }
    }
}

// MARK: - Itens da conta

extension Product {

    /// Resumo do item lido pelo VoiceOver, no lugar das colunas visuais
    /// da comanda (ex.: "Item 1, Cerveja, quantidade 7, R$ 16,50 cada,
    /// total R$ 115,50").
    func accessibilitySummary(number: Int) -> String {
        String(localized: "Item \(number), \(name), quantidade \(quantity), \(CurrencyHelper.accessibilityFormat(price)) cada, total \(CurrencyHelper.accessibilityFormat(total))")
    }
}
