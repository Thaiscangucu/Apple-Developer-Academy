//
//  ReceiptOrientationChecker.swift
//  EventsApp
//

@preconcurrency import Vision
import UIKit

/// Resultado da checagem de orientação da nota na foto.
nonisolated enum ReceiptOrientation: Equatable {
    case upright
    case upsideDown
    /// Pouco texto legível nas duas posições (foto ruim, nota de lado...).
    /// Não bloqueia: o fluxo segue e os outros erros cuidam do caso.
    case undetermined
}

/// Descobre se a nota foi fotografada de ponta-cabeça.
///
/// O Vision lê texto assumindo a orientação que a gente informa. Então
/// fazemos uma leitura rápida (`.fast`) duas vezes — na orientação da
/// foto e girada 180° — e comparamos o quanto de texto "de verdade" saiu
/// em cada uma. Texto de cabeça pra baixo vira lixo com confiança baixa;
/// na posição certa aparecem palavras e preços ("12,50") com confiança
/// alta.
nonisolated enum ReceiptOrientationChecker {

    /// Pontuação mínima pra considerar que a leitura numa orientação foi
    /// boa o bastante pra decidir alguma coisa.
    private static let minimumScore: Double = 40

    /// Quanto a leitura girada precisa ser melhor que a normal pra
    /// concluir que a nota está de ponta-cabeça. Margem folgada pra nunca
    /// bloquear uma nota que está certa.
    private static let upsideDownRatio: Double = 2.0

    static func check(_ image: UIImage) async -> ReceiptOrientation {
        guard let cgImage = image.cgImage else { return .undetermined }
        let orientation = image.imageOrientation.cgImagePropertyOrientation

        async let uprightScore = readingScore(of: cgImage, orientation: orientation)
        async let flippedScore = readingScore(of: cgImage, orientation: orientation.rotated180)
        let (upright, flipped) = await (uprightScore, flippedScore)

        print("[Scan] Orientação — leitura normal: \(Int(upright)), girada 180°: \(Int(flipped))")

        if flipped >= minimumScore && flipped > upright * upsideDownRatio {
            return .upsideDown
        }
        if upright >= minimumScore {
            return .upright
        }
        return .undetermined
    }

    // MARK: - Pontuação de legibilidade

    private static let priceRegex = try! NSRegularExpression(pattern: #"\d+[,.]\d{2}(?!\d)"#)
    private static let wordRegex = try! NSRegularExpression(pattern: #"\p{L}{3,}"#)

    /// Soma de caracteres lidos com confiança, com bônus pra palavras e
    /// preços bem formados — que praticamente nunca aparecem quando o
    /// texto está sendo lido de cabeça pra baixo.
    private static func readingScore(of cgImage: CGImage, orientation: CGImagePropertyOrientation) async -> Double {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let request = VNRecognizeTextRequest()
                request.recognitionLevel = .fast
                request.usesLanguageCorrection = false
                request.recognitionLanguages = ["pt-BR", "en-US"]

                let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
                try? handler.perform([request])

                continuation.resume(returning: score(of: request.results ?? []))
            }
        }
    }

    private static func score(of observations: [VNRecognizedTextObservation]) -> Double {
        var score: Double = 0

        for observation in observations {
            guard let candidate = observation.topCandidates(1).first,
                  candidate.confidence >= 0.5 else { continue }
            let text = candidate.string
            let range = NSRange(text.startIndex..., in: text)
            let confidence = Double(candidate.confidence)

            let alphanumerics = text.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) }.count
            let words = wordRegex.numberOfMatches(in: text, range: range)
            let prices = priceRegex.numberOfMatches(in: text, range: range)

            score += confidence * Double(alphanumerics + words * 3 + prices * 8)
        }
        return score
    }
}

private extension CGImagePropertyOrientation {
    /// A mesma orientação girada meia volta.
    var rotated180: CGImagePropertyOrientation {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        case .upMirrored: return .downMirrored
        case .downMirrored: return .upMirrored
        case .leftMirrored: return .rightMirrored
        case .rightMirrored: return .leftMirrored
        }
    }
}
