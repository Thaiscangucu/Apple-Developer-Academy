//
//  ConsumedItemsResult.swift
//  EventsApp
//
//  Created by Thais Cangucu on 15/09/26.
//


import FoundationModels
import Foundation
import SwiftUI
import CoreGraphics

// MARK: - Resultado estruturado da IA
// Testar com apple no servidor da apple
// Voice over

// Foundation Models só existe a partir do iOS 26. Em aparelhos com iOS
// mais antigo esses tipos não existem e o app usa o fluxo de OCR.
@available(iOS 26.0, *)
@Generable
struct ConsumedItemsResult {

    @Guide(
        description: """
        Lista de itens de consumo (comida e bebida) identificados no documento,
        na ordem em que aparecem, um para cada linha de produto, ignorando
        totais, subtotais, CNPJ e qualquer linha que não seja um item consumido
        """
    )
    var items: [ConsumedItem]

    @Guide(
        description: """
        Valor impresso na nota como SUBTOTAL (ou TOTAL, se não houver
        subtotal), em reais, com ponto decimal. Use 0 se não estiver visível
        """
    )
    var printedTotal: Double
}

// MARK: - Item individual

@available(iOS 26.0, *)
@Generable
struct ConsumedItem {

    @Guide(
        description: """
        Nome do prato ou bebida como aparece na nota, sem código de barras,
        sem número do item e sem quantidade/preço
        """
    )
    var name: String

    @Guide(
        description: """
        O mesmo nome reescrito para ficar claro: abreviações expandidas \
        (CERV → Cerveja, REFRI → Refrigerante, LT → Lata, C/ → com, S/ → sem), \
        só a primeira letra de cada palavra maiúscula, acentos corretos, \
        mantendo marca, sabor e tamanho (350ml, 2L). No máximo 5 palavras. \
        Não acrescente nada que não esteja no nome original
        """
    )
    var readableName: String

    @Guide(
        description: """
        Quantidade consumida deste item. Se a nota não especificar, use 1
        """,
        .range(1...99)
    )
    var quantity: Int

    @Guide(
        description: """
        Preço de UMA unidade do item em reais — não o subtotal da
        linha já multiplicado pela quantidade. Valor decimal com
        ponto (ex: 24.00), sem o símbolo de moeda. Se a nota mostrar
        "2 UN X 3,50 7,00", o preço é 3.50 (o app multiplica por
        quantidade depois)
        """
    )
    var price: Double
}

// MARK: - Erros

enum IntelligenceError: LocalizedError {

    case modelUnavailable(String)
    case emptyInput
    case processingFailed(String)
    case upsideDown

    var errorDescription: String? {

        switch self {

        case .modelUnavailable(let reason):
            return String(localized: "Apple Intelligence indisponível: \(reason)")

        case .emptyInput:
            return String(localized: "Nenhum texto foi extraído da imagem para processar")

        case .processingFailed(let reason):
            return String(localized: "Falha ao processar com IA: \(reason)")

        case .upsideDown:
            return String(localized: "A nota parece estar de ponta-cabeça. Gire a nota e tire a foto de novo.")
        }
    }
}

// MARK: - Processador de IA

@available(iOS 26.0, *)
enum IntelligenceProcessor {

    /// Limite do texto do OCR enviado junto com a foto. O modelo on-device
    /// tem janela de contexto pequena; uma nota comum cabe folgado nisso.
    private static let maxOCRHintCharacters = 2_500

    /// Sessão criada e pré-aquecida (`prewarm`) enquanto a câmera está
    /// aberta, para o modelo já estar carregado quando a foto chegar.
    /// É usada uma vez só (cada nota começa sem histórico).
    private static var preparedSession: LanguageModelSession?

    /// Carrega o modelo na memória antes da foto. Chamar quando a câmera abre.
    static func prewarm() {
        guard isAvailable, preparedSession == nil else { return }
        let session = LanguageModelSession(instructions: instructions)
        session.prewarm()
        preparedSession = session
    }

    /// Pega a sessão pré-aquecida (se houver) ou cria uma nova.
    private static func makeSession() -> LanguageModelSession {
        if let session = preparedSession {
            preparedSession = nil
            return session
        }
        return LanguageModelSession(instructions: instructions)
    }

    // MARK: Disponibilidade

    /// Retorna true quando o modelo do Apple Intelligence
    /// está disponível para uso neste dispositivo.
    static var isAvailable: Bool {

        if case .available = SystemLanguageModel.default.availability {
            return true
        }

        return false
    }

    // MARK: Verificação detalhada

    static func checkAvailability() -> Result<Void, IntelligenceError> {

        let model = SystemLanguageModel.default

        switch model.availability {

        case .available:

            return .success(())

        case .unavailable(.deviceNotEligible):

            return .failure(
                .modelUnavailable(String(localized: "Este dispositivo não é compatível com Apple Intelligence"))
            )

        case .unavailable(.appleIntelligenceNotEnabled):

            return .failure(
                .modelUnavailable(String(localized: "Apple Intelligence não está ativado em Ajustes"))
            )

        case .unavailable(.modelNotReady):

            return .failure(
                .modelUnavailable(String(localized: "O modelo ainda está sendo baixado/preparado. Tente novamente em instantes"))
            )

        case .unavailable(let other):

            return .failure(
                .modelUnavailable(String(localized: "Motivo: \(String(describing: other))"))
            )
        }
    }

    // MARK: Instruções

    private static let instructions = """
        Você extrai os itens consumidos de notas fiscais e comandas de
        supermercados, restaurantes e bares brasileiros.

        Você recebe a FOTO da nota e, às vezes, o texto da mesma nota lido
        por OCR. Use a foto para entender o layout (qual nome está na mesma
        linha de qual preço). Para os NÚMEROS, confie mais no texto do OCR,
        que costuma ler dígitos com mais precisão que a imagem.

        Regras:
        - Um item para cada linha de produto. Se o mesmo produto aparece em
          duas linhas, devolva as duas.
        - name: o nome como está escrito, sem código de barras, sem número
          do item, sem quantidade e sem preço.
        - readableName: o mesmo nome legível para uma pessoa: abreviações
          expandidas, "Pão Francês" em vez de "PAO FRANCES", erros óbvios
          de leitura corrigidos ("C0CA C0LA" → "Coca-Cola"), mantendo marca,
          sabor e tamanho. Não invente nada que não esteja no nome.
        - quantity: a quantidade impressa; 1 se não houver.
        - price: preço de UMA unidade. Se a linha tem unitário e subtotal
          ("2 UN X 3,50 7,00"), use o unitário (3.50). Se só tem o total da
          linha com quantidade maior que 1 ("2 CERVEJA 24,00"), divida
          (12.00).
        - Item vendido por peso ("BANANA 0,530 kg x 6,99/kg 3,70"):
          quantity 1 e price = valor cobrado (3.70), nunca o preço por kg.
        - Ignore subtotal, total, taxa de serviço, gorjeta, troco, desconto,
          forma de pagamento, CNPJ, endereço, data, hora e informações
          fiscais.
        - Nunca invente itens nem preços. Se não conseguir ler uma linha,
          deixe ela de fora.
        - A soma de price × quantity dos itens deve bater com o subtotal
          impresso na nota. Se não bater, revise as linhas antes de responder.
        """

    // MARK: Processamento

    /// Extrai os itens consumidos a partir da FOTO da nota (modelo
    /// multimodal do Foundation Models, iOS 27+). O texto do OCR, quando
    /// existe, vai junto como apoio pros números.
    ///
    /// Se o prompt estourar a janela de contexto (nota muito longa), tenta
    /// de novo só com a foto.
    @available(iOS 27.0, *)
    static func process(
        image: CGImage,
        orientation: CGImagePropertyOrientation = .up,
        ocrText: String? = nil
    ) async throws -> ConsumedItemsResult {

        if case .failure(let error) = checkAvailability() {
            throw error
        }

        let hint = ocrText
            .map { String($0.prefix(maxOCRHintCharacters)) }
            .flatMap { $0.isEmpty ? nil : $0 }

        do {
            return try await respond(image: image, orientation: orientation, ocrHint: hint)

        } catch LanguageModelSession.GenerationError.exceededContextWindowSize(_) where hint != nil {

            print("[Scan] Contexto do modelo estourou com o texto do OCR — tentando só com a foto.")
            do {
                return try await respond(image: image, orientation: orientation, ocrHint: nil)
            } catch {
                throw IntelligenceError.processingFailed(error.localizedDescription)
            }

        } catch {
            throw IntelligenceError.processingFailed(error.localizedDescription)
        }
    }

    @available(iOS 27.0, *)
    private static func respond(
        image: CGImage,
        orientation: CGImagePropertyOrientation,
        ocrHint: String?
    ) async throws -> ConsumedItemsResult {

        // Sessão nova a cada chamada (não queremos histórico de outra nota);
        // usa a pré-aquecida quando existir.
        let session = makeSession()

        // Greedy = sempre a resposta mais provável. Pra extração de dados
        // não queremos criatividade, e a mesma foto passa a dar o mesmo
        // resultado.
        let options = GenerationOptions(sampling: .greedy)

        let response = try await session.respond(
            generating: ConsumedItemsResult.self,
            options: options
        ) {
            "Aqui está a foto de uma nota fiscal. Extraia somente os itens consumidos que aparecem nela."

            Attachment(image, orientation: orientation)

            if let ocrHint {
                """
                Texto da mesma nota lido por OCR (pode ter erros de leitura \
                e linhas fora de ordem, mas os números costumam estar certos):

                \(ocrHint)
                """
            }
        }

        return response.content
    }
}
