//
//  ImageEnhancer.swift
//  EventsApp
//
//  Created by Thais Cangucu on 17/09/26.
//

import CoreImage
import UIKit

/// Aplica um tratamento leve na foto antes de mandar pro Vision, pensado
/// pra papel térmico desbotado (o mais comum em nota de mercado/bar):
/// equaliza sombra e brilho desiguais, converte pra escala de cinza com
/// mais contraste, e dá uma leve nitidez pra compensar foco/movimento.
///
/// Cada etapa tem uma saída opcional — se algum filtro falhar por
/// qualquer motivo, a imagem original (ou o resultado da etapa anterior)
/// é usada, pra nunca travar o fluxo de OCR por causa do pré-processamento.
enum ImageEnhancer {

    /// Criar um CIContext é caro (prepara a GPU); um só para o app todo.
    /// CIContext pode ser usado de várias threads com segurança.
    nonisolated(unsafe) private static let context = CIContext()

    static func enhanced(_ image: UIImage) async -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = process(
                    cgImage: cgImage,
                    orientation: image.imageOrientation.cgImagePropertyOrientation,
                    scale: image.scale
                )
                continuation.resume(returning: result ?? image)
            }
        }
    }

    private static func process(cgImage: CGImage, orientation: CGImagePropertyOrientation, scale: CGFloat) -> UIImage? {
        // Aplica a orientação EXIF nos pixels. Sem isso, quando a correção de
        // perspectiva não acha a nota e devolve a foto original (que pode vir
        // "deitada" no metadado), a imagem saía daqui marcada como .up mas com
        // os pixels de lado — e a IA/OCR liam a nota girada.
        let original = CIImage(cgImage: cgImage).oriented(orientation)

        // 1. Equaliza sombra/brilho desiguais (sombra de mão, reflexo do papel térmico).
        let shadowCorrected = highlightShadowAdjusted(original) ?? original

        // 2. Escala de cinza + contraste — texto desbotado fica bem mais legível pro Vision.
        let contrasted = colorAdjusted(shadowCorrected) ?? shadowCorrected

        // 3. Nitidez leve, pra compensar foto levemente fora de foco ou com leve movimento.
        let sharpened = unsharpened(contrasted) ?? contrasted

        guard let outputCGImage = context.createCGImage(sharpened, from: original.extent) else {
            return nil
        }

        return UIImage(cgImage: outputCGImage, scale: scale, orientation: .up)
    }

    // MARK: - Filtros individuais

    private static func highlightShadowAdjusted(_ image: CIImage) -> CIImage? {
        guard let filter = CIFilter(name: "CIHighlightShadowAdjust") else { return nil }
        filter.setValue(image, forKey: kCIInputImageKey)
        // Valores moderados — ajustar depois de testar com notas reais.
        filter.setValue(0.6, forKey: "inputShadowAmount")     // levanta sombra sem lavar a imagem
        filter.setValue(0.75, forKey: "inputHighlightAmount") // suaviza brilho/reflexo do papel
        return filter.outputImage
    }

    private static func colorAdjusted(_ image: CIImage) -> CIImage? {
        guard let filter = CIFilter(name: "CIColorControls") else { return nil }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey) // escala de cinza
        filter.setValue(1.2, forKey: kCIInputContrastKey)   // contraste um pouco acima do normal
        return filter.outputImage
    }

    private static func unsharpened(_ image: CIImage) -> CIImage? {
        guard let filter = CIFilter(name: "CIUnsharpMask") else { return nil }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(2.5, forKey: kCIInputRadiusKey)
        filter.setValue(0.5, forKey: kCIInputIntensityKey)
        return filter.outputImage
    }
}
