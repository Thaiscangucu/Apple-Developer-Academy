//
//  CloseAccountScene.swift
//  PaymentCardPOC
//

import SpriteKit
import UIKit
import CoreHaptics

struct MockPerson {
    let emoji: String
    let color: UIColor
    let offset: CGPoint
    let radius: CGFloat
    let isCenter: Bool
}

final class CloseAccountScene: SKScene {
    
    var onPaymentCompleted: (() -> Void)?

    // =====================================================
    // MOCK — LISTA CENTRALIZADA DE DADOS E POSIÇÕES
    // =====================================================
    // Valores medidos no protótipo (offset relativo ao centro da bola, y para cima)
    private let mockPeopleData: [MockPerson] = [
        // Centro (Fixo)
        MockPerson(
            emoji: "😎",
            color: UIColor(red: 10 / 255, green: 218 / 255, blue: 255 / 255, alpha: 1.0),   // #0ADAFF
            offset: CGPoint(x: 1.5, y: 2.5),
            radius: 40.5,
            isCenter: true
        ),

        // Pequenos (Se movem)
        MockPerson(
            emoji: "👨🏻‍🔬",
            color: UIColor(red: 206 / 255, green: 206 / 255, blue: 206 / 255, alpha: 1.0),  // #CECECE
            offset: CGPoint(x: -25.5, y: 70.5),
            radius: 26.5,
            isCenter: false
        ),

        MockPerson(
            emoji: "😇",
            color: UIColor(red: 92 / 255, green: 255 / 255, blue: 10 / 255, alpha: 1.0),    // #5CFF0A
            offset: CGPoint(x: 46.5, y: 55),
            radius: 21.5,
            isCenter: false
        ),

        MockPerson(
            emoji: "🐙",
            color: UIColor(red: 120 / 255, green: 255 / 255, blue: 89 / 255, alpha: 1.0),   // #78FF59
            offset: CGPoint(x: -72.5, y: 34.5),
            radius: 27.5,
            isCenter: false
        ),

        MockPerson(
            emoji: "👨🏼‍💻",
            color: UIColor(red: 255 / 255, green: 214 / 255, blue: 10 / 255, alpha: 1.0),   // #FFD60A
            offset: CGPoint(x: 75.5, y: 3.5),
            radius: 27.5,
            isCenter: false
        ),

        MockPerson(
            emoji: "🌈",
            color: UIColor(red: 255 / 255, green: 10 / 255, blue: 14 / 255, alpha: 1.0),    // #FF0A0E
            offset: CGPoint(x: -63.5, y: -27.5),
            radius: 28.5,
            isCenter: false
        ),

        MockPerson(
            emoji: "🥸",
            color: UIColor(red: 255 / 255, green: 233 / 255, blue: 89 / 255, alpha: 1.0),   // #FFE959
            offset: CGPoint(x: -21.5, y: -61.5),
            radius: 21.5,
            isCenter: false
        ),

        MockPerson(
            emoji: "🎈",
            color: UIColor(red: 254 / 255, green: 181 / 255, blue: 35 / 255, alpha: 1.0),   // #FEB523
            offset: CGPoint(x: 51.5, y: -43.5),
            radius: 21.5,
            isCenter: false
        ),

        MockPerson(
            emoji: "🤓",
            color: UIColor(red: 255 / 255, green: 10 / 255, blue: 202 / 255, alpha: 1.0),   // #FF0ACA
            offset: CGPoint(x: 92.5, y: -40.5),
            radius: 16.5,
            isCenter: false
        )
    ]

    // MARK: - Nodes Esfera e Pessoas

    private struct PersonNodeItem {
        let node: SKNode
        let circle: SKShapeNode
        let emoji: SKLabelNode
        let startPosition: CGPoint
        let targetPosition: CGPoint
        let isCenter: Bool
    }

    private var peopleNodes: [PersonNodeItem] = []
    private var networkLines: [SKShapeNode] = []

    private var sphereCenter: CGPoint = .zero

    // Bola usada durante a aproximação
    private var backgroundBallNode: SKSpriteNode!

    // =====================================================
    // GLASS (segunda etapa)
    // =====================================================

    // Diâmetro do círculo glass (igual ao da bola.png)
    private let glassDiameter: CGFloat = 306

    // Reflexo/brilho de vidro (asset "Ellipse 82")
    private var glassReflectionNode: SKSpriteNode!

    // Camada visual do vidro fosco (renderizada dinamicamente com gradiente e luz)
    private var glassOverlayNode: SKSpriteNode!

    // Node "pai" que agrupa o vidro e o reflexo, controlando o fade in/out
    private var glassGroupNode: SKNode!

    // Contorno iridescente do vidro (ciano / magenta / amarelo)
    private var glassRimNode: SKSpriteNode!

    // Camada "lente": cópias desfocadas das bolinhas vistas através do vidro
    private var lensCropNode: SKCropNode!
    private var lensEffectNode: SKEffectNode!

    // Bolinhas coloridas da explosão (sem emoji)
    private struct ExplosionDot {
        let node: SKShapeNode   // bolinha nítida, fica ATRÁS do vidro
        let lensCopy: SKNode    // cópia desfocada, vista "através" do vidro
        let stretch: CGFloat
    }

    private var explosionDots: [ExplosionDot] = []

    // MARK: - Nodes Cartão/Maquininha

    private var parteDetrasCartao: SKShapeNode!
    private var cartao: SKSpriteNode!
    private var cartaoBlur: SKSpriteNode!
    private var maquininha: SKShapeNode!
    private var progressTrack: SKShapeNode!
    private var bolinhaRS: SKSpriteNode!
    /// "Arraste o cartão para finalizar", dentro da maquininha.
    private var dragHintNode: SKNode!

    // Check agora é imagem
    private var checkNode: SKSpriteNode!

    // Layout
    private var cardStartPosition: CGPoint = .zero
    private var cardEndPosition: CGPoint = .zero
    private var indicatorStartPosition: CGPoint = .zero
    private var indicatorEndPosition: CGPoint = .zero

    private let machineSize = CGSize(width: 336, height: 197)
    private let backMachineSize = CGSize(width: 306, height: 183)
    private let machineCornerRadius: CGFloat = 22.41315
    private let backMachineYOffset: CGFloat = 21
    private let blurRadius: CGFloat = 40

    // Estado
    private var isSceneSetup = false
    private var isDragging = false
    private var hasCompleted = false
    private var currentProgress: CGFloat = 0
    private var touchOffsetX: CGFloat = 0

    // Estado da animação das bolinhas
    private enum BubbleAnimationPhase {
        case approaching
        case disappearing
        case checkAppearing
        case behindGlass
        case exploding
    }

    private var bubblePhase: BubbleAnimationPhase = .approaching

    private let completionThreshold: CGFloat = 0.95
    private let resetDuration: TimeInterval = 0.25
    private let settleDuration: TimeInterval = 0.12

    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)

    // MARK: - Haptics do arrasto do cartão
    /// Toque leve quando o dedo "pega" o cartão.
    private let pickUpHaptic = UIImpactFeedbackGenerator(style: .soft)
    /// Vibração contínua que segue o dedo: começa leve no início do trilho
    /// e vai ficando mais forte (e mais "seca") conforme o cartão chega
    /// perto da maquininha. Com o dedo parado, quase some.
    private var dragHapticEngine: CHHapticEngine?
    private var dragHapticPlayer: CHHapticAdvancedPatternPlayer?
    /// Força no início e no fim do trilho. (Antes começava em 0.08, fraco
    /// demais para sentir no começo do arrasto.)
    private let dragHapticStartIntensity: Float = 0.3
    private let dragHapticEndIntensity: Float = 1.0
    /// Timbre no início e no fim: 0 = grave/abafado, 1 = seco/agudo.
    private let dragHapticStartSharpness: Float = 0.2
    private let dragHapticEndSharpness: Float = 0.55
    /// Curva do aumento: 1 = linear; maior que 1 = segura mais leve no
    /// começo e cresce mais no final.
    private let dragHapticCurve: Float = 1.6
    /// Com o dedo parado por esse tempo, a vibração baixa para quase nada.
    private let dragHapticIdleDelay: TimeInterval = 0.08
    private let dragHapticIdleIntensity: Float = 0.02
    private var lastDragMoveTime: TimeInterval = 0
    private var dragHapticIsIdle = false
    private var lastDragProgress: CGFloat = 0

    /// "Cliques" ao longo do trilho, como marcas de uma régua: um a cada
    /// 1/`dragTickSteps` do caminho, ficando mais fortes perto do fim.
    /// Somam-se à vibração contínua e são fáceis de sentir.
    private let dragTickHaptic = UIImpactFeedbackGenerator(style: .rigid)
    private let dragTickSteps = 8
    private let dragTickStartIntensity: CGFloat = 0.35
    private let dragTickEndIntensity: CGFloat = 1.0
    private var lastDragTick = 0

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = .white

        if !isSceneSetup {
            setupScene()
            isSceneSetup = true
        }
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        // Dedo parado em cima do cartão não gera touchesMoved: depois de um
        // instante sem movimento, a vibração baixa para quase nada.
        if dragHapticPlayer != nil,
           !dragHapticIsIdle,
           CACurrentMediaTime() - lastDragMoveTime > dragHapticIdleDelay {
            dragHapticIsIdle = true
            sendDragHaptic(intensity: dragHapticIdleIntensity, progress: lastDragProgress)
        }

        if !explosionDots.isEmpty {
            updateLensCopies()
        }
    }

    // MARK: - Setup Principal

    private func setupScene() {
        hapticGenerator.prepare()

        hasCompleted = false
        currentProgress = 0
        isDragging = false
        touchOffsetX = 0
        bubblePhase = .approaching

        sphereCenter = CGPoint(
            x: size.width / 2,
            y: size.height * 0.55
        )

        setupBackgroundGradient()
        setupTypography()

        // Área das bolinhas
        setupSphere()
        setupGlassLens()
        setupMockPeopleAndLines()
        setupSuccessCheckmark()

        // Setup da Maquininha
        setupBackCard()
        setupCard()
        setupBlurCard()
        setupMachine()
        setupProgressIndicator()
        setupDragHint()

        updatePositions(progress: 0)
    }

    // MARK: - Fundo (gradiente)

    /// Textura do gradiente de fundo, do tamanho da cena. Equivale a:
    /// LinearGradient(white → (0.88, 0.95, 1),
    ///                startPoint: (0.5, 0.12), endPoint: (0.5, 1))
    private lazy var backgroundGradientTexture: SKTexture = {
        let renderSize = size
        let image = UIGraphicsImageRenderer(size: renderSize).image { ctx in
            let colors = [
                UIColor.white.cgColor,
                UIColor(red: 0.88, green: 0.95, blue: 1, alpha: 1).cgColor
            ] as CFArray

            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: [0, 1]
            ) else { return }

            // UIKit: y = 0 é o topo, igual ao UnitPoint do SwiftUI
            ctx.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: renderSize.width * 0.5, y: renderSize.height * 0.12),
                end: CGPoint(x: renderSize.width * 0.5, y: renderSize.height),
                options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
            )
        }
        return SKTexture(image: image)
    }()

    /// Sprite com o gradiente de fundo, do tamanho da cena.
    private func makeBackgroundGradientNode() -> SKSpriteNode {
        let node = SKSpriteNode(texture: backgroundGradientTexture)
        node.size = size
        return node
    }

    private func setupBackgroundGradient() {
        let bg = makeBackgroundGradientNode()
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -10
        addChild(bg)
    }

    // MARK: - Setup Customizado (Conta)

    private func setupTypography() {

        let titleNode1 = SKLabelNode(fontNamed: "MontserratAlternates-Regular")
        titleNode1.text = String(localized: "Hora de ")
        titleNode1.horizontalAlignmentMode = .left
        titleNode1.fontColor = .black

        let titleNodeBold = SKLabelNode(fontNamed: "MontserratAlternates-Bold")
        titleNodeBold.text = String(localized: "fechar")
        titleNodeBold.horizontalAlignmentMode = .left
        titleNodeBold.fontColor = .black

        let titleNode2 = SKLabelNode(fontNamed: "MontserratAlternates-Regular")
        titleNode2.text = String(localized: " a conta!")
        titleNode2.horizontalAlignmentMode = .left
        titleNode2.fontColor = .black

        // Tamanho do título: 32pt no tamanho de texto padrão e maior quando
        // a fonte do iPhone está maior (Dynamic Type), sem passar da largura
        // da tela nem de `maxTitleScale`.
        let fontSize = titleFontSize(for: [titleNode1, titleNodeBold, titleNode2])
        let scale = fontSize / baseTitleFontSize

        titleNode1.fontSize = fontSize
        titleNodeBold.fontSize = fontSize
        titleNode2.fontSize = fontSize

        // O topo do título fica no mesmo lugar de sempre; com a fonte maior
        // ele cresce para baixo (e não para baixo da barra de navegação).
        let firstLineY = size.height - 120 - (fontSize - baseTitleFontSize) * 0.75

        titleNode1.position = CGPoint(x: 30, y: firstLineY)
        titleNodeBold.position = CGPoint(
            x: titleNode1.frame.maxX + 8 * scale,
            y: firstLineY
        )
        titleNode2.position = CGPoint(x: 30, y: firstLineY - 40 * scale)

        addChild(titleNode1)
        addChild(titleNodeBold)
        addChild(titleNode2)
    }

    /// Tamanho do título no tamanho de texto padrão do iPhone.
    private let baseTitleFontSize: CGFloat = 32

    /// Até quantas vezes o título pode crescer com a fonte grande.
    private let maxTitleScale: CGFloat = 1.8

    /// Tamanho do título acompanhando o Dynamic Type (estilo Title 1),
    /// limitado para a primeira linha ("Hora de fechar") caber na tela.
    private func titleFontSize(for nodes: [SKLabelNode]) -> CGFloat {
        let scaled = UIFontMetrics(forTextStyle: .title1).scaledValue(for: baseTitleFontSize)
        var fontSize = min(max(scaled, baseTitleFontSize), baseTitleFontSize * maxTitleScale)

        // Mede a primeira linha no tamanho base e reduz se não couber.
        nodes.forEach { $0.fontSize = baseTitleFontSize }
        let firstLineWidth = nodes[0].frame.width + 8 + nodes[1].frame.width
        let secondLineWidth = nodes[2].frame.width
        let widest = max(firstLineWidth, secondLineWidth)
        let available = size.width - 60

        if widest > 0 {
            fontSize = min(fontSize, baseTitleFontSize * available / widest)
        }

        return max(fontSize, baseTitleFontSize)
    }

    // MARK: - Esfera / Bola

    private func setupSphere() {

        // Tamanho do protótipo (igual ao asset bola.png)
        let diameter: CGFloat = 270

        // =================================================
        // BOLA.PNG (usada apenas na primeira etapa)
        // =================================================

        let texture = SKTexture(imageNamed: "bola")

        backgroundBallNode = SKSpriteNode(texture: texture)

        backgroundBallNode.size = CGSize(
            width: diameter,
            height: diameter
        )

        backgroundBallNode.position = sphereCenter

        // Atrás das bolinhas
        backgroundBallNode.zPosition = 4

        backgroundBallNode.alpha = 1

        addChild(backgroundBallNode)
    }

    // MARK: - Glass (construído manualmente, sem bola.png)

    private func setupGlassLens() {

        let radius = glassDiameter / 2

        // Grupo que controla o fade in/out geral do glass
        glassGroupNode = SKNode()
        glassGroupNode.position = sphereCenter
        glassGroupNode.zPosition = 8
        glassGroupNode.alpha = 0
        addChild(glassGroupNode)

        // -----------------------------------------------
        // 1. Corpo principal de vidro fosco (frosted glass)
        // -----------------------------------------------
        let glassTexture = makeGlassTexture(diameter: glassDiameter)

        glassOverlayNode = SKSpriteNode(texture: glassTexture)
        glassOverlayNode.size = CGSize(width: glassDiameter, height: glassDiameter)
        glassOverlayNode.zPosition = 1
        glassOverlayNode.blendMode = .alpha
        glassGroupNode.addChild(glassOverlayNode)

        // -----------------------------------------------
        // 1b. Lente: o que está atrás do vidro aparece desfocado
        // -----------------------------------------------
        let lensMask = SKShapeNode(circleOfRadius: radius - 1)
        lensMask.fillColor = .white
        lensMask.strokeColor = .clear

        lensCropNode = SKCropNode()
        lensCropNode.maskNode = lensMask
        lensCropNode.zPosition = 1.5
        glassGroupNode.addChild(lensCropNode)

        lensEffectNode = SKEffectNode()
        let lensBlur = CIFilter(name: "CIGaussianBlur")
        lensBlur?.setValue(1.2, forKey: kCIInputRadiusKey)
        lensEffectNode.filter = lensBlur
        lensEffectNode.shouldEnableEffects = true
        // No protótipo o que está atrás do vidro aparece um pouco "lavado"
        lensEffectNode.alpha = 0.83
        lensCropNode.addChild(lensEffectNode)

        // Área invisível que garante que o blur não seja cortado em retângulo
        let lensPadding = SKSpriteNode(
            color: UIColor(white: 1, alpha: 0.001),
            size: CGSize(width: glassDiameter + 60, height: glassDiameter + 60)
        )
        lensEffectNode.addChild(lensPadding)

        // -----------------------------------------------
        // 1c. Contorno iridescente
        // -----------------------------------------------
        glassRimNode = SKSpriteNode(
            texture: makeIridescentRimTexture(diameter: glassDiameter)
        )
        glassRimNode.size = CGSize(width: glassDiameter, height: glassDiameter)
        glassRimNode.zPosition = 2
        glassGroupNode.addChild(glassRimNode)

        // -----------------------------------------------
        // 2. Reflexo de luz (asset "Ellipse 82")
        // -----------------------------------------------
        let reflectionTexture = SKTexture(imageNamed: "Ellipse 82")

        glassReflectionNode = SKSpriteNode(texture: reflectionTexture)

        // O asset já vem inclinado; tamanho e posição medidos no protótipo
        glassReflectionNode.size = CGSize(width: 77, height: 43)

        glassReflectionNode.position = CGPoint(x: -50, y: 101)

        glassReflectionNode.alpha = 0.55
        glassReflectionNode.color = UIColor(white: 0.62, alpha: 1)
        glassReflectionNode.colorBlendFactor = 1.0
        glassReflectionNode.blendMode = .alpha

        // Franjas coloridas do reflexo (lado de cima/esquerda)
        let fringes: [(UIColor, CGPoint, CGFloat)] = [
            (UIColor(red: 1.0, green: 0.30, blue: 0.85, alpha: 1), CGPoint(x: -1.2, y: 1.2), 0.55),
            (UIColor(red: 1.0, green: 0.88, blue: 0.25, alpha: 1), CGPoint(x: -2.4, y: 2.4), 0.55),
            (UIColor(red: 0.30, green: 0.85, blue: 1.0, alpha: 1), CGPoint(x: -3.4, y: 3.2), 0.40)
        ]

        for (fringeColor, offset, fringeAlpha) in fringes {
            let fringe = SKSpriteNode(texture: reflectionTexture)
            fringe.size = glassReflectionNode.size
            fringe.position = offset
            fringe.color = fringeColor
            fringe.colorBlendFactor = 1.0
            fringe.alpha = fringeAlpha
            fringe.zPosition = -0.1
            glassReflectionNode.addChild(fringe)
        }

        glassReflectionNode.zPosition = 3

        // Reflexo oval removido do visual
        glassReflectionNode.isHidden = true

        glassGroupNode.addChild(glassReflectionNode)
    }

    /// Corpo do vidro: cinza claro (#F7F7F7) opaco, igual ao protótipo.
    /// É opaco de propósito: as bolinhas reais ficam escondidas atrás dele
    /// e o que aparece "dentro" é a camada de lente (desfocada).
    private func makeGlassTexture(diameter: CGFloat) -> SKTexture {

        let sizeInPx = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: sizeInPx)

        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let rect = CGRect(origin: .zero, size: sizeInPx)

            cg.addEllipse(in: rect)
            cg.clip()

            // Cinza do protótipo: #F7F7F7, chapado
            cg.setFillColor(UIColor(white: 247.0 / 255.0, alpha: 1).cgColor)
            cg.fill(rect)
        }

        return SKTexture(image: image)
    }

    /// Brilho iridescente na borda do vidro (ciano, magenta e amarelo),
    /// como no protótipo.
    private func makeIridescentRimTexture(diameter: CGFloat) -> SKTexture {

        let sizeInPx = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: sizeInPx)

        let magenta = UIColor(red: 1.00, green: 0.30, blue: 0.85, alpha: 1)
        let yellow = UIColor(red: 1.00, green: 0.85, blue: 0.20, alpha: 1)

        let softCyan = UIColor(red: 0.36, green: 0.88, blue: 0.97, alpha: 1)
        let green = UIColor(red: 0.35, green: 0.80, blue: 0.45, alpha: 1)

        // (início°, fim°, cor, intensidade, distância da borda, espessura, blur)
        // 0° = direita, ângulos crescem no sentido horário (coordenadas da tela)
        let arcs: [(CGFloat, CGFloat, UIColor, CGFloat, CGFloat, CGFloat, CGFloat)] = [
            // faixa ciano grossa no canto superior direito
            (-56, -27, softCyan, 0.80, 10, 9, 7),
            // linhas finas na borda
            (-115, -62, magenta, 0.50, 0.8, 1.5, 1),
            (-62, -54, yellow, 0.35, 0.8, 1.5, 1),
            (20, 55, magenta, 0.22, 0.8, 1.5, 1),
            (92, 104, softCyan, 0.55, 2, 4, 3),
            (112, 128, yellow, 0.50, 0.8, 1.5, 1),
            (128, 142, green, 0.40, 0.8, 1.5, 1),
            (172, 186, softCyan, 0.55, 1.5, 3, 2)
        ]

        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let rect = CGRect(origin: .zero, size: sizeInPx)
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = diameter / 2

            cg.addEllipse(in: rect)
            cg.clip()

            for (start, end, color, strength, inset, width, blur) in arcs {
                let path = UIBezierPath(
                    arcCenter: center,
                    radius: radius - inset,
                    startAngle: start * .pi / 180,
                    endAngle: end * .pi / 180,
                    clockwise: true
                )

                cg.saveGState()
                cg.setShadow(
                    offset: .zero,
                    blur: blur,
                    color: color.withAlphaComponent(strength).cgColor
                )
                cg.setStrokeColor(color.withAlphaComponent(strength).cgColor)
                cg.setLineWidth(width)
                cg.setLineCap(.round)
                cg.addPath(path.cgPath)
                cg.strokePath()
                cg.restoreGState()
            }

        }

        return SKTexture(image: image)
    }

    // MARK: - Bolinhas

    private func setupMockPeopleAndLines() {
        peopleNodes.removeAll()
        networkLines.removeAll()

        // Linhas
        for person in mockPeopleData where !person.isCenter {

            let line = SKShapeNode()

            // No protótipo essas linhas não aparecem (só o fio da bola.png)
            line.strokeColor = .clear
            line.lineWidth = 1.5

            // Atrás das bolinhas
            line.zPosition = 5

            addChild(line)

            networkLines.append(line)
        }

        // Pessoas
        for person in mockPeopleData {

            let container = SKNode()

            // Bolinhas na frente da bola.png
            container.zPosition = person.isCenter ? 7 : 6

            let circle = SKShapeNode(
                circleOfRadius: person.radius
            )

            circle.fillColor = person.color
            circle.strokeColor = .clear

            container.addChild(circle)

            let emojiLabel = SKLabelNode(
                text: person.emoji
            )

            emojiLabel.fontSize = person.radius * 1.16

            emojiLabel.verticalAlignmentMode = .center
            emojiLabel.horizontalAlignmentMode = .center

            container.addChild(emojiLabel)

            let startPos = CGPoint(
                x: sphereCenter.x + person.offset.x,
                y: sphereCenter.y + person.offset.y
            )

            container.position = startPos

            addChild(container)

            peopleNodes.append(
                PersonNodeItem(
                    node: container,
                    circle: circle,
                    emoji: emojiLabel,
                    startPosition: startPos,
                    targetPosition: sphereCenter,
                    isCenter: person.isCenter
                )
            )
        }
    }

    // MARK: - Check

    private func setupSuccessCheckmark() {
        
        let texture = SKTexture(imageNamed: "check.png")
        checkNode = SKSpriteNode(texture: texture)
        checkNode.size = CGSize(width: 131, height: 127)
        checkNode.position = sphereCenter
        checkNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        checkNode.zPosition = 30
        checkNode.alpha = 0
        checkNode.setScale(0.1)
        addChild(checkNode)
    }
    
    private func showCheck() {
        
        checkNode.removeAllActions()
        checkNode.position = sphereCenter
        checkNode.alpha = 0
        checkNode.setScale(0.1)
        
        let appear = SKAction.fadeIn(withDuration: 0.12)
        let grow = SKAction.scale(to: 1.0, duration: 0.30)
        
        grow.timingMode = .easeOut

        // No protótipo o check fica levemente "lavado" pelo vidro (83%)
        let wash = SKAction.fadeAlpha(to: 0.83, duration: 0.10)

        checkNode.run(
            SKAction.sequence([
                SKAction.group([appear, grow]),
                wash
            ])
        )
    }

    // MARK: - Setup Maquininha

    private func groupCenter() -> CGPoint {
        CGPoint(
            x: size.width * 0.50,
            y: 33.5
        )
    }

    private func machineCenter() -> CGPoint {
        let center = groupCenter()

        return CGPoint(
            x: center.x,
            y: center.y
        )
    }

    private func cardStartCenter() -> CGPoint {
        let center = groupCenter()

        return CGPoint(
            x: center.x - machineSize.width * 0.5,
            y: center.y + 109
        )
    }

    private func cardEndCenter() -> CGPoint {
        let center = machineCenter()

        return CGPoint(
            x: center.x + machineSize.width * 0.62,
            y: center.y + 109
        )
    }

    private func setupBackCard() {
        parteDetrasCartao = SKShapeNode(
            rectOf: backMachineSize,
            cornerRadius: machineCornerRadius
        )

        // ParteDetrasCartao.svg: preto com 6% de opacidade
        parteDetrasCartao.fillColor =
            UIColor(white: 0, alpha: 0.06)

        parteDetrasCartao.strokeColor = .clear

        let machinePosition = machineCenter()

        parteDetrasCartao.position = CGPoint(
            x: machinePosition.x,
            y: machinePosition.y + backMachineYOffset
        )

        parteDetrasCartao.zPosition = 0

        addChild(parteDetrasCartao)
    }

    private func setupCard() {
        let texture = SKTexture(
            imageNamed: "Cartao"
        )

        cartao = SKSpriteNode(
            texture: texture
        )

        cartao.size = CGSize(
            width: 332,
            height: 243
        )

        cardStartPosition = cardStartCenter()
        cardEndPosition = cardEndCenter()

        cartao.position = cardStartPosition
        cartao.zPosition = 1

        addChild(cartao)
    }

    private func setupBlurCard() {
        let texture = SKTexture(
            imageNamed: "Cartao"
        )

        cartaoBlur = SKSpriteNode(
            texture: texture
        )

        cartaoBlur.size = cartao.size
        cartaoBlur.position = .zero

        let blurFilter = CIFilter(
            name: "CIGaussianBlur"
        )

        blurFilter?.setValue(
            blurRadius,
            forKey: kCIInputRadiusKey
        )

        let effectNode = SKEffectNode()

        effectNode.filter = blurFilter
        effectNode.shouldEnableEffects = true
        // O cartão desfocado não muda, só se move: dá pra cachear o blur
        effectNode.shouldRasterize = true
        effectNode.zPosition = 0.2

        // Área invisível para o desfoque "vazar" para fora do cartão
        let cardBlurPadding = SKSpriteNode(
            color: UIColor(white: 1, alpha: 0.001),
            size: CGSize(
                width: cartao.size.width + blurRadius * 6,
                height: cartao.size.height + blurRadius * 6
            )
        )
        effectNode.addChild(cardBlurPadding)

        effectNode.addChild(cartaoBlur)

        let mask = SKShapeNode(
            rectOf: machineSize,
            cornerRadius: machineCornerRadius
        )

        mask.fillColor = .white
        mask.strokeColor = .clear

        let cropNode = SKCropNode()

        cropNode.maskNode = mask
        cropNode.position = machineCenter()
        cropNode.zPosition = 1.5

        // Fundo do vidro: o mesmo gradiente da cena (o que está atrás da
        // maquininha), alinhado com o fundo e recortado pela máscara.
        let glassBase = makeBackgroundGradientNode()
        glassBase.position = CGPoint(
            x: size.width / 2 - machineCenter().x,
            y: size.height / 2 - machineCenter().y
        )
        glassBase.zPosition = 0
        cropNode.addChild(glassBase)

        // Parte de trás vista através do vidro (desfocada, parada)
        let backBlurNode = SKEffectNode()
        backBlurNode.filter = CIFilter(
            name: "CIGaussianBlur",
            parameters: [kCIInputRadiusKey: blurRadius]
        )
        backBlurNode.shouldEnableEffects = true
        backBlurNode.shouldRasterize = true
        backBlurNode.zPosition = 0.1

        let backPadding = SKSpriteNode(
            color: UIColor(white: 1, alpha: 0.001),
            size: CGSize(
                width: machineSize.width + blurRadius * 6,
                height: machineSize.height + blurRadius * 6
            )
        )
        backBlurNode.addChild(backPadding)

        let backCopy = SKShapeNode(
            rectOf: backMachineSize,
            cornerRadius: machineCornerRadius
        )
        backCopy.fillColor = UIColor(white: 0, alpha: 0.06)
        backCopy.strokeColor = .clear
        backCopy.position = CGPoint(x: 0, y: backMachineYOffset)
        backBlurNode.addChild(backCopy)

        cropNode.addChild(backBlurNode)

        cropNode.addChild(effectNode)

        effectNode.position = CGPoint(
            x: cardStartPosition.x - machineCenter().x,
            y: cardStartPosition.y - machineCenter().y
        )

        addChild(cropNode)
    }

    private func setupMachine() {
        maquininha = SKShapeNode(
            rectOf: machineSize,
            cornerRadius: machineCornerRadius
        )

        // Maquininha.svg: preto com 6% de opacidade + borda clara de vidro
        maquininha.fillColor =
            UIColor(white: 0, alpha: 0.06)

        maquininha.strokeColor = UIColor(white: 1, alpha: 0.6)
        maquininha.lineWidth = 1
        maquininha.position = machineCenter()
        maquininha.zPosition = 2

        addChild(maquininha)
    }

    /// Texto "**Arraste** o cartão para finalizar", centralizado na
    /// maquininha logo abaixo do trilho.
    private func setupDragHint() {
        let fontSize: CGFloat = 12

        let boldNode = SKLabelNode(fontNamed: "MontserratAlternates-Bold")
        boldNode.text = String(localized: "Arraste")
        boldNode.fontSize = fontSize
        boldNode.fontColor = .white
        boldNode.horizontalAlignmentMode = .left
        boldNode.verticalAlignmentMode = .center

        let regularNode = SKLabelNode(fontNamed: "MontserratAlternates-Regular")
        regularNode.text = String(localized: " o cartão para finalizar")
        regularNode.fontSize = fontSize
        regularNode.fontColor = .white
        regularNode.horizontalAlignmentMode = .left
        regularNode.verticalAlignmentMode = .center

        // Centraliza as duas partes juntas
        let totalWidth = boldNode.frame.width + regularNode.frame.width
        boldNode.position = CGPoint(x: -totalWidth / 2, y: 0)
        regularNode.position = CGPoint(x: boldNode.position.x + boldNode.frame.width, y: 0)

        let container = SKNode()
        container.addChild(boldNode)
        container.addChild(regularNode)

        let mPosition = machineCenter()
        let machineTop = mPosition.y + machineSize.height / 2
        let trackY = machineTop - 24

        container.position = CGPoint(x: mPosition.x, y: trackY - 26)
        container.zPosition = 3

        // O VoiceOver já tem o botão próprio em CardView
        container.isAccessibilityElement = false

        dragHintNode = container
        addChild(container)
    }

    private func setupProgressIndicator() {

        let mPosition = machineCenter()

        // Posições do Maquininha.svg
        let machineLeft = mPosition.x - machineSize.width / 2
        let machineTop = mPosition.y + machineSize.height / 2

        let trackY = machineTop - 24

        indicatorStartPosition = CGPoint(
            x: machineLeft + 55,
            y: trackY
        )

        indicatorEndPosition = CGPoint(
            x: machineLeft + 294,
            y: trackY
        )

        let path = CGMutablePath()

        path.move(
            to: indicatorStartPosition
        )

        path.addLine(
            to: indicatorEndPosition
        )

        progressTrack = SKShapeNode(
            path: path
        )

        progressTrack.strokeColor = .white

        progressTrack.lineWidth = 2
        progressTrack.lineCap = .round
        progressTrack.zPosition = 3

        addChild(progressTrack)

        // Pontinho branco no fim da linha
        let trackEndDot = SKShapeNode(circleOfRadius: 5.33)
        trackEndDot.fillColor = .white
        trackEndDot.strokeColor = .clear
        trackEndDot.position = indicatorEndPosition
        trackEndDot.zPosition = 2.9
        addChild(trackEndDot)

        let texture = SKTexture(
            imageNamed: "BolinhaRS"
        )

        bolinhaRS = SKSpriteNode(
            texture: texture
        )

        // BolinhaRS.svg: 25 x 25
        let diameter: CGFloat = 25

        bolinhaRS.size = CGSize(
            width: diameter,
            height: diameter
        )

        bolinhaRS.position =
            indicatorStartPosition

        bolinhaRS.zPosition = 3

        addChild(bolinhaRS)
    }

    private func updateBlurCardPosition() {

        guard let cropNode =
                cartaoBlur.parent?.parent as? SKCropNode,

              let effectNode =
                cartaoBlur.parent as? SKEffectNode
        else {
            return
        }

        let mPosition = machineCenter()

        cropNode.position = mPosition

        effectNode.position = CGPoint(
            x: cartao.position.x - mPosition.x,
            y: cartao.position.y - mPosition.y
        )

        cartaoBlur.position = .zero
    }

    // MARK: - Touches

    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        guard let touch = touches.first else {
            return
        }

        if hasCompleted {
           // resetInteraction()
            return
        }

        let location = touch.location(
            in: self
        )

        if cartao.contains(location) || bolinhaRS.contains(location) {
            isDragging = true

            touchOffsetX = cartao.position.x - location.x

            cartao.removeAllActions()
            bolinhaRS.removeAllActions()

            startDragHaptics()
        }
    }

    override func touchesMoved(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        guard
            isDragging,
            !hasCompleted,
            let touch = touches.first
        else {
            return
        }

        let location = touch.location(
            in: self
        )

        let proposedX =
            location.x + touchOffsetX

        let clampedX = min(
            max(
                proposedX,
                cardStartPosition.x
            ),
            cardEndPosition.x
        )

        let cardMoved = abs(cartao.position.x - clampedX) > 0.5
        cartao.position.x = clampedX

        updateBlurCardPosition()

        let progress = min(
            max(
                (
                    cartao.position.x -
                    cardStartPosition.x
                )
                /
                (
                    cardEndPosition.x -
                    cardStartPosition.x
                ),
                0
            ),
            1
        )

        currentProgress = progress

        if cardMoved {
            updateDragHaptics(progress: progress)
        }

        let indicatorX = min(
            max(
                location.x,
                indicatorStartPosition.x
            ),
            indicatorEndPosition.x
        )

        bolinhaRS.position = CGPoint(
            x: indicatorX,
            y: indicatorStartPosition.y
        )

        updatePositions(
            progress: currentProgress
        )

        if currentProgress >= completionThreshold &&
            !hasCompleted {

            completeInteraction()
        }
    }

    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        guard isDragging else {
            return
        }

        isDragging = false
        stopDragHaptics()

        if !hasCompleted {
            let remainingProgress = max(0, 1 - currentProgress)

            let duration = TimeInterval(
                max(
                    0.15,
                    min(0.5, 0.5 * remainingProgress)
                )
            )

            let moveCard = SKAction.move(
                to: cardEndPosition,
                duration: duration
            )

            let moveIndicator = SKAction.move(
                to: indicatorEndPosition,
                duration: duration
            )

            moveCard.timingMode = .easeOut
            moveIndicator.timingMode = .easeOut

            cartao.run(moveCard)
            bolinhaRS.run(moveIndicator) {
                self.completeInteraction()
            }
        }
    }

    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        touchesEnded(
            touches,
            with: event
        )
    }

    // MARK: - Haptics do arrasto

    /// Começa a vibração do arrasto: um toque leve ao pegar o cartão e uma
    /// vibração contínua que, a partir daí, é controlada pelo dedo
    /// (`updateDragHaptics`). Começa em silêncio até o cartão se mover.
    /// Só toca se "Animações & haptics" estiver ligado nos Ajustes.
    private func startDragHaptics() {
        guard AppSettings.isAnimationsOn else { return }

        pickUpHaptic.impactOccurred(intensity: 0.5)

        // Prepara os cliques do trilho a partir de onde o cartão está.
        lastDragTick = Int(currentProgress * CGFloat(dragTickSteps))
        dragTickHaptic.prepare()

        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        stopDragHaptics()

        do {
            if dragHapticEngine == nil {
                let engine = try CHHapticEngine()
                engine.playsHapticsOnly = true
                engine.isAutoShutdownEnabled = true
                engine.resetHandler = { [weak self] in
                    DispatchQueue.main.async {
                        self?.dragHapticPlayer = nil
                        try? self?.dragHapticEngine?.start()
                    }
                }
                engine.stoppedHandler = { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.dragHapticPlayer = nil
                    }
                }
                dragHapticEngine = engine
            }

            guard let engine = dragHapticEngine else { return }
            try engine.start()

            // Evento contínuo longo com força/timbre "cheios"; o valor real
            // é ajustado em tempo real pelos parâmetros de controle.
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: dragHapticStartSharpness)
                ],
                relativeTime: 0,
                duration: 30
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makeAdvancedPlayer(with: pattern)
            dragHapticPlayer = player

            // Começa sem vibrar: só vibra quando o cartão se mexe.
            lastDragProgress = currentProgress
            dragHapticIsIdle = true
            sendDragHaptic(intensity: 0, progress: currentProgress)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            dragHapticPlayer = nil
        }
    }

    /// Chamado a cada movimento do dedo: a força e o timbre dependem de
    /// onde o cartão está no trilho (leve no início, forte no final).
    private func updateDragHaptics(progress: CGFloat) {
        lastDragMoveTime = CACurrentMediaTime()
        lastDragProgress = progress
        dragHapticIsIdle = false

        let p = Float(min(max(progress, 0), 1))
        let eased = powf(p, dragHapticCurve)
        let intensity = dragHapticStartIntensity
            + (dragHapticEndIntensity - dragHapticStartIntensity) * eased

        sendDragHaptic(intensity: intensity, progress: progress)
        playDragTickIfNeeded(progress: progress)
    }

    /// Dá um clique quando o cartão passa por uma das marcas do trilho
    /// (indo ou voltando).
    private func playDragTickIfNeeded(progress: CGFloat) {
        guard AppSettings.isAnimationsOn else { return }

        let tick = Int(min(max(progress, 0), 1) * CGFloat(dragTickSteps))
        guard tick != lastDragTick else { return }
        lastDragTick = tick

        // A última marca é o fim do trilho: lá já toca o toque de conclusão.
        guard tick < dragTickSteps else { return }

        let intensity = dragTickStartIntensity
            + (dragTickEndIntensity - dragTickStartIntensity) * progress
        dragTickHaptic.impactOccurred(intensity: intensity)
        dragTickHaptic.prepare()
    }

    /// Envia força e timbre para a vibração que já está tocando.
    private func sendDragHaptic(intensity: Float, progress: CGFloat) {
        guard let dragHapticPlayer else { return }

        let p = Float(min(max(progress, 0), 1))
        // O controle de timbre é somado ao timbre do evento (início).
        let sharpnessOffset = (dragHapticEndSharpness - dragHapticStartSharpness) * p

        try? dragHapticPlayer.sendParameters(
            [
                CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: intensity, relativeTime: 0),
                CHHapticDynamicParameter(parameterID: .hapticSharpnessControl, value: sharpnessOffset, relativeTime: 0)
            ],
            atTime: CHHapticTimeImmediate
        )
    }

    /// Para a vibração do arrasto (dedo soltou, conta fechou ou reset).
    private func stopDragHaptics() {
        try? dragHapticPlayer?.stop(atTime: CHHapticTimeImmediate)
        dragHapticPlayer = nil
    }

    // MARK: - Acessibilidade (VoiceOver)

    /// Fecha a conta sem arrastar o cartão — o VoiceOver não enxerga os
    /// nós do SpriteKit. Faz o mesmo caminho de quando o dedo solta o
    /// cartão: leva cartão e indicador até o fim e conclui.
    func accessibilityCloseAccount() {
        guard isSceneSetup, !hasCompleted else {
            return
        }

        isDragging = false

        cartao.removeAllActions()
        bolinhaRS.removeAllActions()

        let moveCard = SKAction.move(
            to: cardEndPosition,
            duration: 0.5
        )

        let moveIndicator = SKAction.move(
            to: indicatorEndPosition,
            duration: 0.5
        )

        moveCard.timingMode = .easeOut
        moveIndicator.timingMode = .easeOut

        cartao.run(moveCard)
        bolinhaRS.run(moveIndicator) { [weak self] in
            self?.completeInteraction()
        }
    }

    // MARK: - Aproximação das Bolinhas

    private func updatePositions(
        progress: CGFloat
    ) {

        // Depois que a animação final começou,
        // o arrasto não controla mais as bolinhas.
        guard bubblePhase == .approaching else {
            return
        }

        let centerPos = sphereCenter

        var lineIndex = 0

        for item in peopleNodes {

            if !item.isCenter {

                let currentX =
                    item.startPosition.x +
                    (
                        item.targetPosition.x -
                        item.startPosition.x
                    ) * progress

                let currentY =
                    item.startPosition.y +
                    (
                        item.targetPosition.y -
                        item.startPosition.y
                    ) * progress

                item.node.position = CGPoint(
                    x: currentX,
                    y: currentY
                )

                if lineIndex < networkLines.count {

                    let line =
                        networkLines[lineIndex]

                    let path = CGMutablePath()

                    path.move(
                        to: centerPos
                    )

                    path.addLine(
                        to: item.node.position
                    )

                    line.path = path

                    line.alpha = max(
                        0,
                        1.0 - (progress * 1.33)
                    )

                    lineIndex += 1
                }
            }
        }
    }

    // MARK: - Finalização

    private func completeInteraction() {

        guard !hasCompleted else {
            return
        }

        hasCompleted = true
        isDragging = false
        currentProgress = 1

        stopDragHaptics()
        if AppSettings.isAnimationsOn {
            hapticGenerator.impactOccurred()
        }

        // Some com a instrução depois que o pagamento foi feito
        dragHintNode?.run(.fadeOut(withDuration: 0.2))

        // =================================================
        // CARTÃO
        // =================================================
        
       // cartao.position = cardEndPosition

        updateBlurCardPosition()

       //bolinhaRS.position = indicatorEndPosition

        let settleOut = SKAction.scale(
            to: 1.04,
            duration: settleDuration / 2
        )

        settleOut.timingMode = .easeOut

        let settleIn = SKAction.scale(
            to: 1,
            duration: settleDuration / 2
        )

        settleIn.timingMode = .easeIn

        cartao.run(
            .sequence([settleOut, settleIn])
        )

        // =================================================
        // BOLINHAS
        // =================================================

        bubblePhase = .disappearing

        // Garantimos que todas chegaram ao centro.
        for item in peopleNodes {

            item.node.removeAllActions()

            item.node.position =
                sphereCenter
        }

        // As linhas desaparecem
        networkLines.forEach {
            $0.removeAllActions()
            $0.run(
                SKAction.fadeOut(
                    withDuration: 0.08
                )
            )
        }

        // =================================================
        // BOLINHAS SOMEM
        // =================================================

        let disappearGroup = SKAction.group([
            SKAction.fadeOut(
                withDuration: 0.07
            ),
            SKAction.scale(
                to: 0.92,
                duration: 0.07
            )
        ])

        for item in peopleNodes {
            item.node.run(disappearGroup)
        }

        run(
            SKAction.sequence([
                
                // Espera as bolinhas terminarem de desaparecer
                SKAction.wait(
                    forDuration: 0.07
                ),
                
                // Agora o check nasce
                SKAction.run { [weak self] in
                    self?.bubblePhase = .checkAppearing
                    self?.showCheck()
                }
            ]),
            withKey: "showCheck"
        )

        // =================================================
        // CHECK NASCE
        // =================================================

        let checkSequence = SKAction.sequence([

            // Espera as bolinhas desaparecerem
            SKAction.wait(
                forDuration: 0.07
            ),

            SKAction.run { [weak self] in

                guard let self = self else {
                    return
                }

                self.bubblePhase =
                    .checkAppearing

            },

            // A explosão começa junto com o check (o check cresce sozinho em showCheck)

            // =================================================
            // AGORA O CHECK ESTÁ PRONTO
            // =================================================

            SKAction.run { [weak self] in

                guard let self = self else {
                    return
                }

                self.bubblePhase =
                    .behindGlass

                self.showGlassAndPrepareExplosion()

                // As bolinhas começam a nascer
                // exatamente quando o glass aparece.
                self.startExplosion()
            }
        ])

        run(
            checkSequence,
            withKey: "closeAccountAnimation"
        )
    }

    // MARK: - Troca Bola → Glass

    private func showGlassAndPrepareExplosion() {

        let hideBackgroundBall =
            SKAction.fadeOut(
                withDuration: 0.10
            )

        let showGlass =
            SKAction.fadeIn(
                withDuration: 0.06
            )

        backgroundBallNode.run(
            hideBackgroundBall
        )

        glassGroupNode.run(
            showGlass
        )

        // As bolinhas precisam estar atrás do glass.
        for item in peopleNodes {

            if item.isCenter {
                continue
            }

            item.node.zPosition = 6

            // Elas continuam invisíveis neste momento.
            item.node.alpha = 0

            item.node.setScale(1.0)

            item.node.position =
                sphereCenter
        }

        // O emoji central não volta.
        if let centerItem =
            peopleNodes.first(where: {
                $0.isCenter
            }) {

            centerItem.node.alpha = 0
        }

        // O check permanece na frente.
        checkNode.zPosition = 20

    }

    // MARK: - Explosão

    /// Configuração de cada bolinha da explosão — medida a partir do protótipo.
    /// `target` é relativo ao centro da esfera (x para a direita, y para cima).
    /// As que terminam fora do vidro ficam nítidas; as que terminam
    /// dentro aparecem só através do vidro (camada de lente).
    private struct ExplosionDotSpec {
        let color: UIColor
        let radius: CGFloat
        let target: CGPoint
        let alpha: CGFloat
        let stretch: CGFloat   // alongamento na direção do centro → borda
        let delay: TimeInterval
    }

    private var explosionSpecs: [ExplosionDotSpec] {

        // Cores exatas do protótipo
        let red = UIColor(red: 252 / 255, green: 41 / 255, blue: 76 / 255, alpha: 1)       // #FC294C
        let cyan = UIColor(red: 0 / 255, green: 195 / 255, blue: 243 / 255, alpha: 1)      // #00C3F3
        let green = UIColor(red: 40 / 255, green: 174 / 255, blue: 39 / 255, alpha: 1)     // #28AE27
        let orange = UIColor(red: 255 / 255, green: 137 / 255, blue: 8 / 255, alpha: 1)    // #FF8908
        let purple = UIColor(red: 173 / 255, green: 65 / 255, blue: 210 / 255, alpha: 1)   // #AD41D2
        let yellow = UIColor(red: 255 / 255, green: 189 / 255, blue: 0 / 255, alpha: 1)    // #FFBD00
        let smallGreen = UIColor(red: 80 / 255, green: 172 / 255, blue: 40 / 255, alpha: 1)
        let lightBlue = UIColor(red: 50 / 255, green: 190 / 255, blue: 238 / 255, alpha: 1)

        func spec(
            _ color: UIColor,
            _ radius: CGFloat,
            _ x: CGFloat,
            _ y: CGFloat,
            alpha: CGFloat = 1,
            stretch: CGFloat = 1,
            delay: TimeInterval = 0
        ) -> ExplosionDotSpec {
            ExplosionDotSpec(
                color: color,
                radius: radius,
                target: CGPoint(x: x, y: y),
                alpha: alpha,
                stretch: stretch,
                delay: delay
            )
        }

        // A ordem importa: quem vem depois fica por cima.
        return [
            // ---- Fora do vidro (nítidas) ----
            spec(red, 15, -89, 213),
            spec(cyan, 15, -98, 176, delay: 0.01),
            spec(green, 15, -114.5, 185.5, alpha: 0.85, delay: 0.02),   // por cima do azul
            spec(cyan, 15, 37, 201),
            spec(orange, 15, 100.5, 180.5, delay: 0.01),
            spec(green, 15, 114.5, 164.5, delay: 0.02),                 // por cima do laranja
            spec(orange, 15, -111, 118, delay: 0.01),
            spec(purple, 15, -135, 90.5, delay: 0.02),
            spec(cyan, 15, -141.5, -69, delay: 0.01),

            // ---- Dentro do vidro (vistas através dele) ----
            spec(red, 16.5, -12, 129),
            spec(red, 16.5, -9.5, 99, delay: 0.01),
            spec(yellow, 15.5, 50, 106, stretch: 1.12, delay: 0.01),
            spec(orange, 12, 107, -45, delay: 0.02),
            spec(purple, 17.5, 88, -76.5, delay: 0.01),
            spec(orange, 13.5, -78, -88, delay: 0.02),
            spec(smallGreen, 5.5, -59.5, -99.5, delay: 0.02),
            spec(lightBlue, 4, -92.5, 70.5, delay: 0.01)
        ]
    }

    private func startExplosion() {

        bubblePhase = .exploding

        clearExplosionDots()

        // Explosão rápida: as bolinhas saem do centro, passam pelas
        // posições do protótipo e continuam até sair da tela.
        let flightDuration: TimeInterval = 0.5

        // Distância suficiente para qualquer bolinha sair da tela
        let exitDistance = sqrt(size.width * size.width + size.height * size.height)

        // Pequena variação de velocidade para não sair tudo junto
        let speedVariation: [CGFloat] = [1.00, 1.15, 0.95, 1.10, 1.05, 0.90, 1.20, 1.00, 1.10]

        var longestFlight: TimeInterval = 0

        for (index, spec) in explosionSpecs.enumerated() {

            // Bolinha nítida: fica atrás do vidro (opaco),
            // então só aparece quando sai dele.
            let dot = SKShapeNode(circleOfRadius: spec.radius)
            dot.fillColor = spec.color
            dot.strokeColor = .clear
            dot.position = sphereCenter
            dot.zPosition = 6
            dot.alpha = 0
            dot.setScale(0.5)
            addChild(dot)

            // Cópia vista através do vidro (leve desfoque + franja de cor)
            let copy = makeLensCopy(color: spec.color, radius: spec.radius)
            copy.alpha = 0
            lensEffectNode.addChild(copy)

            explosionDots.append(
                ExplosionDot(node: dot, lensCopy: copy, stretch: spec.stretch)
            )

            // Direção: a mesma da posição do protótipo
            let length = max(
                sqrt(spec.target.x * spec.target.x + spec.target.y * spec.target.y),
                1
            )
            let directionX = spec.target.x / length
            let directionY = spec.target.y / length

            let distance = exitDistance * speedVariation[index % speedVariation.count]

            let exitPoint = CGPoint(
                x: sphereCenter.x + directionX * distance,
                y: sphereCenter.y + directionY * distance
            )

            let move = SKAction.move(to: exitPoint, duration: flightDuration)
            move.timingMode = .easeIn

            let grow = SKAction.scale(to: 1.0, duration: 0.12)
            grow.timingMode = .easeOut

            dot.run(
                .sequence([
                    .wait(forDuration: spec.delay),
                    .group([
                        .fadeAlpha(to: spec.alpha, duration: 0.03),
                        move,
                        grow
                    ]),
                    // Saiu da tela: acabou para esta bolinha
                    .hide()
                ])
            )

            longestFlight = max(longestFlight, spec.delay + flightDuration)
        }

        // A explosão acaba quando todas saíram da tela
        run(
            .sequence([
                .wait(forDuration: longestFlight + 0.05),
                .run { [weak self] in
                    self?.clearExplosionDots()
                    // Do dev: salva a conta no histórico e volta ao início.
                    self?.onPaymentCompleted?()
                }
            ]),
            withKey: "explosionEnd"
        )
    }

    /// Bolinha como é vista através do vidro:
    /// núcleo colorido + franjas magenta/amarela para o lado de fora.
    private func makeLensCopy(color: UIColor, radius: CGFloat) -> SKNode {

        let container = SKNode()

        // Franjas deslocadas para fora (eixo x local aponta para a borda):
        // magenta fininha e amarela por fora, como no protótipo.
        let yellowFringe = SKShapeNode(circleOfRadius: radius)
        yellowFringe.fillColor = UIColor(red: 1.0, green: 0.92, blue: 0.25, alpha: 0.9)
        yellowFringe.strokeColor = .clear
        yellowFringe.position = CGPoint(x: 3.5, y: 0)
        container.addChild(yellowFringe)

        let magentaFringe = SKShapeNode(circleOfRadius: radius)
        magentaFringe.fillColor = UIColor(red: 1.0, green: 0.25, blue: 0.85, alpha: 0.5)
        magentaFringe.strokeColor = .clear
        magentaFringe.position = CGPoint(x: 1.3, y: 0)
        container.addChild(magentaFringe)

        let core = SKShapeNode(circleOfRadius: radius)
        core.fillColor = color
        core.strokeColor = .clear
        container.addChild(core)

        return container
    }

    /// Mantém as cópias da lente exatamente sobre as bolinhas reais.
    private func updateLensCopies() {

        for dot in explosionDots {

            let dx = dot.node.position.x - sphereCenter.x
            let dy = dot.node.position.y - sphereCenter.y
            let distance = sqrt(dx * dx + dy * dy)

            dot.lensCopy.position = CGPoint(x: dx, y: dy)

            // Eixo x local aponta do centro para a borda
            dot.lensCopy.zRotation = distance > 0.5 ? atan2(dy, dx) : 0

            dot.lensCopy.xScale = dot.node.xScale * dot.stretch
            dot.lensCopy.yScale = dot.node.yScale
            dot.lensCopy.alpha = dot.node.alpha > 0 ? 1 : 0
        }
    }

    private func clearExplosionDots() {

        for dot in explosionDots {
            dot.node.removeAllActions()
            dot.node.removeFromParent()
            dot.lensCopy.removeFromParent()
        }

        explosionDots.removeAll()
    }

    // MARK: - Reset

    private func resetInteraction() {

        hasCompleted = false
        isDragging = false
        currentProgress = 0
        touchOffsetX = 0
        stopDragHaptics()

        bubblePhase = .approaching

        // Cancela a animação final
        removeAction(
            forKey: "closeAccountAnimation"
        )

        removeAction(forKey: "explosionEnd")

        // =================================================
        // CARTÃO
        // =================================================

        cartao.removeAllActions()
        bolinhaRS.removeAllActions()

        let cardReset =
            SKAction.move(
                to: cardStartPosition,
                duration: resetDuration
            )

        cardReset.timingMode = .easeOut

        cartao.run(cardReset)

        let indicatorReset =
            SKAction.move(
                to: indicatorStartPosition,
                duration: resetDuration
            )

        indicatorReset.timingMode = .easeOut

        bolinhaRS.run(
            indicatorReset
        )

        if let cropNode =
            cartaoBlur.parent?.parent as? SKCropNode,

           let effectNode =
            cartaoBlur.parent as? SKEffectNode {

            cropNode.position =
                machineCenter()

            let blurReset =
                SKAction.move(
                    to: CGPoint(
                        x:
                            cardStartPosition.x -
                            machineCenter().x,

                        y:
                            cardStartPosition.y -
                            machineCenter().y
                    ),
                    duration: resetDuration
                )

            blurReset.timingMode =
                .easeOut

            effectNode.run(
                blurReset
            )
        }

        // =================================================
        // CHECK
        // =================================================

        checkNode.removeAllActions()

        checkNode.alpha = 0

        checkNode.setScale(
            0.1
        )

        checkNode.position =
            sphereCenter

        // =================================================
        // BOLA.PNG
        // =================================================

        backgroundBallNode.removeAllActions()

        backgroundBallNode.alpha = 1

        backgroundBallNode.position =
            sphereCenter

        // =================================================
        // GLASS
        // =================================================

        glassGroupNode.removeAllActions()

        glassGroupNode.alpha = 0

        glassGroupNode.position =
            sphereCenter

        glassReflectionNode.alpha = 0.55

        // =================================================
        // BOLINHAS
        // =================================================

        for item in peopleNodes {

            item.node.removeAllActions()
            item.emoji.removeAllActions()

            item.node.position =
                item.startPosition

            item.node.alpha = 1.0

            item.node.setScale(
                1.0
            )

            item.node.zPosition =
                item.isCenter ? 7 : 6

            item.emoji.alpha = 1.0
        }

        clearExplosionDots()

        // =================================================
        // LINHAS
        // =================================================

        for line in networkLines {

            line.removeAllActions()

            line.alpha = 1
        }

        updatePositions(
            progress: 0
        )
    }
}

#if DEBUG
import SwiftUI

struct CloseAccountScenePreview: View {
    var body: some View {
        SpriteView(scene: makeScene())
            .ignoresSafeArea()
    }

    private func makeScene() -> CloseAccountScene {
        let scene = CloseAccountScene(
            size: CGSize(width: 390, height: 844)
        )

        scene.scaleMode = .aspectFill

        return scene
    }
}

#Preview {
    CloseAccountScenePreview()
}
#endif
