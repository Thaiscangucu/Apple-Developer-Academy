//
//  DocumentPerspectiveCorrector.swift
//  EventsApp
//
//  Created by Thais Cangucu on 17/09/26.
//

@preconcurrency import Vision
import CoreImage
import UIKit

/// Detecta os quatro cantos da nota fiscal na foto capturada e aplica
/// correção de perspectiva, recortando e "desempenando" o documento —
/// o mesmo processamento que o scanner nativo da Apple
/// (VNDocumentCameraViewController) faz por trás dos panos antes de
/// entregar a imagem final.
///
/// Se nenhum documento for detectado com confiança suficiente, a imagem
/// original é devolvida sem alteração, pra que o OCR continue funcionando
/// normalmente mesmo sem a correção.
enum DocumentPerspectiveCorrector {

    /// Criar um CIContext é caro (prepara a GPU); um só para o app todo.
    /// CIContext pode ser usado de várias threads com segurança.
    nonisolated(unsafe) private static let context = CIContext()

    /// Área mínima (em coordenadas normalizadas, 0...1) que o quadrilátero
    /// detectado precisa ocupar pra ser considerado a nota de verdade,
    /// e não um retângulo qualquer do fundo da foto (mesa, prato, etc.).
    private static let minimumNormalizedArea: CGFloat = 0.15

    static func correctedImage(from image: UIImage) async -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let orientation = image.imageOrientation.cgImagePropertyOrientation

        let observation = await detectDocument(in: cgImage, orientation: orientation)

        guard let observation, normalizedArea(of: observation) >= minimumNormalizedArea else {
            print("DocumentPerspectiveCorrector: nenhuma borda de nota detectada com confiança suficiente — usando foto original.")
            return image
        }

        guard let corrected = perspectiveCorrectedImage(
            cgImage: cgImage,
            orientation: orientation,
            observation: observation,
            scale: image.scale
        ) else {
            print("DocumentPerspectiveCorrector: falha ao aplicar correção de perspectiva — usando foto original.")
            return image
        }

        return corrected
    }

    // MARK: - Detecção

    private static func detectDocument(
        in cgImage: CGImage,
        orientation: CGImagePropertyOrientation
    ) async -> VNRectangleObservation? {
        await withCheckedContinuation { continuation in
            let request = VNDetectDocumentSegmentationRequest()

            let handler = VNImageRequestHandler(
                cgImage: cgImage,
                orientation: orientation,
                options: [:]
            )

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                    let observation = request.results?.first as? VNRectangleObservation
                    continuation.resume(returning: observation)
                } catch {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    // MARK: - Correção de perspectiva

    private static func perspectiveCorrectedImage(
        cgImage: CGImage,
        orientation: CGImagePropertyOrientation,
        observation: VNRectangleObservation,
        scale: CGFloat
    ) -> UIImage? {
        let ciImage = CIImage(cgImage: cgImage).oriented(orientation)
        let extent = ciImage.extent

        func point(_ normalized: CGPoint) -> CGPoint {
            CGPoint(
                x: extent.origin.x + normalized.x * extent.width,
                y: extent.origin.y + normalized.y * extent.height
            )
        }

        guard let filter = CIFilter(name: "CIPerspectiveCorrection") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgPoint: point(observation.topLeft)), forKey: "inputTopLeft")
        filter.setValue(CIVector(cgPoint: point(observation.topRight)), forKey: "inputTopRight")
        filter.setValue(CIVector(cgPoint: point(observation.bottomLeft)), forKey: "inputBottomLeft")
        filter.setValue(CIVector(cgPoint: point(observation.bottomRight)), forKey: "inputBottomRight")

        guard let outputImage = filter.outputImage else { return nil }

        guard let outputCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return UIImage(cgImage: outputCGImage, scale: scale, orientation: .up)
    }

    // MARK: - Área do quadrilátero (heurística de confiança)

    /// Calcula a área do quadrilátero detectado usando a fórmula do shoelace,
    /// em coordenadas normalizadas (0...1) — serve pra descartar detecções
    /// que pegaram só um pedacinho da cena, e não a nota inteira.
    private static func normalizedArea(of observation: VNRectangleObservation) -> CGFloat {
        let points = [
            observation.topLeft,
            observation.topRight,
            observation.bottomRight,
            observation.bottomLeft
        ]

        var area: CGFloat = 0
        for i in 0..<points.count {
            let current = points[i]
            let next = points[(i + 1) % points.count]
            area += (current.x * next.y) - (next.x * current.y)
        }
        return abs(area) / 2
    }
}
