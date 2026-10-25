//
//  CardsScene.swift
//  POCMoveCards
//
//  Created by Camila Parolin on 19/08/26.
//

import SpriteKit
import SwiftUI

class CardsScene: SKScene {
    
    // MARK: - ViewModels / Dados
    
    var cardsVm: ScatteredCardsViewModel?
    var billVm: BillViewModel?
    var userTotals: [UUID: Double] = [:]
    var topBoundaryScreenY: CGFloat = 100
    
    /// Toque simples num card. Envia também o centro da bolinha (avatar)
    /// em coordenadas da view, para o card em destaque sair desse ponto.
    var onTapUser: ((UUID, CGPoint) -> Void)?
    
    // MARK: - Drag
    
    private var draggingNode: SKNode?
    private let dropZoneRadius: CGFloat = 135
    private var initialNodePosition: CGPoint = .zero
    private var lastTouchLocation: CGPoint = .zero
    private var lastTouchTime: TimeInterval = 0
    private var dragVelocity: CGVector = .zero
    
    /// Enquanto os cards voam para o círculo (botão "Concluir pagamento"),
    /// os toques ficam bloqueados.
    private var isPayingAll = false

    private var touchStartLocation: CGPoint = .zero
    private var didMoveDuringTouch = false

    // Distância entre o dedo e o centro do card no início do toque.
    // Mantém o card preso ao dedo no ponto onde foi tocado (sem "pulo").
    private var dragTouchOffset: CGVector = .zero

    /// Card que está embaixo do card arrastado (vai receber o card se
    /// o dedo for solto agora). Fica levemente ampliado como feedback.
    private var mergeCandidate: SKNode?

    // MARK: - Spawn control

    private var didSpawnCards = false
    private var spawnWaitStartTime: TimeInterval?
    
    // MARK: - Physics Categories
    
    private let cardCategory: UInt32 = 1 << 0
    private let barrierCategory: UInt32 = 1 << 1

    
    // MARK: - Scene
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .clear

        // Deixa a TotalView marcar pagamentos pelo VoiceOver.
        cardsVm?.markUserAsPaid = { [weak self] userID in
            self?.accessibilityMarkAsPaid(userID: userID)
        }

        // Deixa a TotalView esconder o card enquanto ele está em destaque.
        cardsVm?.setCardHidden = { [weak self] userID, hidden in
            self?.setCardHidden(userID: userID, hidden: hidden)
        }

        // Deixa a sheet de consumo juntar/separar cards sem arrasto
        // (VoiceOver, Controle Assistivo ou quem preferir o botão).
        cardsVm?.mergeCards = { [weak self] userID, payerID in
            self?.mergeCards(userID: userID, into: payerID)
        }
        cardsVm?.splitCard = { [weak self] userID in
            self?.splitCard(userID: userID)
        }

        // Deixa o botão "Concluir pagamento" da TotalView pagar todos.
        cardsVm?.payAllUsers = { [weak self] animated in
            self?.payAllUsers(animated: animated)
        }
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = barrierCategory
        
        // MARK: - Barreira superior
        
        let topBarrier = SKNode()
        let topHeight = topBoundaryScreenY   // era: let topHeight: CGFloat = 100
        
        topBarrier.position = CGPoint(x: self.size.width / 2, y: self.size.height - (topHeight / 2))
        topBarrier.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: topHeight))
        topBarrier.physicsBody?.isDynamic = false
        topBarrier.physicsBody?.categoryBitMask = barrierCategory
        topBarrier.physicsBody?.collisionBitMask = cardCategory
        self.addChild(topBarrier)
        
        // MARK: - Barreira inferior
        
        let circleRadius: CGFloat = 135
        let bottomBarrier = SKNode()
        
        bottomBarrier.position = CGPoint(x: self.size.width / 2, y: circleRadius)
        bottomBarrier.physicsBody = SKPhysicsBody(circleOfRadius: circleRadius + 15)
        bottomBarrier.physicsBody?.isDynamic = false
        bottomBarrier.physicsBody?.categoryBitMask = barrierCategory
        bottomBarrier.physicsBody?.collisionBitMask = cardCategory
        self.addChild(bottomBarrier)
        
        // MARK: - Cards
        // Os cards nascem no update(_:), assim que a cena estiver
        // na janela (ver spawnCardsWhenReady).
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        spawnCardsWhenReady(currentTime)
    }

    /// Espera a cena estar na janela (para ler a área segura real)
    /// antes de criar os cards, para eles não nascerem sobre o "Total a pagar".
    /// Se demorar mais de 0,5 s, cria mesmo assim com o limite padrão.
    private func spawnCardsWhenReady(_ currentTime: TimeInterval) {
        guard !didSpawnCards else { return }

        if spawnWaitStartTime == nil {
            spawnWaitStartTime = currentTime
        }

        let isInWindow = view?.window != nil
        let waitedTooLong = currentTime - (spawnWaitStartTime ?? currentTime) > 0.5

        guard isInWindow || waitedTooLong else { return }

        didSpawnCards = true
        spawnCards()
    }
    
    // MARK: - Card Metrics

    /// Dimensões visuais do card.
    /// `.regular` = tamanho atual. `.compact` = versão menor (8+ usuários).
    private struct CardMetrics {
        let isCompact: Bool

        let avatarRadius: CGFloat
        let avatarCenter: CGPoint
        let emojiFontSize: CGFloat

        let bgSize: CGSize
        let bgCenter: CGPoint
        let bgCornerRadius: CGFloat
        let bgColor: UIColor
        let bgStrokeColor: UIColor

        let nameFont: UIFont
        let nameColor: UIColor
        let namePosition: CGPoint   // relativo ao retângulo branco

        let valueFont: UIFont
        let valueColor: UIColor
        let valuePosition: CGPoint  // relativo ao retângulo branco

        /// Retângulo branco em coordenadas do card.
        var bgRect: CGRect {
            CGRect(
                x: bgCenter.x - bgSize.width / 2,
                y: bgCenter.y - bgSize.height / 2,
                width: bgSize.width,
                height: bgSize.height
            )
        }

        /// Retângulo que envolve a bolinha, em coordenadas do card.
        var avatarRect: CGRect {
            CGRect(
                x: avatarCenter.x - avatarRadius,
                y: avatarCenter.y - avatarRadius,
                width: avatarRadius * 2,
                height: avatarRadius * 2
            )
        }

        /// Caixa que envolve o card inteiro (bolinha + retângulo).
        var bounds: CGRect {
            bgRect.union(avatarRect)
        }

        static let regular = CardMetrics(
            isCompact: false,
            avatarRadius: 35,
            avatarCenter: CGPoint(x: -45, y: 8),
            emojiFontSize: 43,
            bgSize: CGSize(width: 120, height: 50),
            bgCenter: CGPoint(x: 16, y: 5),
            bgCornerRadius: 18,
            bgColor: UIColor.systemBackground,
            bgStrokeColor: UIColor.black.withAlphaComponent(0.05),
            nameFont: UIFont.systemFont(ofSize: 12, weight: .regular),
            nameColor: UIColor.secondaryLabel,
            namePosition: CGPoint(x: -18, y: 7),   // mesmo x do valor
            valueFont: UIFont.systemFont(ofSize: 16, weight: .medium),
            valueColor: UIColor.darkGray,
            valuePosition: CGPoint(x: -18, y: -15)
        )

        static let compact = CardMetrics(
            isCompact: true,
            avatarRadius: 54.6781 / 2,
            avatarCenter: CGPoint(x: -36, y: 6),
            emojiFontSize: 35.62888,
            bgSize: CGSize(width: 101.09669, height: 35.4095),
            // Borda esquerda do retângulo começa logo após o centro da bolinha
            bgCenter: CGPoint(x: -35 + 101.09669 / 2, y: 4),
            bgCornerRadius: 12.31635,
            bgColor: UIColor.white,
            bgStrokeColor: .clear,
            nameFont: UIFont.systemFont(ofSize: 7.69772, weight: .thin),
            nameColor: UIColor(red: 0.44, green: 0.44, blue: 0.44, alpha: 1),
            namePosition: CGPoint(x: -14, y: 5),   // mesmo x do valor
            valueFont: UIFont.systemFont(ofSize: 12.31635, weight: .medium),
            valueColor: UIColor(red: 0.46, green: 0.46, blue: 0.46, alpha: 1),
            valuePosition: CGPoint(x: -14, y: -11)
        )
    }

    /// A partir desta quantidade de usuários, os cards ficam menores.
    private let compactCardThreshold = 8

    /// Definido em `spawnCards()` com base apenas em `users.count`.
    private var cardMetrics: CardMetrics = .regular

    // MARK: - Limites da tela (Regra 2)

    /// Distância do topo da tela até onde os cards podem chegar.
    /// O "Total a pagar" fica na barra de navegação (mesma altura do botão voltar),
    /// então o limite é o fim dessa barra: área segura do topo + 44 pt da barra.
    private var topLimitFromScreenTop: CGFloat {
        guard let view else {
            return topBoundaryScreenY
        }

        let safeTop = view.window?.safeAreaInsets.top ?? view.safeAreaInsets.top
        let navigationBarHeight: CGFloat = 44
        let margin: CGFloat = 8

        return safeTop + navigationBarHeight + margin
    }

    /// Limita a posição para que o card INTEIRO
    /// (bolinha + retângulo + nome + valor) fique dentro da área permitida.
    /// Quando o card é informado, inclui também o texto que passa
    /// para fora do retângulo branco (nomes/valores longos).
    private func clampedCardPosition(_ position: CGPoint, for card: SKNode? = nil) -> CGPoint {
        var bounds = card.map(cardBounds(of:)) ?? cardMetrics.bounds

        if let card, let text = textRect(of: card) {
            bounds = bounds.union(text)
        }

        let minX = -bounds.minX
        let maxX = max(minX, self.size.width - bounds.maxX)

        let minY = -bounds.minY
        let maxY = max(minY, self.size.height - topLimitFromScreenTop - bounds.maxY)

        return CGPoint(
            x: min(max(position.x, minX), maxX),
            y: min(max(position.y, minY), maxY)
        )
    }

    // MARK: - Spawn Cards

    private func spawnCards() {
        guard let billVm else {
            return
        }

        var initialSum: Double = 0.0
        let allUsers = billVm.bill.users

        // Tamanho do card depende SOMENTE da quantidade de usuários.
        cardMetrics = allUsers.count >= compactCardThreshold ? .compact : .regular

        // Quem é coberto por outra pessoa (cards juntados) não tem card
        // próprio: o valor dele já está somado no card de quem paga.
        let users = allUsers.filter { !(cardsVm?.groups.isCovered($0.id) ?? false) }
        let metrics = cardMetrics
        let cardBounds = metrics.bounds

        // Faixa onde os cards podem nascer (mesma faixa de antes:
        // acima da área de pagamento e abaixo do header),
        // considerando o tamanho REAL do card.
        let spawnBottomEdge: CGFloat = 346
        let spawnTopEdge = self.size.height - topLimitFromScreenTop

        let minX = -cardBounds.minX
        let maxX = max(minX, self.size.width - cardBounds.maxX)

        let minY = spawnBottomEdge - cardBounds.minY
        let maxY = max(minY, spawnTopEdge - cardBounds.maxY)

        // MARK: Regra 1 — nenhum card nasce sobre outro card
        // Considera a bolinha E o retângulo branco (com nome e valor).
        let spacing: CGFloat = 6
        let samplesPerCard = 200
        let freeCandidatesPerCard = 10
        let maxLayoutAttempts = 8
        let maxRelaxIterations = 400

        func clampToSpawnArea(_ p: CGPoint) -> CGPoint {
            CGPoint(
                x: min(max(p.x, minX), maxX),
                y: min(max(p.y, minY), maxY)
            )
        }

        func randomPoint() -> CGPoint {
            CGPoint(
                x: CGFloat.random(in: minX...maxX),
                y: CGFloat.random(in: minY...maxY)
            )
        }

        func circleRectPenetration(
            circleCenter: CGPoint,
            radius: CGFloat,
            rect: CGRect
        ) -> CGFloat {
            let closestX = max(rect.minX, min(circleCenter.x, rect.maxX))
            let closestY = max(rect.minY, min(circleCenter.y, rect.maxY))
            let distance = hypot(circleCenter.x - closestX, circleCenter.y - closestY)
            return max(0, radius + spacing - distance)
        }

        /// Quanto o card na posição `a` invade o card na posição `b`.
        /// 0 = não se tocam (respeitando o espaçamento).
        func overlap(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
            let avatarA = CGPoint(x: a.x + metrics.avatarCenter.x, y: a.y + metrics.avatarCenter.y)
            let avatarB = CGPoint(x: b.x + metrics.avatarCenter.x, y: b.y + metrics.avatarCenter.y)
            let rectA = metrics.bgRect.offsetBy(dx: a.x, dy: a.y)
            let rectB = metrics.bgRect.offsetBy(dx: b.x, dy: b.y)
            let r = metrics.avatarRadius

            // Bolinha x bolinha
            let circles = max(0, r * 2 + spacing - hypot(avatarA.x - avatarB.x, avatarA.y - avatarB.y))

            // Bolinha x retângulo
            let circleARectB = circleRectPenetration(circleCenter: avatarA, radius: r, rect: rectB)
            let circleBRectA = circleRectPenetration(circleCenter: avatarB, radius: r, rect: rectA)

            // Retângulo x retângulo
            let expandedA = rectA.insetBy(dx: -spacing / 2, dy: -spacing / 2)
            let expandedB = rectB.insetBy(dx: -spacing / 2, dy: -spacing / 2)
            let overlapX = min(expandedA.maxX, expandedB.maxX) - max(expandedA.minX, expandedB.minX)
            let overlapY = min(expandedA.maxY, expandedB.maxY) - max(expandedA.minY, expandedB.minY)
            let rects = (overlapX > 0 && overlapY > 0) ? min(overlapX, overlapY) : 0

            return circles + circleARectB + circleBRectA + rects
        }

        func totalOverlap(_ layout: [CGPoint]) -> CGFloat {
            var total: CGFloat = 0
            for i in layout.indices {
                for j in layout.indices where j > i {
                    total += overlap(layout[i], layout[j])
                }
            }
            return total
        }

        /// Passo 1: sorteia uma posição aleatória por card,
        /// descartando as que encostam em cards já posicionados.
        func randomLayout() -> [CGPoint] {
            var layout: [CGPoint] = []

            for _ in users {
                var best = randomPoint()
                var bestOverlap = CGFloat.greatestFiniteMagnitude

                // Distribuição (item 9): em vez de ficar com a PRIMEIRA posição livre,
                // sorteia várias posições livres e escolhe a mais afastada dos
                // cards já colocados. Continua aleatório, mas espalha melhor
                // pela área e evita "buracos" e aglomerados.
                var bestFree: CGPoint?
                var bestFreeSpread: CGFloat = -1
                var freeCandidatesFound = 0

                for _ in 0..<samplesPerCard {
                    let candidate = randomPoint()
                    let conflict = layout.reduce(0) { $0 + overlap(candidate, $1) }

                    if conflict == 0 {
                        // Menor distância até os outros cards
                        // (vertical pesa mais, porque os cards são largos).
                        let spread = layout
                            .map { hypot(candidate.x - $0.x, (candidate.y - $0.y) * 2) }
                            .min() ?? .greatestFiniteMagnitude

                        if spread > bestFreeSpread {
                            bestFreeSpread = spread
                            bestFree = candidate
                        }

                        freeCandidatesFound += 1
                        if freeCandidatesFound >= freeCandidatesPerCard {
                            break
                        }
                    } else if conflict < bestOverlap {
                        best = candidate
                        bestOverlap = conflict
                    }
                }

                layout.append(bestFree ?? best)
            }

            return layout
        }

        /// Passo 2: com muitos cards o sorteio sozinho não encontra espaço.
        /// Então afastamos levemente os cards que ainda se tocam,
        /// mantendo a distribuição aleatória, até ninguém encostar em ninguém.
        func relax(_ layout: inout [CGPoint]) {
            guard layout.count > 1 else { return }

            for _ in 0..<maxRelaxIterations {
                var moved = false

                for i in 0..<(layout.count - 1) {
                    for j in (i + 1)..<layout.count {
                        let conflict = overlap(layout[i], layout[j])
                        guard conflict > 0 else { continue }

                        moved = true

                        // Cards são largos: separa mais na vertical.
                        var dx = layout[i].x - layout[j].x
                        var dy = (layout[i].y - layout[j].y) * 2
                        var distance = hypot(dx, dy)

                        if distance < 0.001 {
                            let angle = CGFloat.random(in: 0..<(2 * .pi))
                            dx = cos(angle)
                            dy = sin(angle)
                            distance = 1
                        }

                        let step = min(conflict, 20) / 2 + 0.5

                        layout[i].x += dx / distance * step
                        layout[i].y += dy / distance * step
                        layout[j].x -= dx / distance * step
                        layout[j].y -= dy / distance * step
                    }
                }

                for k in layout.indices {
                    layout[k] = clampToSpawnArea(layout[k])
                }

                if !moved {
                    return
                }
            }
        }

        // Tenta alguns layouts e fica com o primeiro sem nenhuma sobreposição
        // (ou, se não existir espaço, com o de menor sobreposição).
        var spawnPositions: [CGPoint] = []
        var bestLayoutOverlap = CGFloat.greatestFiniteMagnitude

        for _ in 0..<maxLayoutAttempts {
            var layout = randomLayout()
            relax(&layout)

            let conflict = totalOverlap(layout)

            if conflict < bestLayoutOverlap {
                bestLayoutOverlap = conflict
                spawnPositions = layout
            }

            if conflict == 0 {
                break
            }
        }

        for (index, user) in users.enumerated() {
            let value = groupValue(for: user.id)
            initialSum += value

            let card = createCardNode(
                value: value,
                user: user
            )

            card.position = spawnPositions[index]
            self.addChild(card)
            updateGroupAvatar(on: card)

        }

        // Nomes/valores longos podem passar do retângulo branco.
        // Agora que os textos existem, garante (sem animação) que eles
        // não saem da tela nem ficam sob outro card.
        separateCardsAfterDrop(animated: false)

        // Cards aparecem já deslizando um pouquinho a partir da SUA posição aleatória.
        startEntryDrift()

        DispatchQueue.main.async { [weak self] in
            self?.cardsVm?.targetAmount = initialSum
        }
    }

    
    // MARK: - Create Card
    
    private func createCardNode(value: Double, user: User) -> SKNode {
        let metrics = cardMetrics

        let cardContainer = SKNode()
        cardContainer.name = "card_\(user.id.uuidString)"
        cardContainer.zPosition = 1
        cardContainer.userData = [
            "value": value,
            "userID": user.id.uuidString
        ]
        
        // MARK: Background
        let bgNode = SKShapeNode(rectOf: metrics.bgSize, cornerRadius: metrics.bgCornerRadius)
        bgNode.fillColor = metrics.bgColor
        bgNode.strokeColor = metrics.bgStrokeColor
        bgNode.lineWidth = 1
        bgNode.position = metrics.bgCenter
        bgNode.name = "cardBackground"
        
        // MARK: Shadow
        let effectNode = SKEffectNode()
        effectNode.name = "cardShadow"
        effectNode.shouldEnableEffects = true
        // Guarda a sombra desfocada em cache: sem isso o blur é recalculado
        // a cada frame enquanto o card se move, e a animação perde fluidez.
        effectNode.shouldRasterize = true
        effectNode.zPosition = -1

        if metrics.isCompact {
            // Sombras curtas do card compacto
            let filter = CIFilter(name: "CIGaussianBlur")
            filter?.setValue(1.02636, forKey: kCIInputRadiusKey)
            effectNode.filter = filter

            let bottomShadow = SKShapeNode(rectOf: metrics.bgSize, cornerRadius: metrics.bgCornerRadius)
            bottomShadow.fillColor = UIColor.black.withAlphaComponent(0.2)
            bottomShadow.strokeColor = .clear
            bottomShadow.position = CGPoint(x: 0, y: -1.02636)
            effectNode.addChild(bottomShadow)

            let topShadow = SKShapeNode(rectOf: metrics.bgSize, cornerRadius: metrics.bgCornerRadius)
            topShadow.fillColor = UIColor(red: 0.43, green: 0.43, blue: 0.43, alpha: 0.1)
            topShadow.strokeColor = .clear
            topShadow.position = CGPoint(x: 0, y: 0.51318)
            effectNode.addChild(topShadow)

            effectNode.position = metrics.bgCenter
        } else {
            let filter = CIFilter(name: "CIGaussianBlur")
            filter?.setValue(4.0, forKey: kCIInputRadiusKey)
            effectNode.filter = filter

            let shadowNode = SKShapeNode(rectOf: CGSize(width: 115, height: 30), cornerRadius: 18)
            shadowNode.fillColor = UIColor.black.withAlphaComponent(0.12)
            shadowNode.strokeColor = .clear
            effectNode.addChild(shadowNode)
            effectNode.position = CGPoint(x: 16, y: -8)
        }

        cardContainer.addChild(effectNode)
        cardContainer.addChild(bgNode)
        
        // MARK: - Circle
        let circle = SKShapeNode(circleOfRadius: metrics.avatarRadius)
        circle.name = "avatarBackground"
        circle.fillColor = UIColor(user.color)
        circle.strokeColor = .clear
        circle.position = metrics.avatarCenter
        circle.zPosition = 1
        cardContainer.addChild(circle)
        
        // MARK: - Emoji
        let emoji = SKLabelNode(text: user.emoji)
        emoji.name = "emoji"
        emoji.fontSize = metrics.emojiFontSize
        emoji.verticalAlignmentMode = .center
        emoji.horizontalAlignmentMode = .center
        emoji.position = metrics.avatarCenter
        emoji.zPosition = 2
        cardContainer.addChild(emoji)
        
        // MARK: - Currency
        let formattedValue = CurrencyHelper.formatWithSymbol(value)
        
        // MARK: - User Name
        let nameLabel = SKLabelNode()
        // Espaço livre entre o início do texto e a borda direita do card.
        let nameMaxWidth = metrics.bgSize.width / 2 - metrics.namePosition.x - 8
        nameLabel.attributedText = NSAttributedString(
            string: fittedName(user.name, font: metrics.nameFont, maxWidth: nameMaxWidth),
            attributes: [
                .font: metrics.nameFont,
                .foregroundColor: metrics.nameColor
            ]
        )
        nameLabel.name = "nameLabel"
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.position = metrics.namePosition
        nameLabel.zPosition = 2
        bgNode.addChild(nameLabel)
        
        // MARK: - Value
        let valueLabel = SKLabelNode()
        valueLabel.attributedText = NSAttributedString(
            string: formattedValue,
            attributes: [
                .font: metrics.valueFont,
                .foregroundColor: metrics.valueColor
            ]
        )
        valueLabel.name = "valueLabel"
        valueLabel.horizontalAlignmentMode = .left
        valueLabel.position = metrics.valuePosition
        valueLabel.zPosition = 2
        bgNode.addChild(valueLabel)
        
        // MARK: - Physics
        // O retângulo branco não possui colisão.
        // A colisão entre usuários é controlada somente pela bolinha/avatar.
        cardContainer.physicsBody = nil

        return cardContainer
    }
    
    /// Encurta o nome com "…" quando ele não cabe no card
    /// (ex.: nomes antigos com mais de 8 caracteres ou letras largas como "W").
    private func fittedName(_ name: String, font: UIFont, maxWidth: CGFloat) -> String {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        guard (name as NSString).size(withAttributes: attributes).width > maxWidth else {
            return name
        }
        var trimmed = name
        while !trimmed.isEmpty,
              ((trimmed + "…") as NSString).size(withAttributes: attributes).width > maxWidth {
            trimmed.removeLast()
        }
        return trimmed.trimmingCharacters(in: .whitespaces) + "…"
    }

    // MARK: - Touch Began

    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        guard !isPayingAll, let touch = touches.first else { return }

        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        if let card = touchedNodes.first(where: {
            $0.name?.starts(with: "card_") == true
        }) {
            draggingNode = card

            // Guarda onde o toque começou
            touchStartLocation = location
            didMoveDuringTouch = false

            initialNodePosition = card.position
            dragTouchOffset = CGVector(
                dx: card.position.x - location.x,
                dy: card.position.y - location.y
            )
            card.zPosition = 100

            // Se o card ainda estava sendo afastado, para a animação
            // para ele seguir o dedo.
            card.removeAction(forKey: separationActionKey)

            lastTouchLocation = location
            lastTouchTime = event?.timestamp ?? 0
            dragVelocity = .zero

            let scaleDown = SKAction.scale(
                to: 0.95,
                duration: 0.1
            )

            card.run(scaleDown)
        }
    }


    // MARK: - Touch Moved

    override func touchesMoved(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        guard let touch = touches.first,
              let node = draggingNode else {
            return
        }

        let location = touch.location(in: self)

        // Verifica se realmente houve arraste
        let movement = hypot(
            location.x - touchStartLocation.x,
            location.y - touchStartLocation.y
        )

        if movement > 5 {
            didMoveDuringTouch = true
        }

        // Limites considerando o card inteiro (Regra 2).
        // O card inteiro (container) segue o dedo mantendo o ponto tocado.
        // Regra 4: sem colisão/empurrão durante o arraste.
        // O card arrastado passa livremente sobre os outros,
        // e os outros ficam exatamente onde estão.
        let proposedPosition = clampedCardPosition(
            CGPoint(
                x: location.x + dragTouchOffset.dx,
                y: location.y + dragTouchOffset.dy
            ),
            for: node
        )

        let clampedX = proposedPosition.x
        let clampedY = proposedPosition.y

        node.position = proposedPosition

        // Passou por cima de outro card? Destaca quem vai receber.
        if didMoveDuringTouch {
            updateMergeCandidate(for: node)
        }

        // MARK: Velocity

        let currentTime = event?.timestamp ?? 0

        let timeSinceLastTouch =
            currentTime - lastTouchTime

        if timeSinceLastTouch > 0 {

            let velocityX =
                (clampedX - lastTouchLocation.x)
                / CGFloat(timeSinceLastTouch)

            let velocityY =
                (clampedY - lastTouchLocation.y)
                / CGFloat(timeSinceLastTouch)

            dragVelocity = CGVector(
                dx: velocityX,
                dy: velocityY
            )
        }

        lastTouchLocation = CGPoint(
            x: clampedX,
            y: clampedY
        )

        lastTouchTime = currentTime

    }

    // MARK: - Separação dos cards após soltar

    private let dropSeparationSpacing: CGFloat = 6
    private let separationActionKey = "separation"

    /// Quanto o card na posição `a` invade o card na posição `b`
    /// (bolinha + retângulo). 0 = não se tocam.
    private func cardOverlap(
        _ a: CGPoint, _ b: CGPoint,
        radiusA: CGFloat? = nil, radiusB: CGFloat? = nil,
        shiftA: CGFloat = 0, shiftB: CGFloat = 0
    ) -> CGFloat {
        let metrics = cardMetrics
        let spacing = dropSeparationSpacing
        // Raio da bolinha de cada card (o círculo do grupo é maior).
        let rA = radiusA ?? metrics.avatarRadius
        let rB = radiusB ?? metrics.avatarRadius

        let avatarA = CGPoint(x: a.x + metrics.avatarCenter.x, y: a.y + metrics.avatarCenter.y)
        let avatarB = CGPoint(x: b.x + metrics.avatarCenter.x, y: b.y + metrics.avatarCenter.y)
        // No grupo a cápsula fica mais à direita (ver `capsuleShift`).
        let rectA = metrics.bgRect.offsetBy(dx: a.x + shiftA, dy: a.y)
        let rectB = metrics.bgRect.offsetBy(dx: b.x + shiftB, dy: b.y)

        func circleRectPenetration(_ center: CGPoint, _ r: CGFloat, _ rect: CGRect) -> CGFloat {
            let closestX = max(rect.minX, min(center.x, rect.maxX))
            let closestY = max(rect.minY, min(center.y, rect.maxY))
            return max(0, r + spacing - hypot(center.x - closestX, center.y - closestY))
        }

        // Bolinha x bolinha
        let circles = max(0, rA + rB + spacing - hypot(avatarA.x - avatarB.x, avatarA.y - avatarB.y))

        // Bolinha x retângulo
        let circleARectB = circleRectPenetration(avatarA, rA, rectB)
        let circleBRectA = circleRectPenetration(avatarB, rB, rectA)

        // Retângulo x retângulo
        let expandedA = rectA.insetBy(dx: -spacing / 2, dy: -spacing / 2)
        let expandedB = rectB.insetBy(dx: -spacing / 2, dy: -spacing / 2)
        let overlapX = min(expandedA.maxX, expandedB.maxX) - max(expandedA.minX, expandedB.minX)
        let overlapY = min(expandedA.maxY, expandedB.maxY) - max(expandedA.minY, expandedB.minY)
        let rects = (overlapX > 0 && overlapY > 0) ? min(overlapX, overlapY) : 0

        return circles + circleARectB + circleBRectA + rects
    }

    /// Área REAL do nome + valor do card, em coordenadas do card.
    /// Pode passar do retângulo branco quando o nome ou o valor são longos.
    private func textRect(of card: SKNode) -> CGRect? {
        guard let bg = card.childNode(withName: "cardBackground") else {
            return nil
        }

        let labels = ["nameLabel", "valueLabel"].compactMap {
            bg.childNode(withName: $0)
        }

        guard !labels.isEmpty else {
            return nil
        }

        let localFrame = labels
            .map { $0.frame }
            .reduce(CGRect.null) { $0.union($1) }

        return localFrame.offsetBy(dx: bg.position.x, dy: bg.position.y)
    }

    /// Regra 8: nada de outro card (bolinha, emoji, retângulo ou textos)
    /// pode ficar sobre o nome/valor — inclusive a parte do texto
    /// que passa para fora do retângulo branco.
    private func textConflict(
        textA: CGRect?, at a: CGPoint,
        textB: CGRect?, at b: CGPoint,
        radiusA: CGFloat? = nil, radiusB: CGFloat? = nil,
        shiftA: CGFloat = 0, shiftB: CGFloat = 0
    ) -> CGFloat {
        let metrics = cardMetrics
        let spacing = dropSeparationSpacing
        let rA = radiusA ?? metrics.avatarRadius
        let rB = radiusB ?? metrics.avatarRadius

        func rectPenetration(_ x: CGRect, _ y: CGRect) -> CGFloat {
            let ex = x.insetBy(dx: -spacing / 2, dy: -spacing / 2)
            let ey = y.insetBy(dx: -spacing / 2, dy: -spacing / 2)
            let ox = min(ex.maxX, ey.maxX) - max(ex.minX, ey.minX)
            let oy = min(ex.maxY, ey.maxY) - max(ex.minY, ey.minY)
            return (ox > 0 && oy > 0) ? min(ox, oy) : 0
        }

        func circlePenetration(_ center: CGPoint, _ r: CGFloat, _ rect: CGRect) -> CGFloat {
            let closestX = max(rect.minX, min(center.x, rect.maxX))
            let closestY = max(rect.minY, min(center.y, rect.maxY))
            return max(0, r + spacing - hypot(center.x - closestX, center.y - closestY))
        }

        let avatarA = CGPoint(x: a.x + metrics.avatarCenter.x, y: a.y + metrics.avatarCenter.y)
        let avatarB = CGPoint(x: b.x + metrics.avatarCenter.x, y: b.y + metrics.avatarCenter.y)
        let bgA = metrics.bgRect.offsetBy(dx: a.x + shiftA, dy: a.y)
        let bgB = metrics.bgRect.offsetBy(dx: b.x + shiftB, dy: b.y)
        let worldTextA = textA?.offsetBy(dx: a.x, dy: a.y)
        let worldTextB = textB?.offsetBy(dx: b.x, dy: b.y)

        var total: CGFloat = 0

        if let tA = worldTextA {
            total += circlePenetration(avatarB, rB, tA)
            total += rectPenetration(tA, bgB)
        }

        if let tB = worldTextB {
            total += circlePenetration(avatarA, rA, tB)
            total += rectPenetration(tB, bgA)
        }

        if let tA = worldTextA, let tB = worldTextB {
            total += rectPenetration(tA, tB)
        }

        return total
    }

    /// Depois que o usuário solta um card: se algum card estiver sobre outro,
    /// afasta aos poucos SOMENTE os que se tocam, até nenhum ficar em cima de outro.
    /// Os cards ficam o mais perto possível de onde estavam (sem canto, sem posição fixa).
    ///
    /// `plannedCard`/`plannedPosition`: card que acabou de ser solto e o ponto
    /// onde ele vai terminar de deslizar (inércia do "gelo").
    private func separateCardsAfterDrop(
        animated: Bool = true,
        plannedCard: SKNode? = nil,
        plannedPosition: CGPoint? = nil,
        releaseSpeed: CGFloat = 0
    ) {
        let cards = children.filter {
            $0.name?.starts(with: "card_") == true &&
            $0.name != "removing_card"
        }

        guard !cards.isEmpty else {
            return
        }

        // Trabalha numa cópia das posições e só no final anima os cards.
        // O card solto entra já na posição onde vai terminar de deslizar.
        var positions = cards.map { card -> CGPoint in
            if card === plannedCard, let planned = plannedPosition {
                return clampedCardPosition(planned, for: card)
            }
            return clampedCardPosition(card.position, for: card)
        }
        positions = separatedPositions(for: cards, from: positions)

        // Anima somente os cards que precisaram se mover.
        for (card, target) in zip(cards, positions) {
            let distance = hypot(card.position.x - target.x, card.position.y - target.y)
            guard distance > 0.5 else { continue }

            guard animated else {
                card.position = target
                continue
            }

            // Card solto com velocidade: a duração acompanha a velocidade do dedo,
            // para o deslize começar na mesma velocidade e ir freando.
            var duration = iceSettleDuration
            let startsWithVelocity = card === plannedCard && releaseSpeed > 0
            if startsWithVelocity {
                duration = TimeInterval(min(1.2, max(0.45, iceInitialSpeedFactor * distance / releaseSpeed)))
            }

            card.run(
                iceSlide(to: target, duration: duration, startsWithVelocity: startsWithVelocity),
                withKey: separationActionKey
            )
        }
    }

    /// Calcula (sem animar) posições em que nenhum card fica sobre outro
    /// nem sobre textos, partindo de `initial` e movendo só o necessário.
    /// Mesma lógica usada ao soltar um card.
    private func separatedPositions(for cards: [SKNode], from initial: [CGPoint]) -> [CGPoint] {
        guard !cards.isEmpty, cards.count == initial.count else {
            return initial
        }

        var positions = zip(cards, initial).map { clampedCardPosition($1, for: $0) }
        let textRects = cards.map { textRect(of: $0) }
        let radii = cards.map { avatarRadius(of: $0) }
        let shifts = cards.map { capsuleShift(of: $0) }

        for _ in 0..<400 {
            var moved = false

            for i in 0..<(positions.count - 1) {
                for j in (i + 1)..<positions.count {
                    let conflict =
                        cardOverlap(
                            positions[i], positions[j],
                            radiusA: radii[i], radiusB: radii[j],
                            shiftA: shifts[i], shiftB: shifts[j]
                        ) +
                        textConflict(
                            textA: textRects[i], at: positions[i],
                            textB: textRects[j], at: positions[j],
                            radiusA: radii[i], radiusB: radii[j],
                            shiftA: shifts[i], shiftB: shifts[j]
                        )
                    guard conflict > 0 else { continue }

                    moved = true

                    // Cards são largos: separa preferencialmente na vertical.
                    var dx = positions[i].x - positions[j].x
                    var dy = (positions[i].y - positions[j].y) * 2
                    var distance = hypot(dx, dy)

                    if distance < 0.001 {
                        let angle = CGFloat.random(in: 0..<(2 * .pi))
                        dx = cos(angle)
                        dy = sin(angle)
                        distance = 1
                    }

                    // Passos pequenos = movimento mínimo necessário.
                    let step = min(conflict, 20) / 2 + 0.5

                    positions[i].x += dx / distance * step
                    positions[i].y += dy / distance * step
                    positions[j].x -= dx / distance * step
                    positions[j].y -= dy / distance * step
                }
            }

            // Regra 2: o card inteiro continua dentro da área permitida.
            for k in positions.indices {
                positions[k] = clampedCardPosition(positions[k], for: cards[k])
            }

            if !moved {
                break
            }
        }

        return positions
    }

    // MARK: - Animação "gelo"

    // Mesmo movimento da UserFlightScene:
    // - progresso "smoothstep" (sai e chega suave);
    // - trajetória em leve curva (Bézier quadrática), não em linha reta seca;
    // - no final, uma pequena acomodação (como o spring 0.45 / 0.75 do onArrival):
    //   passa um pouquinho do destino e volta suavemente.
    // O card inteiro (container) é que se move: bolinha, emoji, retângulo,
    // nome, valor e sombra juntos.

    /// Duração do deslize quando um card se acomoda/reorganiza
    /// (UserFlightScene usa 0.70).
    private let iceSettleDuration: TimeInterval = 0.7

    /// Duração da pequena acomodação final (spring response 0.45).
    private let iceLandingDuration: TimeInterval = 0.45

    /// Quanto passa do destino antes de acomodar: % da distância, com limite.
    private let iceLandingOvershootRatio: CGFloat = 0.04
    private let iceLandingOvershootMax: CGFloat = 6

    /// Curvatura da trajetória: % da distância, com o limite da UserFlightScene (36).
    private let iceArcRatio: CGFloat = 0.12
    private let iceArcMax: CGFloat = 36

    /// Card solto com velocidade: a curva começa com essa velocidade relativa
    /// (ease-out cúbico → derivada 3 em t = 0), para não dar tranco ao soltar.
    private let iceInitialSpeedFactor: CGFloat = 3

    /// Deslize "sobre gelo" do card inteiro, da posição ATUAL até `target`.
    /// Não altera o destino calculado; só a forma do movimento.
    private func iceSlide(
        to target: CGPoint,
        duration: TimeInterval,
        startsWithVelocity: Bool = false
    ) -> SKAction {
        let travel = CGFloat(duration)
        let landing = CGFloat(iceLandingDuration)

        // Calculados no primeiro frame, a partir da posição atual do card.
        var start: CGPoint?
        var control = CGPoint.zero
        var passPoint = target

        let slide = SKAction.customAction(withDuration: duration + iceLandingDuration) { [weak self] node, elapsed in
            guard let self else { return }

            if start == nil {
                let origin = node.position
                start = origin

                let dx = target.x - origin.x
                let dy = target.y - origin.y
                let distance = hypot(dx, dy)

                if distance > 0.001 {
                    let ux = dx / distance
                    let uy = dy / distance

                    // Leve curva lateral (como o controlPoint da UserFlightScene).
                    // Card solto pelo dedo segue reto na direção em que foi jogado.
                    let bend = startsWithVelocity ? 0 : min(self.iceArcMax, distance * self.iceArcRatio)
                    let side: CGFloat = origin.x <= target.x ? -1 : 1
                    control = CGPoint(
                        x: (origin.x + target.x) / 2 - uy * bend * side,
                        y: (origin.y + target.y) / 2 + ux * bend * side
                    )

                    // Ponto um pouquinho depois do destino (acomodação).
                    let overshoot = min(self.iceLandingOvershootMax, distance * self.iceLandingOvershootRatio)
                    passPoint = CGPoint(x: target.x + ux * overshoot, y: target.y + uy * overshoot)
                } else {
                    control = origin
                    passPoint = target
                }
            }

            guard let origin = start else { return }

            if elapsed <= travel {
                // Fase 1: desliza até passar levemente do destino.
                let t = min(max(elapsed / travel, 0), 1)
                let progress: CGFloat
                if startsWithVelocity {
                    // Já está em movimento (solto pelo dedo): só vai freando.
                    let inverse = 1 - t
                    progress = 1 - inverse * inverse * inverse
                } else {
                    // Igual à UserFlightScene: smoothstep.
                    progress = t * t * (3 - 2 * t)
                }

                let inverse = 1 - progress
                node.position = CGPoint(
                    x: inverse * inverse * origin.x + 2 * inverse * progress * control.x + progress * progress * passPoint.x,
                    y: inverse * inverse * origin.y + 2 * inverse * progress * control.y + progress * progress * passPoint.y
                )
            } else {
                // Fase 2: acomodação suave de volta ao destino (sem quique).
                let t = min(max((elapsed - travel) / landing, 0), 1)
                let progress = t * t * (3 - 2 * t)
                node.position = CGPoint(
                    x: passPoint.x + (target.x - passPoint.x) * progress,
                    y: passPoint.y + (target.y - passPoint.y) * progress
                )
            }
        }

        // Garante a posição final exata.
        return SKAction.sequence([slide, SKAction.move(to: target, duration: 0)])
    }

    // MARK: - Deslize de entrada (gelo)

    /// Distância do deslize de entrada de cada card (sutil).
    private let entryDriftDistance: ClosedRange<CGFloat> = 14...30
    /// Duração do deslize de entrada (cada card sorteia a sua).
    private let entryDriftDuration: ClosedRange<TimeInterval> = 1.3...1.9
    /// Pequeno atraso aleatório para os cards não andarem sincronizados.
    private let entryDriftDelay: ClosedRange<TimeInterval> = 0...0.12

    /// Ao entrar na tela: cada card começa na SUA posição aleatória (já sem
    /// sobreposição), escorrega um pouco numa direção própria, vai perdendo
    /// velocidade e para sozinho. Nada sai do centro nem de um ponto comum.
    private func startEntryDrift() {
        let cards = children.filter {
            $0.name?.starts(with: "card_") == true &&
            $0.name != "removing_card"
        }

        guard !cards.isEmpty else { return }

        // Direção e distância independentes para cada card
        // (vertical um pouco menor, porque os cards são largos).
        let drifted = cards.map { card -> CGPoint in
            let angle = CGFloat.random(in: 0..<(2 * .pi))
            let distance = CGFloat.random(in: entryDriftDistance)
            return CGPoint(
                x: card.position.x + cos(angle) * distance,
                y: card.position.y + sin(angle) * distance * 0.6
            )
        }

        // Onde cada card vai parar continua respeitando todas as regras:
        // limites da tela, nada sobre outro card e textos livres.
        let finals = separatedPositions(for: cards, from: drifted)

        // Todos nascem exatamente no MESMO ponto: o centro da tela.
        // Cada um segue dali a sua própria trajetória até a posição final.
        let entryOrigin = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        for card in cards {
            card.position = entryOrigin
        }

        for (card, final) in zip(cards, finals) {
            let distance = hypot(final.x - card.position.x, final.y - card.position.y)
            guard distance > 0.5 else { continue }

            let drift = SKAction.sequence([
                SKAction.wait(forDuration: TimeInterval.random(in: entryDriftDelay)),
                // Já começa em movimento e vai freando até parar (gelo).
                iceSlide(
                    to: final,
                    duration: TimeInterval.random(in: entryDriftDuration),
                    startsWithVelocity: true
                )
            ])

            // Mesma chave da separação: se o usuário pegar o card,
            // o deslize para e o card segue o dedo.
            card.run(drift, withKey: separationActionKey)
        }
    }

    // MARK: - Mantém cards dentro da tela
    private func keepCardsInsideScreen() {
        let cards = children.filter {
            $0.name?.starts(with: "card_") == true &&
            $0.name != "removing_card"
        }

        for card in cards {
            card.position = clampedCardPosition(card.position, for: card)
        }
    }

    // MARK: - Pagamento

    /// Conta o card como pago: soma o valor, some com o card e, se era o
    /// último, conclui a etapa. Usado pelo arrasto e pelo VoiceOver.
    private func registerPayment(for node: SKNode) {

        if let value =
            node.userData?["value"] as? Double {

            cardsVm?.totalAmount += value
        }

        if let userID = cardUserID(of: node) {
            // Card juntado: quem paga e todo mundo que ele cobre.
            cardsVm?.markGroupAsPaid(payerID: userID)
        }

        node.name = "removing_card"

        // Toque quando o card entra no círculo (arrasto, "Concluir
        // pagamento" ou VoiceOver).
        Haptics.cardPaid()

        let shrink = SKAction.scale(
            to: 0,
            duration: 0.2
        )

        let remove = SKAction.removeFromParent()

        node.run(
            SKAction.sequence([
                shrink,
                remove
            ])
        )

        let remainingCards =
            self.children.filter {
                $0.name?.starts(
                    with: "card_"
                ) == true
            }.count

        if remainingCards == 0 {

            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.2
            ) {
                // Todo mundo pagou.
                Haptics.allPaid()

                withAnimation(
                    .spring(response: 0.6, dampingFraction: 0.8)
                ) {
                    self.cardsVm?.isCompleted = true
                }
            }
        }
    }

    // MARK: - Acessibilidade (VoiceOver)

    /// Marca uma pessoa como paga sem arrastar o card — o VoiceOver não
    /// enxerga os nós do SpriteKit nem consegue fazer o arrasto.
    func accessibilityMarkAsPaid(userID: UUID) {
        guard let node = childNode(withName: "card_\(userID.uuidString)") else {
            return
        }

        if draggingNode === node {
            draggingNode = nil
            didMoveDuringTouch = false
        }

        node.removeAllActions()
        registerPayment(for: node)
    }

    // MARK: - Card em destaque (sheet de consumo)

    /// Some com o card na cena enquanto a cópia em SwiftUI aparece em
    /// destaque acima da sheet, e o traz de volta quando ela fecha.
    func setCardHidden(userID: UUID, hidden: Bool) {
        guard let node = childNode(withName: "card_\(userID.uuidString)") else {
            return
        }

        node.removeAction(forKey: "highlightFade")
        node.setScale(1.0)
        node.alpha = hidden ? 0 : 1
    }

    // MARK: - Juntar cards (um paga pelo outro)

    private let mergeHighlightKey = "mergeHighlight"

    private func cardUserID(of card: SKNode) -> UUID? {
        guard let string = card.userData?["userID"] as? String else { return nil }
        return UUID(uuidString: string)
    }

    /// Valor que a própria pessoa consumiu (com taxa de serviço).
    private func personalValue(for userID: UUID) -> Double {
        if let value = userTotals[userID] {
            return value
        }
        guard let billVm,
              let user = billVm.bill.users.first(where: { $0.id == userID }) else {
            return 0
        }
        return billVm.totalWithServiceFee(for: user)
    }

    /// Valor do card: o da pessoa + o de quem ela está cobrindo.
    private func groupValue(for payerID: UUID) -> Double {
        let members = cardsVm?.groups.members(of: payerID) ?? [payerID]
        return members.reduce(0) { $0 + personalValue(for: $1) }
    }

    /// Card embaixo do arrastado que pode recebê-lo (grupo com espaço).
    private func mergeTarget(for node: SKNode) -> SKNode? {
        guard
            let target = cardUnder(node),
            let movingID = cardUserID(of: node),
            let targetID = cardUserID(of: target),
            cardsVm?.groups.canMerge(movingID, into: targetID) ?? false
        else {
            return nil
        }
        return target
    }

    /// Outro card que está embaixo da bolinha do card arrastado.
    private func cardUnder(_ node: SKNode) -> SKNode? {
        let avatar = CGPoint(
            x: node.position.x + cardMetrics.avatarCenter.x,
            y: node.position.y + cardMetrics.avatarCenter.y
        )

        return children.first { other in
            other !== node &&
            other.name?.starts(with: "card_") == true &&
            other.alpha > 0 &&
            cardBounds(of: other)
                .offsetBy(dx: other.position.x, dy: other.position.y)
                .contains(avatar)
        }
    }

    private func updateMergeCandidate(for node: SKNode) {
        let target = mergeTarget(for: node)
        guard target !== mergeCandidate else { return }

        clearMergeCandidate()
        guard let target else { return }

        mergeCandidate = target
        target.run(.scale(to: 1.08, duration: 0.12), withKey: mergeHighlightKey)
        Haptics.cardMergeHover()
    }

    private func clearMergeCandidate() {
        guard let candidate = mergeCandidate else { return }
        candidate.run(.scale(to: 1.0, duration: 0.12), withKey: mergeHighlightKey)
        mergeCandidate = nil
    }

    /// Junta o card `node` dentro de `target`: quem é dono de `target`
    /// passa a pagar também o consumo de quem era dono de `node`.
    private func mergeCard(_ node: SKNode, into target: SKNode) {
        guard
            let movingID = cardUserID(of: node),
            let targetID = cardUserID(of: target),
            cardsVm?.groups.merge(movingID, into: targetID) != nil
        else {
            node.run(.scale(to: 1.0, duration: 0.15))
            node.zPosition = 1
            return
        }

        // Sai da contagem de cards na hora (pagamento/separação).
        node.name = "merged_card"
        node.removeAllActions()

        // O card "entra" na bolinha de quem vai pagar.
        let finalScale: CGFloat = 0.3
        let avatar = cardMetrics.avatarCenter
        let destination = CGPoint(
            x: target.position.x + avatar.x * (1 - finalScale),
            y: target.position.y + avatar.y * (1 - finalScale)
        )
        let absorb = SKAction.group([
            .move(to: destination, duration: 0.2),
            .scale(to: finalScale, duration: 0.2),
            .fadeOut(withDuration: 0.2)
        ])
        absorb.timingMode = .easeIn
        node.run(.sequence([absorb, .removeFromParent()]))

        refreshCard(target)
        target.removeAction(forKey: mergeHighlightKey)
        target.run(.sequence([
            .wait(forDuration: 0.15),
            .scale(to: 1.15, duration: 0.1),
            .scale(to: 1.0, duration: 0.15)
        ]))
        Haptics.cardMerged()

        // Valor maior = texto mais largo: acomoda os vizinhos.
        separateCardsAfterDrop()
    }

    /// Tremido curto no card que não pode receber mais ninguém.
    private func rejectMerge(on card: SKNode) {
        let shake = SKAction.sequence([
            .moveBy(x: -6, y: 0, duration: 0.05),
            .moveBy(x: 12, y: 0, duration: 0.08),
            .moveBy(x: -10, y: 0, duration: 0.07),
            .moveBy(x: 4, y: 0, duration: 0.05)
        ])
        card.run(shake, withKey: "rejectMerge")
        Haptics.cardMergeRejected()
    }

    /// Mesmo efeito de soltar o card de `userID` em cima do de `payerID`.
    func mergeCards(userID: UUID, into payerID: UUID) {
        let finalPayer = cardsVm?.groups.payer(for: payerID) ?? payerID

        guard
            let node = childNode(withName: "card_\(userID.uuidString)"),
            let target = childNode(withName: "card_\(finalPayer.uuidString)")
        else {
            return
        }

        if draggingNode === node {
            draggingNode = nil
            didMoveDuringTouch = false
        }

        mergeCard(node, into: target)
    }

    /// Tira a pessoa do grupo: o card dela sai de dentro do card de quem
    /// pagava e volta para a tela com o valor só dela.
    func splitCard(userID: UUID) {
        guard
            let oldPayer = cardsVm?.groups.split(userID),
            let user = billVm?.bill.users.first(where: { $0.id == userID })
        else {
            return
        }

        let payerNode = childNode(withName: "card_\(oldPayer.uuidString)")
        if let payerNode {
            refreshCard(payerNode)
        }

        let card = createCardNode(value: groupValue(for: userID), user: user)
        let origin = payerNode?.position ?? CGPoint(x: size.width / 2, y: size.height / 2)
        card.position = origin
        card.setScale(0.3)
        card.alpha = 0
        addChild(card)
        updateGroupAvatar(on: card)

        card.run(.group([
            .scale(to: 1.0, duration: 0.2),
            .fadeIn(withDuration: 0.2)
        ]))

        // Nasce logo abaixo de quem pagava e os cards se acomodam.
        separateCardsAfterDrop(
            plannedCard: card,
            plannedPosition: CGPoint(
                x: origin.x,
                y: origin.y - cardMetrics.bounds.height - 8
            )
        )
    }

    /// Atualiza valor e selo "+N" de um card depois de juntar/separar.
    private func refreshCard(_ card: SKNode) {
        guard let payerID = cardUserID(of: card) else { return }

        let value = groupValue(for: payerID)
        card.userData?["value"] = value

        if let label = card
            .childNode(withName: "cardBackground")?
            .childNode(withName: "valueLabel") as? SKLabelNode {
            label.attributedText = NSAttributedString(
                string: CurrencyHelper.formatWithSymbol(value),
                attributes: [
                    .font: cardMetrics.valueFont,
                    .foregroundColor: cardMetrics.valueColor
                ]
            )
        }

        updateGroupAvatar(on: card)
    }

    /// `true` se o card é de um grupo (alguém paga por mais pessoas).
    private func isGroupCard(_ card: SKNode) -> Bool {
        guard let id = cardUserID(of: card) else { return false }
        return !(cardsVm?.groups.covered(by: id).isEmpty ?? true)
    }

    /// Raio da bolinha do card: o círculo do grupo é maior.
    private func avatarRadius(of card: SKNode) -> CGFloat {
        let base = cardMetrics.avatarRadius
        return isGroupCard(card) ? base * GroupAvatarLayout.circleScale : base
    }

    /// Quanto a cápsula (retângulo com o valor) anda para a direita: no
    /// grupo o círculo cresce, então ela acompanha a borda dele.
    private func capsuleShift(of card: SKNode) -> CGFloat {
        guard isGroupCard(card) else { return 0 }
        return cardMetrics.avatarRadius * (GroupAvatarLayout.circleScale - 1)
    }

    /// Move a cápsula e a sombra dela para a posição certa do card.
    private func applyCapsuleShift(on card: SKNode) {
        let shift = capsuleShift(of: card)
        let current = card.userData?["capsuleShift"] as? CGFloat ?? 0
        let delta = shift - current
        guard abs(delta) > 0.01 else { return }

        for name in ["cardBackground", "cardShadow"] {
            card.childNode(withName: name)?.position.x += delta
        }
        card.userData?["capsuleShift"] = shift
    }

    /// Caixa do card inteiro (bolinha + retângulo), em coordenadas do card,
    /// já com o tamanho real da bolinha.
    private func cardBounds(of card: SKNode) -> CGRect {
        let metrics = cardMetrics
        let r = avatarRadius(of: card)
        let avatar = CGRect(
            x: metrics.avatarCenter.x - r,
            y: metrics.avatarCenter.y - r,
            width: r * 2,
            height: r * 2
        )
        return metrics.bgRect
            .offsetBy(dx: capsuleShift(of: card), dy: 0)
            .union(avatar)
    }

    /// Desenho do card conforme o grupo:
    /// - sozinho: bolinha colorida com emoji, nome e valor (card normal);
    /// - juntado: círculo branco com as bolinhas de cada pessoa (2 a 5),
    ///   selo com a quantidade e só o valor no retângulo.
    private func updateGroupAvatar(on card: SKNode) {
        card.childNode(withName: "groupAvatar")?.removeFromParent()
        card.childNode(withName: "groupShadow")?.removeFromParent()

        guard let payerID = cardUserID(of: card) else { return }

        let metrics = cardMetrics
        let memberIDs = cardsVm?.groups.members(of: payerID) ?? [payerID]
        let members = memberIDs.compactMap { id in
            billVm?.bill.users.first { $0.id == id }
        }
        let isGroup = members.count > 1

        let avatar = card.childNode(withName: "avatarBackground") as? SKShapeNode
        let emoji = card.childNode(withName: "emoji")
        let background = card.childNode(withName: "cardBackground")
        let nameLabel = background?.childNode(withName: "nameLabel")
        let valueLabel = background?.childNode(withName: "valueLabel") as? SKLabelNode

        // Cápsula acompanha o tamanho do círculo.
        applyCapsuleShift(on: card)

        // Retângulo: no grupo aparece só o valor, centralizado na altura.
        nameLabel?.isHidden = isGroup
        valueLabel?.verticalAlignmentMode = isGroup ? .center : .baseline
        valueLabel?.position = isGroup
            ? CGPoint(x: metrics.valuePosition.x, y: 0)
            : metrics.valuePosition

        guard isGroup else {
            // Volta a ser o card normal da pessoa.
            if let payer = members.first {
                avatar?.fillColor = UIColor(payer.color)
            }
            avatar?.strokeColor = .clear
            avatar?.setScale(1)
            emoji?.isHidden = false
            return
        }

        // A bolinha original vira o círculo branco do grupo.
        avatar?.fillColor = metrics.bgColor
        avatar?.strokeColor = .clear
        // Círculo do grupo maior que a bolinha normal.
        avatar?.setScale(GroupAvatarLayout.circleScale)
        emoji?.isHidden = true

        let radius = metrics.avatarRadius * GroupAvatarLayout.circleScale

        // Sombra do círculo branco (fica logo abaixo dele).
        let shadow = SKEffectNode()
        shadow.name = "groupShadow"
        shadow.shouldRasterize = true
        let blur = CIFilter(name: "CIGaussianBlur")
        blur?.setValue(GroupAvatarLayout.shadowRadius, forKey: kCIInputRadiusKey)
        shadow.filter = blur
        shadow.position = CGPoint(
            x: metrics.avatarCenter.x + GroupAvatarLayout.shadowOffset.width,
            y: metrics.avatarCenter.y - GroupAvatarLayout.shadowOffset.height
        )
        shadow.zPosition = (avatar?.zPosition ?? 1) - 0.1

        let shadowShape = SKShapeNode(circleOfRadius: radius)
        shadowShape.fillColor = UIColor.black.withAlphaComponent(GroupAvatarLayout.shadowOpacity)
        shadowShape.strokeColor = .clear
        shadow.addChild(shadowShape)
        card.addChild(shadow)
        let group = SKNode()
        group.name = "groupAvatar"
        group.position = metrics.avatarCenter
        group.zPosition = 2

        // Bolinhas de cada pessoa (y invertido: SpriteKit cresce pra cima).
        let slots = GroupAvatarLayout.slots(for: members.count)
        for (member, slot) in zip(members, slots) {
            let diameter = slot.diameter * radius
            let circle = SKShapeNode(circleOfRadius: diameter / 2)
            circle.fillColor = UIColor(member.color)
            circle.strokeColor = .clear
            circle.position = CGPoint(x: slot.center.x * radius, y: -slot.center.y * radius)

            let label = SKLabelNode(text: member.emoji)
            label.fontSize = diameter * GroupAvatarLayout.emojiScale
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            circle.addChild(label)

            group.addChild(circle)
        }

        // Selo com a quantidade de pessoas.
        let badgeRadius = GroupAvatarLayout.badgeRadius * radius
        let badge = SKShapeNode(circleOfRadius: badgeRadius)
        badge.fillColor = GroupAvatarLayout.badgeColor
        badge.strokeColor = .clear
        badge.position = CGPoint(
            x: GroupAvatarLayout.badgeCenter.x * radius,
            y: -GroupAvatarLayout.badgeCenter.y * radius
        )
        badge.zPosition = 1

        let count = SKLabelNode()
        count.attributedText = NSAttributedString(
            string: "\(members.count)",
            attributes: [
                .font: GroupAvatarLayout.badgeFont(size: badgeRadius * 1.25),
                .foregroundColor: UIColor.white
            ]
        )
        count.verticalAlignmentMode = .center
        count.horizontalAlignmentMode = .center
        badge.addChild(count)
        group.addChild(badge)

        card.addChild(group)
    }

    // MARK: - Pagar todos (botão "Concluir pagamento")

    /// Leva todos os cards que ainda faltam até o círculo de "Pago".
    /// Cada card voa em curva (mesmo estilo do voo da SplitView), diminuindo
    /// de tamanho, com um pequeno atraso entre eles; ao chegar, o pagamento
    /// é registrado normalmente (soma o valor e some com o card).
    func payAllUsers(animated: Bool) {
        guard !isPayingAll else { return }

        let cards = children.filter {
            $0.name?.starts(with: "card_") == true
        }

        guard !cards.isEmpty else { return }

        isPayingAll = true
        cardsVm?.isPayingAll = true

        // Cancela um arrasto em andamento.
        if let dragging = draggingNode {
            dragging.setScale(1.0)
            draggingNode = nil
            didMoveDuringTouch = false
        }

        // Para deslizes de "gelo" que ainda estejam rodando.
        cards.forEach { $0.removeAllActions() }

        guard animated else {
            cards.forEach { registerPayment(for: $0) }
            return
        }

        let dropCenter = CGPoint(x: size.width / 2, y: dropZoneRadius)
        let targetScale: CGFloat = 0.55
        let avatarOffset = cardMetrics.avatarCenter

        // O avatar (bolinha) do card termina no centro do círculo.
        let target = CGPoint(
            x: dropCenter.x - avatarOffset.x * targetScale,
            y: dropCenter.y - avatarOffset.y * targetScale
        )

        // Quem está mais perto do círculo sai primeiro.
        let orderedCards = cards.sorted {
            hypot($0.position.x - dropCenter.x, $0.position.y - dropCenter.y) <
            hypot($1.position.x - dropCenter.x, $1.position.y - dropCenter.y)
        }

        let flightDuration: TimeInterval = 0.55
        let stagger: TimeInterval = 0.07

        for (index, card) in orderedCards.enumerated() {
            card.zPosition = 10 + CGFloat(index)

            let start = card.position
            let horizontalBend: CGFloat = start.x <= target.x ? -36 : 36
            let controlPoint = CGPoint(
                x: ((start.x + target.x) / 2) + horizontalBend,
                y: ((start.y + target.y) / 2) + 40
            )
            let durationAsCGFloat = CGFloat(flightDuration)

            let flight = SKAction.customAction(withDuration: flightDuration) { node, elapsedTime in
                let linear = min(max(elapsedTime / durationAsCGFloat, 0), 1)
                let progress = linear * linear * (3 - (2 * linear))
                let inverse = 1 - progress

                node.position = CGPoint(
                    x: inverse * inverse * start.x +
                       2 * inverse * progress * controlPoint.x +
                       progress * progress * target.x,
                    y: inverse * inverse * start.y +
                       2 * inverse * progress * controlPoint.y +
                       progress * progress * target.y
                )
                node.setScale(1 + ((targetScale - 1) * progress))
            }

            card.run(
                SKAction.sequence([
                    .wait(forDuration: stagger * Double(index)),
                    flight
                ])
            ) { [weak self, weak card] in
                guard let self, let card else { return }
                card.position = target
                self.registerPayment(for: card)
            }
        }
    }

    // MARK: - Touch Ended

    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        guard let node = draggingNode else {
            return
        }

        // MARK: - Apenas toque

        if !didMoveDuringTouch {

            if let userIDString =
                node.userData?["userID"] as? String,
               let userID = UUID(
                    uuidString: userIDString
               ) {

                let avatarInScene = CGPoint(
                    x: node.position.x + cardMetrics.avatarCenter.x,
                    y: node.position.y + cardMetrics.avatarCenter.y
                )
                let avatarInView = convertPoint(toView: avatarInScene)

                DispatchQueue.main.async { [weak self] in
                    self?.onTapUser?(userID, avatarInView)
                }
            }

            node.run(
                SKAction.scale(
                    to: 1.0,
                    duration: 0.15
                )
            )

            node.zPosition = 1

            draggingNode = nil
            didMoveDuringTouch = false

            return
        }

        // MARK: - Drag / Drop

        let dropCenter = CGPoint(
            x: self.size.width / 2,
            y: dropZoneRadius
        )

        let distance = hypot(
            node.position.x - dropCenter.x,
            node.position.y - dropCenter.y
        )

        // MARK: Dropped on another card → junta os dois

        if let target = mergeCandidate ?? mergeTarget(for: node) {
            clearMergeCandidate()
            mergeCard(node, into: target)
            draggingNode = nil
            didMoveDuringTouch = false
            return
        }

        clearMergeCandidate()

        // Soltou em cima de um grupo que já tem 5 pessoas: ele treme
        // dizendo "não cabe" e o card arrastado se acomoda ao lado.
        if let full = cardUnder(node) {
            rejectMerge(on: full)
        }

        // MARK: Dropped in payment zone

        if distance < dropZoneRadius + 30 {

            registerPayment(for: node)

        } else {

            // MARK: Return to normal

            let scaleUp = SKAction.scale(
                to: 1.0,
                duration: 0.15
            )

            node.run(scaleUp)
            node.zPosition = 1

            // MARK: Inércia (gelo)
            // O card continua deslizando um pouco na direção em que foi solto.
            // Se o dedo já estava parado ao soltar, não há deslize.
            let releaseTime = event?.timestamp ?? lastTouchTime
            let fingerWasMoving = releaseTime - lastTouchTime < 0.1
            let velocity = fingerWasMoving ? dragVelocity : .zero
            let speed = hypot(velocity.dx, velocity.dy)

            // Distância do deslize = velocidade × "atrito" (limitada).
            let glideTime: CGFloat = 0.2
            let maxGlide: CGFloat = 140
            var glide = CGVector(dx: velocity.dx * glideTime, dy: velocity.dy * glideTime)
            let glideLength = hypot(glide.dx, glide.dy)
            if glideLength > maxGlide {
                glide.dx *= maxGlide / glideLength
                glide.dy *= maxGlide / glideLength
            }

            // O deslize nunca termina dentro da zona de pagamento
            // (pagamento só acontece quando o usuário solta lá).
            var glideTarget = clampedCardPosition(
                CGPoint(x: node.position.x + glide.dx, y: node.position.y + glide.dy),
                for: node
            )
            for _ in 0..<6 {
                let d = hypot(glideTarget.x - dropCenter.x, glideTarget.y - dropCenter.y)
                guard d < dropZoneRadius + 40 else { break }
                glide.dx /= 2
                glide.dy /= 2
                glideTarget = clampedCardPosition(
                    CGPoint(x: node.position.x + glide.dx, y: node.position.y + glide.dy),
                    for: node
                )
            }

            // Ao soltar: nenhum card pode ficar sobre outro.
            // Todos se acomodam com a animação de gelo.
            separateCardsAfterDrop(
                plannedCard: node,
                plannedPosition: glideTarget,
                releaseSpeed: speed
            )
        }

        draggingNode = nil
        didMoveDuringTouch = false
    }
}
