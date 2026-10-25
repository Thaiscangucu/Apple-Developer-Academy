//
//  ScanResultReconciler.swift
//  EventsApp
//

import Foundation

/// Confere o que a Apple Intelligence devolveu contra o que o OCR leu na
/// mesma nota, e decide qual resultado usar.
///
/// O modelo on-device é bom pra entender o layout (qual nome vai com qual
/// preço), mas às vezes erra números ou devolve o subtotal da linha no
/// lugar do preço unitário. O OCR do Vision é bem preciso nos dígitos.
/// Juntando os dois, dá pra pegar a maior parte desses erros.
enum ScanResultReconciler {

    /// Diferença aceita entre a soma dos itens e o total impresso (1%),
    /// pra absorver arredondamento.
    private static let totalTolerance = 0.01

    enum Source: String {
        case intelligence = "Apple Intelligence"
        case rules = "OCR + parser"
    }

    // MARK: - Limpeza do resultado da IA

    /// Remove itens que não fazem sentido e corrige o erro mais comum do
    /// modelo: devolver o SUBTOTAL da linha como preço unitário (o que faz
    /// o item ser cobrado em dobro, já que o app multiplica por quantidade).
    static func sanitized(_ items: [Product], ocrText: String) -> [Product] {
        let ocrPrices = OCRProductParser.allPrices(in: ocrText)

        func ocrHas(_ value: Double) -> Bool {
            ocrPrices.contains { abs($0 - value) < 0.005 }
        }

        return items.compactMap { item in
            var product = item
            product.name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
            product.quantity = max(1, item.quantity)

            guard !product.name.isEmpty,
                  product.price > 0, product.price < 100_000,
                  !OCRProductParser.isNonItemDescription(product.name)
            else { return nil }

            // Quantidade > 1 e o "preço unitário" que veio é na verdade o
            // subtotal: o OCR tem esse valor e também o valor dividido pela
            // quantidade, mas não tem o valor multiplicado.
            if product.quantity > 1, !ocrPrices.isEmpty {
                let quantity = Double(product.quantity)
                let unitCandidate = (product.price / quantity * 100).rounded() / 100
                if ocrHas(product.price),
                   ocrHas(unitCandidate),
                   !ocrHas(product.price * quantity),
                   abs(unitCandidate * quantity - product.price) < 0.011 {
                    print("[Scan] Corrigindo \(product.name): \(product.price) era subtotal → unitário \(unitCandidate)")
                    product.price = unitCandidate
                }
            }

            return product
        }
    }

    // MARK: - Escolha final

    /// Escolhe entre o resultado da IA e o do parser de regras.
    ///
    /// Com o total da nota em mãos, fica com quem bate com ele — dando
    /// preferência à IA quando os dois batem (ou nenhum bate e ela erra
    /// por menos). Sem total, confia na IA, e só usa o parser se a IA não
    /// achou nada.
    static func choose(
        intelligence: [Product],
        rules: [Product],
        declaredTotal: Double?
    ) -> (products: [Product], source: Source) {

        guard !intelligence.isEmpty else { return (rules, .rules) }
        guard !rules.isEmpty, let total = declaredTotal, total > 0 else {
            return (intelligence, .intelligence)
        }

        let intelligenceError = relativeError(of: intelligence, against: total)
        let rulesError = relativeError(of: rules, against: total)

        print("[Scan] Total impresso: \(total) | soma IA: \(sum(intelligence)) | soma parser: \(sum(rules))")

        if intelligenceError <= totalTolerance { return (intelligence, .intelligence) }
        if rulesError <= totalTolerance { return (rules, .rules) }
        return intelligenceError <= rulesError
            ? (intelligence, .intelligence)
            : (rules, .rules)
    }

    private static func sum(_ products: [Product]) -> Double {
        products.reduce(0) { $0 + $1.total }
    }

    private static func relativeError(of products: [Product], against total: Double) -> Double {
        abs(sum(products) - total) / total
    }
}
