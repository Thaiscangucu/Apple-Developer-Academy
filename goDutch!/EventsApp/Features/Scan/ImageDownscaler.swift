//
//  ImageDownscaler.swift
//  EventsApp
//

import UIKit

/// Reduz a foto da nota antes do processamento.
///
/// A câmera entrega fotos com mais de 12 megapixels, e essa foto passava
/// inteira por todas as etapas (perspectiva, filtros, 3 leituras de OCR e
/// envio pra IA). Texto de nota continua bem legível com ~2400 px no lado
/// maior, e todas as etapas ficam bem mais rápidas.
///
/// Também "assa" a orientação nos pixels: a imagem que sai é sempre `.up`.
enum ImageDownscaler {

    /// Lado maior máximo, em pixels. Suba se notas muito compridas
    /// começarem a perder texto pequeno; desça para ganhar mais velocidade.
    static let maxDimension: CGFloat = 2400

    static func downscaled(_ image: UIImage) async -> UIImage {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(returning: resize(image))
            }
        }
    }

    private static func resize(_ image: UIImage) -> UIImage {
        // Tamanho real em pixels (o `size` do UIImage é em pontos).
        let pixelWidth = image.size.width * image.scale
        let pixelHeight = image.size.height * image.scale
        let longestSide = max(pixelWidth, pixelHeight)

        guard longestSide > maxDimension else { return image }

        let ratio = maxDimension / longestSide
        let targetSize = CGSize(
            width: (pixelWidth * ratio).rounded(),
            height: (pixelHeight * ratio).rounded()
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1          // 1 ponto = 1 pixel
        format.opaque = true      // nota não precisa de transparência

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            // `draw(in:)` já aplica a orientação EXIF da foto.
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
