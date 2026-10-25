//
//  TextExtractor.swift
//  EventsApp
//
//  Created by Thais Cangucu on 15/09/26.
//


@preconcurrency import Vision
import UIKit

/// Responsável por extrair texto de uma imagem usando o framework Vision (OCR on-device).
/// Essa é uma etapa independente da IA generativa: o Vision só "lê" os caracteres,
/// sem entender o conteúdo semântico do texto.
enum TextExtractor {

    /// Confiança mínima (0...1) que o Vision precisa ter na leitura de uma
    /// observation pra ela entrar no texto final. Abaixo disso, é mais
    /// provável que seja ruído (mancha, dobra do papel, letra cortada) do
    /// que texto de verdade — e ruído nessa etapa vira item errado lá na
    /// frente, no parser. Valor conservador de início; ajustar depois de
    /// testar com notas reais (subir se ainda passar muito lixo, descer se
    /// começar a comer texto válido).
    private static let minimumConfidence: VNConfidence = 0.3

    /// Extri o texto de uma imagem, agrupando observations que estão na mesma
    /// altura visual (mesma linha) antes de juntar tudo, para preservar a ordem
    /// de leitura correta — o Vision não garante que cada observation seja uma
    /// linha completa, então isso evita texto embaralhado.
    static func extractText(from image: UIImage) async -> String {
        guard let cgImage = image.cgImage else { return "" }

        // Sem isso, o Vision ignora o metadado de orientação do UIImage e
        // interpreta os pixels "crus" — se a foto veio deitada (comum em
        // fotos da câmera/galeria), o texto é lido fora de ordem.
        let orientation = image.imageOrientation.cgImagePropertyOrientation

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                let lines = groupIntoLines(observations)
                continuation.resume(returning: lines.joined(separator: "\n"))
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["pt-BR", "en-US"]
            request.usesLanguageCorrection = true
            request.minimumTextHeight = 0.01

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: "")
                }
            }
        }
    }

    /// Agrupa observations que estão na mesma altura (mesma linha visual do documento),
    /// e ordena da esquerda pra direita dentro de cada linha antes de concatenar.
    private static func groupIntoLines(_ observations: [VNRecognizedTextObservation]) -> [String] {
        guard !observations.isEmpty else { return [] }

        let items = observations.compactMap { obs -> (text: String, box: CGRect)? in
            guard let candidate = obs.topCandidates(1).first,
                  candidate.confidence >= minimumConfidence else { return nil }
            return (candidate.string, obs.boundingBox)
        }

        let sortedByY = items.sorted { $0.box.midY > $1.box.midY }

        var rows: [[(text: String, box: CGRect)]] = []

        for item in sortedByY {
            let tolerance = max(item.box.height * 0.6, 0.008)
            if let index = rows.firstIndex(where: { row in
                guard let first = row.first else { return false }
                return abs(first.box.midY - item.box.midY) < tolerance
            }) {
                rows[index].append(item)
            } else {
                rows.append([item])
            }
        }

        return rows.map { row in
            row.sorted { $0.box.minX < $1.box.minX }
                .map { $0.text }
                .joined(separator: " ")
        }
    }
}
