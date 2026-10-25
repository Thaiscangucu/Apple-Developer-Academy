//
//  ScanGuidance.swift
//  EventsApp
//
//  Created by Thais Cangucu on 17/09/26.
//

import Foundation

/// Estado de orientação exibido durante o escaneamento ao vivo.
///
/// Calculado a partir do texto que o Vision já está reconhecendo na
/// câmera (via DataScannerViewControllerDelegate), em vez de depender do
/// overlay nativo da Apple (`isGuidanceEnabled`) — que mostra poucas
/// mensagens e sempre no idioma do sistema, não necessariamente em
/// português.
enum ScanGuidance: Equatable {
    case none
    case pointAtDocument
    case moveCloser
    case moveFarther

    var message: String? {
        switch self {
        case .none:
            return nil
        case .pointAtDocument:
            return String(localized: "Aponte a câmera para a nota")
        case .moveCloser:
            return String(localized: "Aproxime mais a câmera")
        case .moveFarther:
            return String(localized: "Afaste um pouco a câmera")
        }
    }
}
