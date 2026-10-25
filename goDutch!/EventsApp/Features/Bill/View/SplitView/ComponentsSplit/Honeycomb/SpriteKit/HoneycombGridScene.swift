
//
//  HoneycomGridScene.swift
//  EventsApp
//
//  Created by Camila Parolin on 31/08/26.
//

//TODO: mudar fonte nome do usuario

import SpriteKit
import SwiftUI
import UIKit
import CoreHaptics

// Classe responsável por todo o comportamento do menu circular dentro do SpriteKit.
final class HoneycombGridScene: SKScene {
    
    private var isApplyingDataSnapshot = false
    
    // Sempre que uma das duas listas abaixo muda, a grade é reconstruída com animação.
    var users: [User] = [] {
        didSet {
            guard !isApplyingDataSnapshot, oldValue != users else {
                return
            }
            
            rebuildGrid()
        }
    }
    
    var assignedUserIDs: Set<User.ID> = [] {
        didSet {
            guard !isApplyingDataSnapshot, oldValue != assignedUserIDs else {
                return
            }
            
            rebuildGrid()
        }
    }
    
    var onTapSelect: ((HoneycombSelection) -> Bool)?
    var onLongPressSelectAll: (([User.ID]) -> Void)?
    /// Segurar um círculo específico (ex.: editar participante na AddUsers).
    /// Quando definido, tem prioridade sobre `onLongPressSelectAll`.
    var onLongPressUser: ((User.ID) -> Void)?
    
    var layoutAnimationDurationScale: TimeInterval = 1.0
    
    private func layoutDuration (_ originalDuration: TimeInterval) -> TimeInterval {
        max(0.01, originalDuration * layoutAnimationDurationScale)
    }
    
    var layoutScale: CGFloat = 1 {
        didSet {
            guard abs(oldValue - layoutScale) > 0.001 else {
                return
            }
            
            contentNode.removeAllChildren()
            contentNode.position = .zero
            rebuildGrid(animated: false)
        }
    }
    
    // Variáveis que controlam o tamanho dos círculos.
    private var circleRadius: CGFloat {
        40 * layoutScale
    }
    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 1.15
    
    private var horizontalSpacing: CGFloat {
        72 * layoutScale
    }
    private var verticalSpacing: CGFloat {
        80 * layoutScale
    }
    private var falloffRadius: CGFloat { horizontalSpacing * 2.0 }
    // Agrupa todos os círculos para que eles possam se mover juntos.
    private let contentNode = SKNode()
    private var focusPoint: CGPoint {
        CGPoint(x: size.width * (0.5 - anchorPoint.x), y: size.height * (0.5 - anchorPoint.y))
    }
    private var touchedCircle: CircleNode?
    private var touchStartLocation: CGPoint?
    private var lastTouchLocation: CGPoint?
    private var lastTouchTimestamp: TimeInterval = 0
    private var velocity: CGVector = .zero
    private var dragBounds: CGRect = .zero
    private let longPressDuration: TimeInterval = 0.8
    private var longPressMovementTolerance: CGFloat {
        10 * layoutScale
    }
    private var longPressWorkItem: DispatchWorkItem?
    private var didTriggerLongPress = false
    
    private var hapticEngine: CHHapticEngine?
    private var progressHapticPlayer: (any CHHapticPatternPlayer)?
    private let completionHapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = .clear
        view.backgroundColor = .clear
        view.isOpaque = false
        view.allowsTransparency = true
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if contentNode.parent == nil {
            addChild(contentNode)
        }
        contentNode.position = .zero
        rebuildGrid(animated: false)
        updateCircleScales()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        contentNode.position = .zero
        rebuildGrid(animated: false)
    }
    
    private func patternPositions(for count: Int) -> [CGPoint] {
        CirclePatternLayout.positions(
            for: count,
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing
        )
    }
    
    func applyDataSnapshot(users newUsers: [User], assignedUserIDs newAssignedUserIDs: Set<User.ID>) {
        let usersChanged = users != newUsers
        let assignmentsChanged = assignedUserIDs != newAssignedUserIDs
        
        guard usersChanged || assignmentsChanged else {
            return
        }
        
        isApplyingDataSnapshot = true
        
        users = newUsers
        assignedUserIDs = newAssignedUserIDs
        
        isApplyingDataSnapshot = false
        
        rebuildGrid()
    }
    
    func flightSelections(for userIDs: Set<User.ID>) -> [HoneycombSelection] {
        contentNode.removeAction(forKey: "inertia")
        velocity = .zero
        
        updateCircleScales()
        
        let userOrder = Dictionary(
            uniqueKeysWithValues: users.enumerated().map {
                ($0.element.id, $0.offset)
            }
        )
        
        return contentNode.children
            .compactMap { $0 as? CircleNode }
            .filter { circle in
                !circle.isHidden && userIDs.contains(circle.userID)
            }
            .sorted { firstCircle, secondCircle in
                let firstIndex = userOrder[firstCircle.userID] ?? Int.max
                let secondIndex = userOrder[secondCircle.userID] ?? Int.max
                
                return firstIndex < secondIndex
            }
            .map { circle in
                selectionInformation(for: circle)
            }
    }
    
    func setCirclesHidden(_ hidden: Bool, for userIDs: Set<User.ID>) {
        for case let circle as CircleNode in contentNode.children {
            guard userIDs.contains(circle.userID) else {
                continue
            }
            
            circle.isHidden = hidden
        }
    }
    
    func removeCirclesImmediately(for userIDs: Set<User.ID>) {
        for case let circle as CircleNode in contentNode.children {
            guard userIDs.contains(circle.userID) else {
                continue
            }
            
            circle.removeAllActions()
            circle.removeFromParent()
        }
    }
    
    // Reconstrói a grade reaproveitando os círculos existentes para permitir animações suaves.
    private func rebuildGrid(animated: Bool = true) {
        let availableUsers = Array(
            users
                .filter { !assignedUserIDs.contains($0.id) }
                .prefix(CirclePatternLayout.maximumCount)
        )
        let positions = patternPositions(for: availableUsers.count)
        guard !positions.isEmpty else {
            if animated {
                animateAllCirclesOut()
            } else {
                contentNode.removeAllChildren()
            }
            dragBounds = .zero
            contentNode.position = .zero
            return
        }
        updateDragBounds(for: positions)
        let newUserIDs = Set(availableUsers.map(\.id))
        let existingCircles = Dictionary(
            uniqueKeysWithValues: contentNode.children.compactMap { node -> (User.ID, CircleNode)? in
                guard let circle = node as? CircleNode else { return nil }
                return (circle.userID, circle)
            }
        )
        // Remove os círculos que não fazem mais parte da lista.
        for child in contentNode.children {
            guard let circle = child as? CircleNode else { continue }
            if !newUserIDs.contains(circle.userID) {
                if animated {
                    animateRemoval(circle)
                } else {
                    circle.removeFromParent()
                }
            }
        }
        // Atualiza ou cria os círculos atuais.
        for (user, position) in zip(availableUsers, positions) {
            if let circle = existingCircles[user.id] {
                circle.update(with: user)
                animateMove(circle, to: position)
            } else {
                let circle = CircleNode(
                    radius: circleRadius,
                    user: user
                )
                circle.position = position
                circle.alpha = animated ? 0 : 1
                circle.setScale(animated ? 0.01 : 1)
                contentNode.addChild(circle)
                if animated {
                    animateInsertion(circle)
                }
            }
        }
        updateCircleScales()
    }
    // Anima a entrada de um novo usuário com escala e opacidade.
    private func animateInsertion(_ circle: CircleNode) {
        circle.removeAllActions()
        
        let targetScale = focusScale(for: circle)
        
        circle.setScale(0.01)
        circle.alpha = 0
        
        let scaleUp = SKAction.scale(to: targetScale, duration: layoutDuration(0.32))
        scaleUp.timingMode = .easeOut
        
        let bounceUp = SKAction.scale(to: targetScale * 1.08, duration: layoutDuration(0.12))
        bounceUp.timingMode = .easeOut
        
        let bounceDown = SKAction.scale(to: targetScale, duration: layoutDuration(0.12))
        bounceDown.timingMode = .easeInEaseOut
        
        let scaleSequence = SKAction.sequence([scaleUp, bounceUp, bounceDown])
        
        let fadeIn = SKAction.fadeIn(withDuration: layoutDuration(0.20))
        fadeIn.timingMode = .easeOut
        
        let insertionAnimation = SKAction.group([
            scaleSequence,
            fadeIn
        ])
        
        let finishInsertion = SKAction.run {
            [weak self, weak circle] in
            
            guard let self = self, let circle = circle else {
                return
            }
            
            circle.alpha = 1
            
            circle.applyFocusEffect(scale: self.focusScale(for: circle))
        }
        
        circle.run(
            SKAction.sequence([
                insertionAnimation,
                finishInsertion
            ]),
            withKey: "insertion"
        )
    }
    
    // Anima a saída de um usuário antes de removê-lo da cena.
    private func animateRemoval(_ circle: CircleNode) {
        circle.removeAllActions()
        let shrink = SKAction.scale(to: 0.01, duration: layoutDuration(0.25))
        shrink.timingMode = .easeIn
        let fadeOut = SKAction.fadeOut(withDuration: layoutDuration(0.20))
        fadeOut.timingMode = .easeIn
        
        let removalAnimation = SKAction.group([
            shrink,
            fadeOut
        ])
        
        circle.run(SKAction.sequence([removalAnimation, SKAction.removeFromParent()]), withKey: "removal")
    }
    
    // Move suavemente um círculo quando a posição dos usuários muda.
    private func animateMove(_ circle: CircleNode, to position: CGPoint) {
        circle.removeAction(forKey: "move")
        let move = SKAction.move(to: position, duration: layoutDuration(0.30))
        move.timingMode = .easeOut
        circle.run(move, withKey: "move")
    }
    
    // Anima todos os círculos para fora quando não existem usuários disponíveis.
    private func animateAllCirclesOut() {
        for child in contentNode.children {
            guard let circle = child as? CircleNode else { continue }
            animateRemoval(circle)
        }
    }
    // Calcula até onde o agrupamento inteiro pode ser movimentado.
    private func updateDragBounds(for positions: [CGPoint]) {
        let minX = positions.map(\.x).min() ?? 0
        let maxX = positions.map(\.x).max() ?? 0
        let minY = positions.map(\.y).min() ?? 0
        let maxY = positions.map(\.y).max() ?? 0
        let minimumContentX = min(0, focusPoint.x - maxX)
        let maximumContentX = max(0, focusPoint.x - minX)
        let minimumContentY = min(0, focusPoint.y - maxY)
        let maximumContentY = max(0, focusPoint.y - minY)
        dragBounds = CGRect(
            x: minimumContentX,
            y: minimumContentY,
            width: maximumContentX - minimumContentX,
            height: maximumContentY - minimumContentY
        )
        contentNode.position = CGPoint(
            x: min(
                max(contentNode.position.x, dragBounds.minX),
                dragBounds.maxX
            ),
            y: min(
                max(contentNode.position.y, dragBounds.minY),
                dragBounds.maxY
            )
        )
    }
    
    private func focusScale(for circle: CircleNode) -> CGFloat {
        let positionInScene = contentNode.convert(circle.position, to: self)
        
        let distance = hypot(positionInScene.x - focusPoint.x, positionInScene.y - focusPoint.y)
        
        let progress = min(max(distance / falloffRadius, 0), 1)
        
        let easedProgress = 1 - pow(1 - progress, 2)
        
        return maxScale - (maxScale - minScale) * easedProgress
    }
    
    // Aumenta os círculos próximos ao foco central e reduz os mais distantes.
    private func updateCircleScales() {
        for case let circle as CircleNode in contentNode.children {
            let positionInScene = contentNode.convert(circle.position, to: self)
            let distance = hypot(positionInScene.x - focusPoint.x, positionInScene.y - focusPoint.y)
            
            circle.zPosition = 100 - (distance / 10)
            
            let isRunningTransition = circle.action(forKey: "insertion") != nil || circle.action(forKey: "removal") != nil || circle.action(forKey: "tapFeedback") != nil
            
            guard !isRunningTransition else {
                continue
            }
            
            circle.applyFocusEffect(scale: focusScale(for: circle))
            
        }
    }
    
    //Calcula a distância entre um círculo e o centro visual da honeycomb
    private func distanceFromFocus(to circle: CircleNode) -> CGFloat {
        let circlePosition = contentNode.convert(circle.position, to: self)
        
        return hypot(circlePosition.x - focusPoint.x, circlePosition.y - focusPoint.y)
    }
    
    //Verifica se o círculo pressionado é o círculo central naquele momento
    private func isCircleCentered(_ circle: CircleNode) -> Bool {
        let circles = contentNode.children.compactMap {
            $0 as? CircleNode
        }
        
        guard let centeredCircle = circles.min(by: {
            distanceFromFocus(to: $0) < distanceFromFocus(to: $1)
        }) else {
            return false
        }
        
        return centeredCircle === circle
    }
    
    //Prepara o mecanismo responsável pelo haptic contínuo
    private func prepareHapticEngine() {
        guard CHHapticEngine
            .capabilitiesForHardware()
            .supportsHaptics else {
            return
        }
        
        do {
            if hapticEngine == nil {
                let engine = try CHHapticEngine()
                
                // Só haptics: sem isso o engine usa a sessão de áudio do app
                // e pode silenciar/atrapalhar outros sons (ex.: o pop).
                engine.playsHapticsOnly = true
                engine.isAutoShutdownEnabled = true
                
                engine.stoppedHandler = { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.progressHapticPlayer = nil
                    }
                }
                
                engine.resetHandler = { [weak self] in
                    DispatchQueue.main.async {
                        guard let self = self else {
                            return
                        }
                        
                        self.progressHapticPlayer = nil
                        try? self.hapticEngine?.start()
                    }
                }
                
                hapticEngine = engine
            }
            
            try hapticEngine?.start()
        } catch {
            hapticEngine = nil
            progressHapticPlayer = nil
        }
    }
    
    //Inicia uma vibração contínua que cresce mais rapidamente no final
    private func startProgressHaptic() {
        stopProgressHaptic()
        
        guard AppSettings.isAnimationsOn else {
            return
        }
        
        prepareHapticEngine()
        
        guard let hapticEngine = hapticEngine else {
            return
        }
        
        let continuosEvent = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.12)
            ],
            relativeTime: 0,
            duration: longPressDuration
        )
        
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                .init(relativeTime: 0.00, value: 0.03),
                .init(relativeTime: longPressDuration * 0.45, value: 0.15),
                .init(relativeTime: longPressDuration * 0.68, value: 0.32),
                .init(relativeTime: longPressDuration * 0.82, value: 0.58),
                .init(relativeTime: longPressDuration * 0.93, value: 0.85),
                .init(relativeTime: longPressDuration, value: 0.85)
            ],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [continuosEvent], parameterCurves: [intensityCurve])
            let player = try hapticEngine.makePlayer(with: pattern)
            
            progressHapticPlayer = player
            
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            progressHapticPlayer = nil
        }
    }
    
    //Interrompe imediamente o preenchimento tátil
    private func stopProgressHaptic() {
        try? progressHapticPlayer?.stop(atTime: CHHapticTimeImmediate)
        progressHapticPlayer = nil
    }
    
    //Inicia a contagem de dois segundos para selecionar todos
    private func scheduleLongPressIfNeeded(for circle: CircleNode) {
        // Segurar um círculo qualquer (não precisa estar no centro).
        if onLongPressUser != nil {
            scheduleUserLongPress(for: circle)
            return
        }

        guard onLongPressSelectAll != nil, isCircleCentered(circle) else {
            return
        }
        
        cancelPendingLongPress()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else {
                return
            }
            
            guard self.touchedCircle === circle, self.isCircleCentered(circle) else {
                return
            }
            
            let availableUserIDs = self.users
                .filter {
                    !self.assignedUserIDs.contains($0.id)
                }
                .prefix(CirclePatternLayout.maximumCount)
                .map(\.id)
            
            guard !availableUserIDs.isEmpty else {
                return
            }
            
            self.stopProgressHaptic()
            self.longPressWorkItem = nil
            self.didTriggerLongPress = true
            self.velocity = .zero
            
            if AppSettings.isAnimationsOn {
                self.completionHapticGenerator.impactOccurred()
            }
            
            self.onLongPressSelectAll?(availableUserIDs)
        }
        
        longPressWorkItem = workItem
        
        completionHapticGenerator.prepare()
        startProgressHaptic()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + longPressDuration, execute: workItem)
        
    }
    
    /// Conta o tempo do toque longo em um círculo e chama `onLongPressUser`.
    private func scheduleUserLongPress(for circle: CircleNode) {
        cancelPendingLongPress()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self, self.touchedCircle === circle else { return }

            self.stopProgressHaptic()
            self.longPressWorkItem = nil
            self.didTriggerLongPress = true
            self.velocity = .zero

            if AppSettings.isAnimationsOn {
                self.completionHapticGenerator.impactOccurred()
            }
            self.animateTapFeedback(circle)

            self.onLongPressUser?(circle.userID)
        }

        longPressWorkItem = workItem

        completionHapticGenerator.prepare()
        startProgressHaptic()

        DispatchQueue.main.asyncAfter(deadline: .now() + longPressDuration, execute: workItem)
    }

    //Cancela a contagem quando o usuário solta ou arrasta o dedo
    private func cancelPendingLongPress() {
        longPressWorkItem?.cancel()
        longPressWorkItem = nil
        
        stopProgressHaptic()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        cancelPendingLongPress()
        didTriggerLongPress = false
        
        let location = touch.location(in: self)
        let hitNode = atPoint(location)
        // Guarda o círculo tocado apenas para identificar um clique.
        // A posição dele nunca será alterada diretamente.
        touchedCircle = (hitNode as? CircleNode) ?? (hitNode.parent as? CircleNode)
        touchStartLocation = location
        lastTouchLocation = location
        lastTouchTimestamp = event?.timestamp ?? CACurrentMediaTime()
        velocity = .zero
        contentNode.removeAction(forKey: "inertia")
        
        if let touchedCircle = touchedCircle {
            scheduleLongPressIfNeeded(for: touchedCircle)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let touch = touches.first,
            let lastLocation = lastTouchLocation
        else {
            return
        }
        
        let location = touch.location(in: self)
        
        if didTriggerLongPress {
            return
        }
        
        if let startLocation = touchStartLocation {
            let totalMovement = hypot(location.x - startLocation.x, location.y - startLocation.y)
            
            if totalMovement > longPressMovementTolerance {
                cancelPendingLongPress()
            }
        }
        
        let dx = location.x - lastLocation.x
        let dy = location.y - lastLocation.y
        
        // Movimenta o conjunto inteiro, nunca um CircleNode isolado.
        moveContent(byX: dx, y: dy)
        let timestamp = event?.timestamp ?? CACurrentMediaTime()
        let timeDifference = max(timestamp - lastTouchTimestamp, 1.0 / 120.0)
        velocity = CGVector(dx: dx / CGFloat(timeDifference), dy: dy / CGFloat(timeDifference))
        lastTouchLocation = location
        lastTouchTimestamp = timestamp
    }
    
    private func selectionInformation(for circle: CircleNode) -> HoneycombSelection {
        let centerInScene = circle.convert(CGPoint.zero, to: self)
        
        let rightEdgeInScene = circle.convert(CGPoint(x: circleRadius, y: 0), to: self)
        
        //Converte a coordenada do SpriteKit para a coordenada visual do SKView
        let centerInView = convertPoint(toView: centerInScene)
        let rightEdgeInView = convertPoint(toView: rightEdgeInScene)
        
        let visibleRadius = hypot(rightEdgeInView.x - centerInView.x, rightEdgeInView.y - centerInView.y)
        
        return HoneycombSelection(userID: circle.userID, centerInHoneycomb: centerInView, diameter: visibleRadius * 2)
    }
    
    // MARK: - Acessibilidade (VoiceOver)

    /// Seleciona o círculo de uma pessoa sem toque na tela — usado pelo
    /// VoiceOver, que não enxerga os nós do SpriteKit. Centraliza o círculo
    /// antes, para a animação de voo sair do lugar certo.
    /// Retorna `nil` quando o círculo não está na grade.
    @discardableResult
    func accessibilitySelect(userID: User.ID) -> Bool? {
        guard let circle = contentNode.children
            .compactMap({ $0 as? CircleNode })
            .first(where: { $0.userID == userID && !$0.isHidden })
        else {
            return nil
        }

        contentNode.removeAction(forKey: "inertia")
        velocity = .zero
        contentNode.position = CGPoint(x: -circle.position.x, y: -circle.position.y)
        updateCircleScales()

        let selection = selectionInformation(for: circle)
        let didStartFlight = onTapSelect?(selection) ?? false

        if didStartFlight {
            circle.isHidden = true
        } else {
            animateTapFeedback(circle)
        }

        return didStartFlight
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            resetTouchState()
            return
        }
        
        if didTriggerLongPress {
            resetTouchState()
            return
        }
        
        let finalLocation = touch.location(in: self)
        let dragDistance: CGFloat
        if let startLocation = touchStartLocation {
            dragDistance = hypot(finalLocation.x - startLocation.x, finalLocation.y - startLocation.y)
        } else {
            dragDistance = 0
        }
        if dragDistance < 5 {
            if let startedCircle = touchedCircle,
               !startedCircle.isHidden,
               startedCircle.parent != nil {
                
                let selection = selectionInformation(for: startedCircle)
                
                // Para a vibração contínua do toque longo ANTES do toque ser
                // tratado. Se ela ainda estiver tocando, o haptic do toque
                // (ex.: pop ao remover) é engolido por ela.
                cancelPendingLongPress()
                
                let didStartFlight = onTapSelect?(selection) ?? false
                
                if didStartFlight {
                    startedCircle.isHidden = true
                } else {
                    animateTapFeedback(startedCircle)
                }
            }
        } else {
            applyInertia()
        }
        resetTouchState()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        velocity = .zero
        resetTouchState()
    }
    
    // Cria um pequeno efeito de pressão ao tocar em um usuário.
    private func animateTapFeedback(_ circle: CircleNode) {
        circle.removeAction(forKey: "tapFeedback")
        let shrink = SKAction.scale(to: circle.xScale * 0.88, duration: 0.08)
        shrink.timingMode = .easeIn
        let restore = SKAction.scale(to: circle.xScale, duration: 0.12)
        restore.timingMode = .easeOut
        circle.run(SKAction.sequence([shrink, restore]), withKey: "tapFeedback")
    }
    
    private func resetTouchState() {
        cancelPendingLongPress()
        
        touchedCircle = nil
        touchStartLocation = nil
        lastTouchLocation = nil
        didTriggerLongPress = false
    }
    
    // Movimenta o agrupamento sem ultrapassar seus limites.
    private func moveContent(byX dx: CGFloat, y dy: CGFloat) {
        var newX = contentNode.position.x + dx
        var newY = contentNode.position.y + dy
        newX = min(max(newX, dragBounds.minX), dragBounds.maxX)
        newY = min(max(newY, dragBounds.minY), dragBounds.maxY)
        contentNode.position = CGPoint(x: newX, y: newY)
    }
    
    // Mantém um pequeno movimento depois que o usuário solta o dedo.
    private func applyInertia() {
        let decelerate = SKAction.customAction(
            withDuration: 0.6
        ) { [weak self] _, elapsed in
            guard let self else { return }
            let progress = elapsed / 0.6
            let damping = 1 - progress
            let dx = self.velocity.dx * 0.016 * damping
            let dy = self.velocity.dy * 0.016 * damping
            self.moveContent(byX: dx, y: dy)
        }
        contentNode.run(
            decelerate,
            withKey: "inertia"
        )
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateCircleScales()
    }
}
