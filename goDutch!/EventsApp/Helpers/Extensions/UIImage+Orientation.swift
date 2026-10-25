//
//  UIImage+Orientation.swift
//  EventsApp
//
//  Created by Thais Cangucu on 17/09/26.
//

import UIKit
import CoreImage

extension UIImage.Orientation {
    /// Converte a orientação do UIImage (que geralmente é só metadado EXIF —
    /// os pixels em si não foram girados) pro tipo que o Vision e o Core
    /// Image esperam, pra interpretarem a imagem do jeito certo.
    ///
    /// Sem isso, uma foto tirada com o celular em pé mas guardada com
    /// orientação landscape (comum em fotos vindas da câmera/galeria) faz o
    /// Vision "ler" a nota deitada, embaralhando a ordem do texto.
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch self {
        case .up: return .up
        case .upMirrored: return .upMirrored
        case .down: return .down
        case .downMirrored: return .downMirrored
        case .left: return .left
        case .leftMirrored: return .leftMirrored
        case .right: return .right
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
