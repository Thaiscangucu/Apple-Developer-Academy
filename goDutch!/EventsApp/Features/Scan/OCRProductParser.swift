//
//  OCRProductParser.swift
//  EventsApp
//
//  Created by Thais Cangucu on 20/08/26.
//

import Foundation

/// Interpreta o texto do OCR como UM BLOCO contínuo, e não linha a linha.
///
/// Por que bloco: o Vision não garante que nome e preço de um item saiam
/// na mesma linha. Em nota de mercado o item ocupa 2 linhas (código +
/// descrição, depois "2 UN X 3,50 7,00"); em nota de restaurante com
/// colunas, às vezes o nome sai numa linha e o preço na seguinte, ou até
/// todos os nomes primeiro e todos os preços depois. Ler linha a linha
/// quebrava em todos esses casos.
///
/// Como funciona:
/// 1. Limpa o texto: descarta linhas de cabeçalho/rodapé (CNPJ, endereço,
///    pagamento...) e corta tudo a partir da linha de TOTAL.
/// 2. Junta o resto num bloco só e acha todos os PREÇOS nele — o preço é a
///    âncora que marca onde cada item termina.
/// 3. Preços separados só por "ruído" (UN, X, KG, quantidade, quebra de
///    linha) formam um mesmo grupo — ex: "3,50 7,00" (unitário + subtotal).
/// 4. O texto entre o grupo anterior e o atual é a descrição do item.
enum OCRProductParser {

    static func parse(_ rawText: String) -> [Product] {
        let lines = relevantLines(from: rawText)
        guard !lines.isEmpty else { return [] }

        let block = lines.joined(separator: "\n")
        return products(in: block)
    }

    // MARK: - 1. Limpeza do texto

    /// Linhas que interessam: sem cabeçalho/rodapé fiscal e sem nada depois
    /// do TOTAL (forma de pagamento, troco, tributos...).
    private static func relevantLines(from rawText: String) -> [String] {
        var result: [String] = []
        var sawPrice = false

        for rawLine in rawText.components(separatedBy: .newlines) {
            let line = cleanLine(rawLine)
            guard !line.isEmpty else { continue }

            if sawPrice && isTotalsLine(line) { break }
            if isIgnoredLine(line) { continue }

            if !priceMatches(in: line).isEmpty { sawPrice = true }
            result.append(line)
        }
        return result
    }

    private static func cleanLine(_ line: String) -> String {
        line.replacingOccurrences(of: "R$", with: " ")
            .replacingOccurrences(of: #"[ \t]+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Linha que marca o fim da lista de itens.
    private static func isTotalsLine(_ line: String) -> Bool {
        matches(
            #"^(SUB\s*-?\s*TOTAL|TOTAL|VALOR\s+(A\s+)?PAGAR|VALOR\s+TOTAL)\b"#,
            in: folded(line)
        )
    }

    private static let ignoredWords = [
        "TOTAL", "TOTAIS", "SUBTOTAL", "CNPJ", "CPF", "TROCO", "DESCONTO",
        "VALOR A PAGAR", "FORMA DE PAGAMENTO", "PAGAMENTO", "CARTAO",
        "PIX", "VALE", "DINHEIRO", "ENDERECO", "CEP", "CIDADE",
        "ESTADO", "OBRIGADO", "DOCUMENTO AUXILIAR", "TRIBUTOS", "ITEM COD",
        "QTD TOTAL", "RECEBIDO", "SENHA", "OPERADOR",
        // cabeçalho de cupom / comanda
        "CUPOM FISCAL", "NFC-E", "NFCE", "EXTRATO", "CONSUMIDOR",
        "CHAVE DE ACESSO", "PROTOCOLO", "GARCOM", "ATENDENTE", "CAIXA",
        // taxas e pagamento que não são item consumido
        "TAXA DE SERVICO", "SERVICO", "GORJETA", "CREDITO", "DEBITO",
        // data/hora — "HORA 12.30" seria lido como preço
        "DATA", "HORA", "EMISSAO"
    ]

    private static let ignoredLineRegex: NSRegularExpression = {
        let alternatives = ignoredWords
            .map { NSRegularExpression.escapedPattern(for: $0) }
            .joined(separator: "|")
        // Palavra inteira — evita descartar item como "CERVEJA PIXOTE".
        return try! NSRegularExpression(pattern: #"(?<![\p{L}\d])(?:"# + alternatives + #")(?![\p{L}\d])"#)
    }()

    private static func isIgnoredLine(_ line: String) -> Bool {
        let text = folded(line)
        if ignoredLineRegex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil {
            return true
        }
        // Linha com data ("01/10/2026", "01.10.26") nunca é item.
        return matches(#"(?<!\d)\d{2}[/.\-]\d{2}[/.\-]\d{2,4}(?!\d)"#, in: line)
    }

    // MARK: - 2. Preços (âncoras)

    private struct PriceMatch {
        let value: Double
        let range: Range<String.Index>
    }

    /// Valor monetário com 2 casas: "1.234,56", "12,50" ou "12.50".
    /// - não pode vir colado em letra (exceto "x", de "2 UN X3,50") nem em
    ///   dígito — evita pegar pedaço de código de barras ou "T17,00%";
    /// - não pode ser seguido de mais dígitos ou % — evita pegar peso
    ///   "0,530 kg" como "0,53" e alíquota de imposto.
    private static let pricePattern = #"(\d{1,3}(?:\.\d{3})+,\d{2}|\d+,\d{2}|\d+\.\d{2})(?![\d%]|[.,]\d)"#

    private static let priceRegex = try! NSRegularExpression(
        pattern: #"(?<![A-WYZa-wyz\d.,])"# + pricePattern
    )

    private static func priceMatches(in text: String) -> [PriceMatch] {
        let range = NSRange(text.startIndex..., in: text)
        return priceRegex.matches(in: text, range: range).compactMap { match in
            guard let r = Range(match.range(at: 1), in: text),
                  let value = parsePrice(String(text[r])) else { return nil }
            return PriceMatch(value: value, range: r)
        }
    }

    private static func parsePrice(_ raw: String) -> Double? {
        if raw.contains(",") {
            return Double(raw.replacingOccurrences(of: ".", with: "")
                             .replacingOccurrences(of: ",", with: "."))
        }
        return Double(raw)
    }

    // MARK: - 3. Grupos de preço

    /// Palavras que podem aparecer entre preços do MESMO item sem indicar
    /// que começou outro item (unidade, "x", códigos de tributo).
    private static let noiseWords: Set<String> = [
        "UN", "UND", "UNID", "UNI", "PC", "PCT", "CX", "KG", "G", "GR",
        "L", "LT", "ML", "X", "T", "F", "I", "N", "FF", "NN", "R"
    ]

    private static func isNoise(_ gap: Substring) -> Bool {
        letterWords(in: String(gap)).allSatisfy { noiseWords.contains($0.uppercased()) }
    }

    private static func priceGroups(in block: String) -> [[PriceMatch]] {
        var groups: [[PriceMatch]] = []
        for match in priceMatches(in: block) {
            if let previous = groups.last?.last,
               isNoise(block[previous.range.upperBound..<match.range.lowerBound]) {
                groups[groups.count - 1].append(match)
            } else {
                groups.append([match])
            }
        }
        return groups
    }

    // MARK: - 4. Itens

    private static func products(in block: String) -> [Product] {
        var products: [Product] = []
        var cursor = block.startIndex

        for group in priceGroups(in: block) {
            guard let first = group.first, let last = group.last else { continue }

            let description = String(block[cursor..<first.range.lowerBound])
            let priceText = String(block[first.range.lowerBound..<last.range.upperBound])
            cursor = last.range.upperBound

            products += productsFrom(description: description, priceText: priceText, prices: group.map(\.value))
        }
        return products
    }

    private static func productsFrom(description: String, priceText: String, prices: [Double]) -> [Product] {
        let lines = description.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        // Caso "coluna": vários nomes, cada um na sua linha, seguidos de
        // vários preços, cada um na sua linha. Pareia na ordem.
        if prices.count >= 2,
           priceText.components(separatedBy: "\n").count == prices.count,
           description.components(separatedBy: "\n").last.map({ !hasNameWords($0) }) ?? true {
            let nameLines = lines.filter { hasNameWords($0) && !isSoldByWeight($0) && !hasUnitQuantity($0) }
            if nameLines.count >= prices.count {
                return zip(nameLines.suffix(prices.count), prices).compactMap { line, price in
                    product(description: line, priceText: "", prices: [price])
                }
            }
        }

        // Caso normal: um item. A descrição começa na última linha com
        // código de produto (bloco de mercado) ou, sem código, na última
        // linha que tem nome — o que vem antes disso é sobra de cabeçalho.
        let start = lines.lastIndex(where: startsWithProductCode)
            ?? lines.lastIndex(where: hasNameWords)
        guard let start else { return [] }

        let itemDescription = lines[start...].joined(separator: " ")
        return product(description: itemDescription, priceText: priceText, prices: prices).map { [$0] } ?? []
    }

    private static func product(description: String, priceText: String, prices: [Double]) -> Product? {
        let name = productName(from: description)
        guard hasNameWords(name),
              let (quantity, price) = quantityAndUnitPrice(
                  text: description + " " + priceText,
                  description: description,
                  prices: prices
              )
        else { return nil }
        return Product(name: name, price: price, quantity: quantity)
    }

    // MARK: - Quantidade + preço unitário

    /// Sempre devolve o preço de UMA unidade — `Product.total` faz
    /// `price * quantity`. Em todos os casos `quantity * price` bate com o
    /// valor cobrado na nota, então o total da conta nunca muda por causa
    /// da divisão em quantidade.
    private static func quantityAndUnitPrice(text: String, description: String, prices: [Double]) -> (quantity: Int, price: Double)? {
        guard let last = prices.last, last > 0 else { return nil }

        // Vendido por peso: o valor cobrado é o último; quantidade 1.
        if isSoldByWeight(text) { return (1, last) }

        // "2 UN X 3,50 7,00" ou "2 x 3,50": a nota já diz quantidade e unitário.
        if let explicit = explicitUnitQuantity(in: text) { return explicit }

        // "3,50 7,00": unitário seguido do subtotal múltiplo dele.
        if prices.count >= 2 {
            let unit = prices[prices.count - 2]
            if unit > 0 {
                let ratio = (last / unit).rounded()
                if ratio >= 2, ratio <= 99, abs(unit * ratio - last) < 0.011 {
                    return (Int(ratio), unit)
                }
            }
        }

        // "2 CERVEJA 24,00" (restaurante): quantidade no começo e só o
        // total da linha. Divide só se der conta exata em centavos.
        if !startsWithProductCode(description),
           let quantity = leadingQuantity(in: description), quantity > 1 {
            let unit = (last / Double(quantity) * 100).rounded() / 100
            if abs(unit * Double(quantity) - last) < 0.001 {
                return (quantity, unit)
            }
        }

        return (1, last)
    }

    private static let explicitQuantityRegex = try! NSRegularExpression(
        pattern: #"(?<![\d.,])(\d{1,3})\s*(?:UN\p{L}*|UND|PC\p{L}*|CX)?\s*[xX*]\s*"# + pricePattern
    )

    private static func explicitUnitQuantity(in text: String) -> (quantity: Int, price: Double)? {
        guard let match = explicitQuantityRegex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let qRange = Range(match.range(at: 1), in: text),
              let pRange = Range(match.range(at: 2), in: text),
              let quantity = Int(text[qRange]), quantity > 0,
              let price = parsePrice(String(text[pRange])), price > 0
        else { return nil }
        return (quantity, price)
    }

    private static func hasUnitQuantity(_ text: String) -> Bool {
        matches(#"(?i)(?<![\d.,])\d{1,3}\s*(?:UN\p{L}*|UND|PC\p{L}*|CX)\s*[xX*]?(?!\p{L})"#, in: text)
    }

    /// Quantidade no início da descrição: "2 CERVEJA", "2x CERVEJA", "2 X CERVEJA".
    /// Exige espaço ou "x" depois do número, pra não ler "2L COCA" como 2 unidades.
    private static let leadingQuantityRegex = try! NSRegularExpression(
        pattern: #"^\s*(\d{1,2})(?:\s*[xX](?!\p{L})|\s)\s*(?=\p{L})"#
    )

    private static func leadingQuantity(in text: String) -> Int? {
        guard let match = leadingQuantityRegex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let r = Range(match.range(at: 1), in: text)
        else { return nil }
        return Int(text[r])
    }

    private static func isSoldByWeight(_ text: String) -> Bool {
        matches(#"(?i)(?<!\p{L})KG(?!\p{L})"#, in: text)
    }

    // MARK: - Nome

    private static func productName(from text: String) -> String {
        let replacements: [(String, NSString.CompareOptions)] = [
            (#"\d+[.,]\d+\s*KG\s*[xX]?"#, [.regularExpression, .caseInsensitive]),                    // peso "0,530 kg x"
            (#"(?<![\d.,])\d{1,3}\s*(?:UN\p{L}*|UND|PC\p{L}*|CX)\s*[xX*]?(?!\p{L})"#, [.regularExpression, .caseInsensitive]), // "2 UN X"
            (#"^\s*\d{1,2}\s*[xX](?!\p{L})"#, [.regularExpression]),                                  // "2x CERVEJA"
            (#"(?<![\p{L}\d])T\d+[.,]\d+%?"#, [.regularExpression, .caseInsensitive]),               // alíquota "T17,00%"
            (#"(?<![\p{L}\d])[TFIN]\d{1,2}(?![\p{L}\d])"#, [.regularExpression]),                     // tributo "F1", "T2"
            (#"(?<![\p{L}\d])\d+(?:[.,:/]\d+)*(?![\p{L}\d])"#, [.regularExpression]),                 // números soltos (código, índice, data)
            (#"(?<!\S)(?:X|UN|UND|UNID|KG|PC)(?!\S)"#, [.regularExpression, .caseInsensitive]),       // sobras de unidade
            (#"[*#=|_~<>{}\[\]%$]"#, [.regularExpression]),                                           // símbolos
            (#"\(\s*\)"#, [.regularExpression])
        ]

        var name = text
        for (pattern, options) in replacements {
            name = name.replacingOccurrences(of: pattern, with: " ", options: options)
        }

        return name
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet.whitespaces.union(CharacterSet(charactersIn: "-.,:/")))
    }

    // MARK: - Apoio à conferência do resultado da IA

    /// Todos os valores monetários que o OCR leu na nota.
    static func allPrices(in rawText: String) -> [Double] {
        priceMatches(in: rawText).map(\.value)
    }

    /// Valor dos itens impresso na nota: o SUBTOTAL quando existe (é o
    /// valor antes de taxa de serviço, que não vira item), senão o TOTAL.
    /// Aceita o valor na mesma linha ou na linha de baixo (layout em coluna).
    static func declaredItemsTotal(in rawText: String) -> Double? {
        let lines = rawText.components(separatedBy: .newlines)
            .map(cleanLine)
            .filter { !$0.isEmpty }

        func value(at index: Int) -> Double? {
            if let price = priceMatches(in: lines[index]).last?.value { return price }
            let nextIndex = index + 1
            if nextIndex < lines.count, !hasNameWords(lines[nextIndex]),
               let price = priceMatches(in: lines[nextIndex]).first?.value {
                return price
            }
            return nil
        }

        let subtotalLines = lines.indices.filter {
            matches(#"^SUB\s*-?\s*TOTAL\b"#, in: folded(lines[$0]))
        }
        let totalLines = lines.indices.filter {
            matches(#"^(TOTAL|VALOR\s+TOTAL|VALOR\s+(A\s+)?PAGAR)\b(?!.*ITENS)"#, in: folded(lines[$0]))
        }

        for index in subtotalLines + totalLines {
            if let total = value(at: index), total > 0 { return total }
        }
        return nil
    }

    /// Nome que claramente não é item consumido (TOTAL, TROCO, CNPJ, taxa...).
    static func isNonItemDescription(_ name: String) -> Bool {
        isIgnoredLine(name)
    }

    // MARK: - Helpers

    private static func startsWithProductCode(_ line: String) -> Bool {
        matches(#"^\s*(?:\d{1,4}\s+)?\d{6,}(?!\d)"#, in: line)
    }

    /// Tem pelo menos uma palavra "de verdade" (2+ letras, que não seja
    /// unidade/ruído) — serve pra saber se a linha descreve um produto.
    private static func hasNameWords(_ text: String) -> Bool {
        letterWords(in: text).contains { $0.count >= 2 && !noiseWords.contains($0.uppercased()) }
    }

    private static let letterWordRegex = try! NSRegularExpression(pattern: #"\p{L}+"#)

    private static func letterWords(in text: String) -> [String] {
        letterWordRegex.matches(in: text, range: NSRange(text.startIndex..., in: text)).compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
    }

    private static func folded(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "pt_BR"))
            .uppercased()
    }

    private static func matches(_ pattern: String, in text: String) -> Bool {
        text.range(of: pattern, options: .regularExpression) != nil
    }
}
