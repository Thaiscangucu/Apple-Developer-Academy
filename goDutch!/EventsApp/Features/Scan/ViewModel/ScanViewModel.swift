import SwiftUI
import Observation

@MainActor
@Observable
final class ScanViewModel {

    var showScanner = false
    var isProcessing = false
    /// Progresso do processamento (0...1), por etapa. A ScanLoadingView usa
    /// isso para a notinha descer no ritmo real da leitura/IA.
    var progress: Double = 0
    var errorMessage: String?

    /// Extrai os produtos da imagem.
    ///
    /// Fluxo:
    /// 1. Detecta a borda da nota e corrige a perspectiva (como o scanner nativo da Apple).
    /// 2. Pré-processa a imagem (sombra/brilho, contraste, nitidez).
    /// 3. Confere a orientação: se a nota estiver de ponta-cabeça, NÃO processa
    ///    nada e pede pra tirar a foto de novo.
    /// 4. Vision faz o OCR e o parser de regras interpreta o texto — isso roda
    ///    sempre, porque serve de conferência pra IA.
    /// 5. Se a Apple Intelligence estiver disponível (iOS 27+), a FOTO + o texto
    ///    do OCR vão pro modelo multimodal. O resultado é limpo, conferido
    ///    contra o total impresso na nota e comparado com o do parser.
    /// 6. Sem Apple Intelligence (ou se ela falhar), usa o resultado do parser.
    /// 7. Com Apple Intelligence (iOS 26+), os NOMES dos itens finais são
    ///    reescritos pra ficarem legíveis ("CERV LT SKOL 350ML" → "Cerveja Skol
    ///    Lata 350ml"). Preço e quantidade não mudam nessa etapa.
    ///
    /// Os prints abaixo são só pra debug — dá pra ver no console do Xcode qual
    /// caminho rodou e o que cada um devolveu.
    func extractProducts(
        from image: UIImage
    ) async throws -> [Product] {

        errorMessage = nil

        // O `isProcessing` é controlado por `processScannedImage`: em caso de
        // sucesso a tela de carregamento continua visível até a navegação.

        // MARK: - Reduz a foto (acelera todas as etapas seguintes)

        let smallImage = await ImageDownscaler.downscaled(image)

        // MARK: - Correção de perspectiva

        let correctedImage = await DocumentPerspectiveCorrector.correctedImage(
            from: smallImage
        )
        progress = 0.12

        // MARK: - Pré-processamento de imagem

        let enhancedImage = await ImageEnhancer.enhanced(
            correctedImage
        )
        progress = 0.22

        // MARK: - Orientação + OCR, ao mesmo tempo
        //
        // A checagem de ponta-cabeça e a leitura completa do texto rodam em
        // paralelo. Se a nota estiver de ponta-cabeça, o texto é descartado.

        async let orientationCheck = ReceiptOrientationChecker.check(enhancedImage)
        async let extractedText = TextExtractor.extractText(from: enhancedImage)

        if await orientationCheck == .upsideDown {
            print("[Scan] Nota de ponta-cabeça — processamento cancelado.")
            _ = await extractedText
            throw IntelligenceError.upsideDown
        }
        progress = 0.28

        // MARK: - OCR + parser (resultado próprio e conferência da IA)

        let rawText = await extractedText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let ruleItems = rawText.isEmpty ? [] : OCRProductParser.parse(rawText)
        let declaredTotal = OCRProductParser.declaredItemsTotal(in: rawText)
        progress = 0.45

        print("[Scan] OCR + parser: \(ruleItems.count) item(ns); total impresso lido pelo OCR: \(declaredTotal.map { "\($0)" } ?? "não encontrado")")

        // MARK: - Apple Intelligence (foto + texto do OCR)
        //
        // O envio de imagem (Attachment) só existe a partir do iOS 27 — em
        // aparelhos com iOS mais antigo (ou sem o chip exigido pela Apple
        // Intelligence) isso nunca entra, e fica o resultado do parser.

        if #available(iOS 27.0, *), IntelligenceProcessor.isAvailable,
           let cgImage = enhancedImage.cgImage {

            print("[Scan] Apple Intelligence disponível — enviando foto + texto do OCR pro modelo.")

            do {
                let result = try await IntelligenceProcessor.process(
                    image: cgImage,
                    orientation: enhancedImage.imageOrientation.cgImagePropertyOrientation,
                    ocrText: rawText
                )

                progress = 0.8
                print("[Scan] IA devolveu \(result.items.count) item(ns), total lido: \(result.printedTotal)")
                for item in result.items {
                    print("[Scan]   - \(item.name) | qtd \(item.quantity) | preço unit. \(item.price)")
                }

                // Nome legível que a IA já devolveu junto (sem 2ª chamada).
                let generatedProducts = result.items.map { Product(from: $0) }
                let readableNames = Dictionary(
                    zip(generatedProducts.map(\.id), result.items.map(\.readableName)),
                    uniquingKeysWith: { first, _ in first }
                )

                let intelligenceItems = ScanResultReconciler.sanitized(
                    generatedProducts,
                    ocrText: rawText
                )

                let total = declaredTotal ?? (result.printedTotal > 0 ? result.printedTotal : nil)

                let choice = ScanResultReconciler.choose(
                    intelligence: intelligenceItems,
                    rules: ruleItems,
                    declaredTotal: total
                )

                print("[Scan] Resultado escolhido: \(choice.source.rawValue) (\(choice.products.count) item(ns)).")

                // Itens da IA: os nomes legíveis já vieram na mesma resposta,
                // então não precisa da segunda chamada de IA (ItemNameRefiner).
                if choice.source == .intelligence {
                    progress = 0.95
                    return choice.products.map { product in
                        guard let readable = readableNames[product.id] else { return product }
                        var updated = product
                        updated.name = ItemNameRefiner.validated(readable, original: product.name)
                        if updated.name != product.name {
                            print("[Scan] Nome: \(product.name) → \(updated.name)")
                        }
                        return updated
                    }
                }

                // Itens do OCR + parser: os nomes ainda vêm crus da nota.
                return await refinedNames(choice.products)

            } catch {
                // IA falhou: se o parser achou itens, segue com eles em vez
                // de mostrar erro pro usuário.
                print("[Scan] Falha na IA (\(error.localizedDescription)).")
                guard !ruleItems.isEmpty else { throw error }
                print("[Scan] Usando o resultado do OCR + parser.")
                return await refinedNames(ruleItems)
            }
        }

        // MARK: - Sem Apple Intelligence: OCR + parser

        if #available(iOS 27.0, *) {
            if case .failure(let error) = IntelligenceProcessor.checkAvailability() {
                print("[Scan] Apple Intelligence indisponível (\(error.localizedDescription)). Usando OCR + parser.")
            }
        } else {
            print("[Scan] iOS < 27 — recurso de imagem direta não existe neste aparelho. Usando OCR + parser.")
        }

        guard !rawText.isEmpty else {
            throw IntelligenceError.emptyInput
        }

        return await refinedNames(ruleItems)
    }

    // MARK: - Nomes legíveis

    /// Reescreve os nomes com o modelo de texto do Apple Intelligence quando
    /// disponível (iOS 26+). Sem ele, devolve os itens como estão.
    private func refinedNames(_ products: [Product]) async -> [Product] {
        progress = max(progress, 0.85)
        guard #available(iOS 26.0, *) else { return products }
        let refined = await ItemNameRefiner.refine(products)
        progress = 0.95
        return refined
    }

    // MARK: - Processar Nota Escaneada

    /// Extrai os produtos da imagem escaneada e adiciona à conta.
    /// Retorna `true` se deu certo (a View então navega para a comanda).
    /// Em caso de erro, preenche `errorMessage` para exibir o alerta.
    func processScannedImage(
        _ image: UIImage,
        billViewModel: BillViewModel
    ) async -> Bool {
        progress = 0
        isProcessing = true
        do {
            let items = try await extractProducts(from: image)

            guard !items.isEmpty else {
                isProcessing = false
                errorMessage = String(localized: "Não consegui identificar nenhum item nessa nota. Tente tirar a foto de novo, com mais luz e a nota bem enquadrada.")
                return false
            }

            billViewModel.addScannedItems(items)
            progress = 1
            // Deu certo: NÃO desliga o `isProcessing` aqui. A LoadingView fica
            // na tela enquanto a View navega para a comanda, e a própria View
            // chama `finishProcessing()` quando a AddUsersView sai de cena.
            return true
        } catch {
            isProcessing = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// Carrega o modelo de IA na memória enquanto a câmera está aberta, para
    /// ele já estar pronto quando a foto chegar.
    func prewarmModels() {
        if #available(iOS 27.0, *), IntelligenceProcessor.isAvailable {
            IntelligenceProcessor.prewarm()
        } else if #available(iOS 26.0, *) {
            ItemNameRefiner.prewarm()
        }
    }

    /// Esconde a tela de carregamento (chamado depois da navegação).
    func finishProcessing() {
        isProcessing = false
    }
}
