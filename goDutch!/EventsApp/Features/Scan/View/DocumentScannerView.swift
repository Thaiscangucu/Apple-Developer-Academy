import SwiftUI
import VisionKit
import AVFoundation
import PhotosUI

struct DocumentScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var path: NavigationPath
    var onScanCompleted: (UIImage) -> Void
    var onCancel: () -> Void
    
    // Referência para controlar o disparador da câmera
    @State private var scannerController: DataScannerViewController?
    
    @State private var isExpanded: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var guidance: ScanGuidance = .pointAtDocument
    
    var body: some View {
        NavigationStack{
            VStack{
                
                Text("**Escaneie** sua notinha")
                  .font(.app(.body))
                  .multilineTextAlignment(.center)
                  // Pega a altura que o texto precisar. Sem isso, a câmera
                  // (70% da tela) e os botões ocupavam todo o espaço e o
                  // título ficava espremido em uma linha: "Escaneie su…".
                  .fixedSize(horizontal: false, vertical: true)
                  .accessibilityAddTraits(.isHeader)

                // Câmera real redimensionada
                ZStack(alignment: .bottom) {
                    DataScannerRepresentable(
                        scannerController: $scannerController,
                        onScanCompleted: onScanCompleted,
                        onCancel: onCancel,
                        onGuidanceChanged: { guidance = $0 }
                    )

                    if let message = guidance.message {
                        Text(message)
                            .font(.app(.footnote, weight: .medium))
                            // Centralizado também quando quebra em mais de
                            // uma linha (fonte grande).
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.black.opacity(0.55), in: Capsule())
                            .padding(.bottom, 20)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: guidance)
                // Fala as dicas de distância ("Aproxime mais a câmera"),
                // já que quem usa VoiceOver pode não ver o aviso na tela.
                .onChange(of: guidance) { _, newGuidance in
                    if let message = newGuidance.message {
                        AccessibilityAnnouncer.announce(message)
                    }
                }
                .cornerRadius(47)
                .shadow(color: .black.opacity(0.25), radius: 8.4, x: 0, y: 9)
                .modifier(CameraHeight())
                Spacer()
                
                HStack(alignment: .center){
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        CircleButton(text: "Add foto galeria", symbol: "photo.on.rectangle", CircleSize: 65, SymbolFont: 25)
                    }
                    .frame(width: isExpanded ? 0 : 63, height: 63)
                    .opacity(isExpanded ? 0 : 1)
                    .disabled(isExpanded)
                    .accessibilityLabel("Adicionar foto da galeria")
                    .accessibilityHint("Escolhe uma foto da nota que já está no seu celular.")
                    .padding(.trailing, 25)
                    .padding(.leading, 42)
                    
                    Spacer()
                    
                    Button {
                        Task {
                            if let photo = try? await scannerController?.capturePhoto() {
                                onScanCompleted(photo)
                            }
                        }
                    }
                    label: {
                        ScanButton(isExpanded: $isExpanded)
                    }
                    .accessibilityLabel("Fotografar a nota")
                    .accessibilityHint("Aponte a câmera para a nota antes de tocar.")
                    
                    Spacer()
                    
                    Button{
                        path.append(Rota.bill(autoOpenForm: true))
                        dismiss()
                    }label:{
                        CircleButton(text: "Add manualmente", symbol: "pencil.and.list.clipboard", CircleSize: 65, SymbolFont: 25)
                    }
                    .accessibilityLabel("Adicionar itens manualmente")
                    .padding(.leading, 25)
                    .padding(.trailing, 42)
                }
                .frame(height: 138)
                .onChange(of: selectedPhotoItem) { _, newItem in
                    guard let newItem else { return }
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            onScanCompleted(uiImage)
                        }
                        selectedPhotoItem = nil
                    }
                }
                
                Spacer()
            }
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button{
                        dismiss()
                    }
                    label:{
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Fechar")
                }
            }
            .containerRelativeFrame(.horizontal) { width, _ in
                width * 0.9
            }
        }
    }
}

/// Altura da câmera: 70% da tela no tamanho de texto normal. Com texto
/// grande o título ocupa mais linhas, então a câmera fica com o espaço que
/// sobrar (em vez de uma altura fixa que espreme o título).
private struct CameraHeight: ViewModifier {
    @Environment(\.dynamicTypeSize) private var typeSize

    func body(content: Content) -> some View {
        if typeSize.isAccessibilitySize {
            content.frame(maxHeight: .infinity)
        } else {
            content.containerRelativeFrame(.vertical) { height, _ in
                height * 0.70
            }
        }
    }
}

// MARK: - Controller Representable NATIVO (DataScannerViewController)
struct DataScannerRepresentable: UIViewControllerRepresentable {
    @Binding var scannerController: DataScannerViewController?
    var onScanCompleted: (UIImage) -> Void
    var onCancel: () -> Void
    var onGuidanceChanged: (ScanGuidance) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text(), .barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: false,
            isHighlightingEnabled: false
        )
        
        scanner.delegate = context.coordinator
        
        // Inicia a captura de câmera
        try? scanner.startScanning()
        
        // Repassa a referência do controller para a View pai
        DispatchQueue.main.async {
            self.scannerController = scanner
        }
        
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onScanCompleted: onScanCompleted, onCancel: onCancel, onGuidanceChanged: onGuidanceChanged)
    }
    
    // MARK: - Coordinator / Delegate
    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScanCompleted: (UIImage) -> Void
        let onCancel: () -> Void
        let onGuidanceChanged: (ScanGuidance) -> Void

        /// Fração da área da tela que o texto reconhecido precisa ocupar
        /// pra ser considerado "perto o suficiente" — abaixo disso, pedimos
        /// pra aproximar; acima do teto, pedimos pra afastar. Ajustar
        /// conforme os testes com notas reais.
        private let tooFarThreshold: CGFloat = 0.05
        private let tooCloseThreshold: CGFloat = 0.5

        init(
            onScanCompleted: @escaping (UIImage) -> Void,
            onCancel: @escaping () -> Void,
            onGuidanceChanged: @escaping (ScanGuidance) -> Void
        ) {
            self.onScanCompleted = onScanCompleted
            self.onCancel = onCancel
            self.onGuidanceChanged = onGuidanceChanged
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                print("Texto detectado ao tocar: \(text.transcript)")
                Task {
                    if let image = try? await dataScanner.capturePhoto() {
                        onScanCompleted(image)
                    }
                }
            default:
                break
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, meBecameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("Scanner indisponível: \(error.localizedDescription)")
            onCancel()
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            updateGuidance(with: allItems, in: dataScanner)
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            updateGuidance(with: allItems, in: dataScanner)
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            updateGuidance(with: allItems, in: dataScanner)
        }

        // MARK: - Cálculo do aviso de distância

        private func updateGuidance(with items: [RecognizedItem], in dataScanner: DataScannerViewController) {
            let viewSize = dataScanner.view.bounds.size
            let viewArea = viewSize.width * viewSize.height
            guard viewArea > 0 else { return }

            guard case let .text(text) = items.first else {
                onGuidanceChanged(.pointAtDocument)
                return
            }

            let bounds = text.bounds
            let area = polygonArea([bounds.topLeft, bounds.topRight, bounds.bottomRight, bounds.bottomLeft])
            let ratio = area / viewArea

            if ratio < tooFarThreshold {
                onGuidanceChanged(.moveCloser)
            } else if ratio > tooCloseThreshold {
                onGuidanceChanged(.moveFarther)
            } else {
                onGuidanceChanged(.none)
            }
        }

        private func polygonArea(_ points: [CGPoint]) -> CGFloat {
            var area: CGFloat = 0
            for i in 0..<points.count {
                let current = points[i]
                let next = points[(i + 1) % points.count]
                area += (current.x * next.y) - (next.x * current.y)
            }
            return abs(area) / 2
        }
    }
}

// MARK: - Preview Provider
#Preview {
    // Container mockup para fornecer o estado de NavigationPath exigido pela View
    struct PreviewContainer: View {
        @State private var path = NavigationPath()
        
        var body: some View {
            NavigationStack(path: $path) {
                DocumentScannerView(
                    path: $path,
                    onScanCompleted: { image in
                        print("[Preview]: Captura concluída com imagem de tamanho: \(image.size)")
                    },
                    onCancel: {
                        print("[Preview]: Ação de cancelamento disparada")
                    }
                )
            }
        }
    }
    
    return PreviewContainer()
}
