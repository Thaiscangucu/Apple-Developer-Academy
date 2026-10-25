//
//  ItemNameRefiner.swift
//  EventsApp
//

import FoundationModels
import Foundation

/// Lista de nomes reescritos pela IA, na mesma ordem dos originais.
@available(iOS 26.0, *)
@Generable
struct RefinedItemNames {

    @Guide(
        description: """
        Um nome reescrito para cada nome da lista recebida, na MESMA ordem e
        na MESMA quantidade
        """
    )
    var names: [String]
}

/// Deixa os nomes dos itens legíveis depois que a nota já foi interpretada.
///
/// O nome que sai da nota (via OCR ou IA lendo a foto) vem do jeito que está
/// impresso: tudo maiúsculo, abreviado ("CERV LATA SKOL 350ML") e às vezes
/// com erro de leitura ("C0CA C0LA"). Essa etapa usa o modelo de TEXTO do
/// Apple Intelligence (iOS 26+, não precisa do suporte a imagem do iOS 27)
/// pra reescrever só os nomes — preço e quantidade não passam por aqui.
///
/// Nunca falha: se o modelo não estiver disponível, der erro ou devolver
/// algo suspeito, o nome original é mantido.
@available(iOS 26.0, *)
enum ItemNameRefiner {

    private static let instructions = """
        Você recebe nomes de produtos copiados de notas fiscais e comandas
        brasileiras (supermercado, restaurante, bar). Eles vêm abreviados,
        em maiúsculas e às vezes com erros de leitura do OCR.

        Reescreva cada nome para ficar claro para uma pessoa dividindo a conta:
        - Expanda abreviações comuns: CERV → Cerveja, REFRI/REFRIG → Refrigerante,
          AGUA S/ GAS → Água sem Gás, C/ → com, S/ → sem, FGO → Frango,
          QJO → Queijo, PCT → Pacote, CX → Caixa, LT → Lata, GDE → Grande,
          PEQ → Pequeno, TRAD → Tradicional, CHOC → Chocolate, PORC → Porção.
        - Corrija erros óbvios de leitura (0 no lugar de O, 1 no lugar de I,
          5 no lugar de S dentro de palavras): "C0CA C0LA" → "Coca-Cola".
        - Use letras maiúsculas só no início das palavras e acentos corretos
          do português: "PAO FRANCES" → "Pão Francês".
        - Mantenha marca, sabor, tamanho e volume (350ml, 2L, 600ml).
        - Não acrescente nada que não esteja no nome original. Se não
          entender uma abreviação, mantenha ela como está.
        - Nomes curtos: no máximo umas 5 palavras.

        Devolva exatamente um nome para cada nome recebido, na mesma ordem.
        """

    /// Sessão pré-aquecida enquanto a câmera está aberta (usada uma vez).
    private static var preparedSession: LanguageModelSession?

    /// Carrega o modelo na memória antes da foto. Usado nos aparelhos em que
    /// a IA não lê a foto (iOS 26), onde esta é a única chamada de IA.
    static func prewarm() {
        guard preparedSession == nil,
              case .available = SystemLanguageModel.default.availability
        else { return }
        let session = LanguageModelSession(instructions: instructions)
        session.prewarm()
        preparedSession = session
    }

    /// Mesma validação usada no refinamento, para nomes legíveis que vêm
    /// direto da leitura da foto pela IA.
    static func validated(_ refined: String, original: String) -> String {
        accepted(refined, original: original)
    }

    static func refine(_ products: [Product]) async -> [Product] {
        guard !products.isEmpty,
              case .available = SystemLanguageModel.default.availability
        else { return products }

        let numberedList = products.enumerated()
            .map { "\($0.offset + 1). \($0.element.name)" }
            .joined(separator: "\n")

        do {
            let session = preparedSession ?? LanguageModelSession(instructions: instructions)
            preparedSession = nil
            let response = try await session.respond(
                generating: RefinedItemNames.self,
                options: GenerationOptions(sampling: .greedy)
            ) {
                "Reescreva estes \(products.count) nomes de produtos:"
                numberedList
            }

            let names = response.content.names
            guard names.count == products.count else {
                print("[Scan] Refinamento de nomes devolveu \(names.count) nome(s) para \(products.count) item(ns) — mantendo os originais.")
                return products
            }

            return zip(products, names).map { product, refined in
                var updated = product
                updated.name = accepted(refined, original: product.name)
                if updated.name != product.name {
                    print("[Scan] Nome: \(product.name) → \(updated.name)")
                }
                return updated
            }

        } catch {
            print("[Scan] Falha ao refinar nomes (\(error.localizedDescription)) — mantendo os originais.")
            return products
        }
    }

    // MARK: - Validação

    private static let standaloneNumberRegex = try! NSRegularExpression(pattern: #"(?<!\p{L})\d+"#)

    /// Usa o nome da IA só se ele parecer uma reescrita do original, e não
    /// outra coisa: não pode vir vazio, enorme, nem perder números de
    /// tamanho/volume ("350" de "350ML" tem que continuar lá).
    private static func accepted(_ refined: String, original: String) -> String {
        let name = refined
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"^\d+[.)]\s*"#, with: "", options: .regularExpression) // "1. " que o modelo copiou da lista

        guard !name.isEmpty, name.count <= 60 else { return original }

        let range = NSRange(original.startIndex..., in: original)
        let numbers = standaloneNumberRegex.matches(in: original, range: range).compactMap {
            Range($0.range, in: original).map { String(original[$0]) }
        }
        guard numbers.allSatisfy({ name.contains($0) }) else { return original }

        return name
    }
}
