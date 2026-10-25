//
//  UserPhysicsClusterScene.swift
//  EventsApp
//
//  Created by Camila Parolin on 29/09/26.
//
import SpriteKit
import UIKit

struct PhysicsUserSelection {
    let userID: User.ID
    let centerInView: CGPoint
    let diameter: CGFloat
}

enum UserPhysicsClusterMode: Equatable {
    case honeycomb
    case maxCard
}

private final class PhysicsUserNode: SKNode {
    let userID: User.ID
    
    private let circle: CircleNode
    private let radius: CGFloat
    private let collisionPadding: CGFloat = 1
    
    init(radius: CGFloat, user: User) {
        self.userID = user.id
        self.radius = radius
        self.circle = CircleNode(radius: radius, user: user)
        
        super.init()
        
        circle.position = .zero
        circle.physicsBody = nil
        
        addChild(circle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var nameCollisionFrame: CGRect? {
        guard let label = circle.childNode(withName: "userNameLabel") as? SKLabelNode else {
            return nil
        }
        
        let textFrame = label.frame
        
        guard textFrame.width > 0, textFrame.height > 0 else {
            return nil
        }
        
        return textFrame.insetBy(dx: -collisionPadding, dy: -collisionPadding)
    }
    
    var collisionFootprintRadius: CGFloat {
        let circleExtent = radius + collisionPadding
        
        guard let nameFrame = nameCollisionFrame else {
            return circleExtent
        }
        
        let corners = [
            CGPoint(x: nameFrame.minX, y: nameFrame.minY),
            CGPoint(x: nameFrame.minX, y: nameFrame.maxY),
            CGPoint(x: nameFrame.maxX, y: nameFrame.minY),
            CGPoint(x: nameFrame.maxX, y: nameFrame.maxY)
        ]
        
        let textExtent = corners.map {
            hypot($0.x, $0.y)
        }.max() ?? 0
        
        return max(circleExtent, textExtent)
    }
    
    func makeCollisionBody() -> SKPhysicsBody {
        let circleBody = SKPhysicsBody(circleOfRadius: radius + collisionPadding)
        
        guard let nameFrame = nameCollisionFrame else {
            return circleBody
        }
        
        let nameBody = SKPhysicsBody(
            rectangleOf: nameFrame.size,
            center: CGPoint(x: nameFrame.midX, y: nameFrame.midY)
        )
        
        return SKPhysicsBody(bodies: [circleBody, nameBody])
    }
    
    func update(with user: User) {
        let previousNameFrame = nameCollisionFrame
        
        circle.update(with: user)
        
        guard
            nameCollisionFrame != previousNameFrame,
            let previousBody = physicsBody
        else {
            return
        }
        
        let newBody = makeCollisionBody()
        
        newBody.affectedByGravity = previousBody.affectedByGravity
        newBody.allowsRotation = previousBody.allowsRotation
        newBody.isDynamic = previousBody.isDynamic
        newBody.mass = previousBody.mass
        newBody.linearDamping = previousBody.linearDamping
        newBody.angularDamping = previousBody.angularDamping
        newBody.friction = previousBody.friction
        newBody.restitution = previousBody.restitution
        
        newBody.categoryBitMask = previousBody.categoryBitMask
        newBody.collisionBitMask = previousBody.collisionBitMask
        newBody.contactTestBitMask = previousBody.contactTestBitMask
        newBody.fieldBitMask = previousBody.fieldBitMask
        newBody.usesPreciseCollisionDetection = previousBody.usesPreciseCollisionDetection
        
        let previousVelocity = previousBody.velocity
        let previousAngularVelocity = previousBody.angularVelocity
        
        physicsBody = newBody
        
        newBody.velocity = previousVelocity
        newBody.angularVelocity = previousAngularVelocity
        
        if newBody.isDynamic {
            newBody.isResting = false
        }
    }
    
    func setVisualScale(_ targetScale: CGFloat, immediately: Bool) {
        let scale: CGFloat
        
        if immediately {
            scale = targetScale
        } else {
            scale = xScale + (targetScale - xScale) * 0.22
        }
        
        guard abs(scale - xScale) > 0.0001 else {
            return
        }
        
        setScale(scale)
        
        if let body = physicsBody, body.isDynamic {
            body.isResting = false
        }
    }
}

final class UserPhysicsClusterScene: SKScene {
    
    var onTapUser: ((User.ID) -> Void)?
    var onTapSelection: ((PhysicsUserSelection) -> Bool)?
    var onLongPressUsers: (([User.ID]) -> Void)?
    /// Segurar UM círculo (ex.: editar participante na AddUsersView).
    /// Quando definido, tem prioridade sobre `onLongPressUsers`.
    var onLongPressUser: ((User.ID) -> Void)?
    var onTapBackground: (() -> Void)?
    
    var onVisualCenterUserChanged: ((User.ID?) -> Void)?
    
    var circleRadius: CGFloat = 30 {
        didSet {
            guard abs(circleRadius - oldValue) > 0.001 else { return }
            
            circlesByUserID.values.forEach { $0.removeFromParent() }
            circlesByUserID.removeAll()
            
            rebuildBoundary()
            
            if view != nil {
                reconcileSnapshot()
            }
        }
    }
    var maximumUserCount = 12
    
    var mode: UserPhysicsClusterMode = .honeycomb {
        didSet {
            guard mode != oldValue else {
                return
            }
            
            configureMode()
        }
    }
    
    private enum PhysicsCategory {
        static let user: UInt32 = 1 << 0
        static let boundary: UInt32 = 1 << 1
    }
    
    private var hiddenUserIDs: Set<User.ID> = []
    private var didTriggerLongPress = false
    
    private var snapshotUsers: [User] = []
    private var requestedCenteredUserID: User.ID?
    
    private var circlesByUserID: [User.ID: PhysicsUserNode] = [:]
    
    private var centeredUserID: User.ID?
    private var visualCenteredUserID: User.ID?
    private var boundaryNode: SKShapeNode?
    
    private let clusterCamera = SKCameraNode()
    
    private var cameraVelocity = CGVector(dx: 0, dy: 0)
    private var lastUpdateTime: TimeInterval?
    private var touchedUserID: User.ID?
    private var lastTouchPointInView: CGPoint?
    private var lastTouchTimestamp: TimeInterval?
    private var accumulatedTouchDistance: CGFloat = 0
    private var isDraggingCamera = false
    private var attractionIsActive = false
    private var attractionStartedAt: TimeInterval?
    private var stableFrameCount = 0
    private let attractionStrength: CGFloat = 16
    private let maximumSpeed: CGFloat = 360
    private let restSpeedThreshold: CGFloat = 5
    private let requiredStableFrames = 12
    private let maximumSimulationDuration: TimeInterval = 1.2
    private let minimumFocusScale: CGFloat = 0.50
    private let maximumFocusScale: CGFloat = 1.15
    private let dragActivationDistance: CGFloat = 10
    
    private let longPressHaptics = UserClusterHapticController()
    private let longPressActionKey = "physicsClusterLongPress"
    
    private var longPressDuration: TimeInterval {
        mode == .honeycomb ? 0.8 : 1
    }
    
    var usesRectangularBoundary = false {
        didSet {
            guard usesRectangularBoundary != oldValue else { return }
            rebuildBoundary()
            wakeCluster()
        }
    }
    
    private var rectangularBoundary: CGRect {
        CGRect(
            x: -size.width / 2 + 3,
            y: -size.height / 2 + 3,
            width: max(0, size.width - 6),
            height: max(0, size.height - 6)
        )
    }
    
    private var boundaryRadius: CGFloat {
        max(circleRadius + 4, min(size.width, size.height) / 2 - 3)
    }
    
    private var focusFallofDistance: CGFloat {
        max(circleRadius * 3.2, min(size.width, size.height) * 0.46)
    }
    
    private var maximumCameraOffset: CGFloat {
        max(0, boundaryRadius - circleRadius - 4)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        backgroundColor = .clear
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        view.backgroundColor = .clear
        view.isOpaque = false
        view.allowsTransparency = true
        
        physicsWorld.gravity = .zero
        
        if clusterCamera.parent == nil {
            addChild(clusterCamera)
        }
        
        camera = clusterCamera
        
        configureMode()
        rebuildBoundary()
        reconcileSnapshot()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        rebuildBoundary()
        clampCameraPosition()
        wakeCluster()
        
        refreshVisualFocus(immediately: true)
    }
    
    func apply(users newUsers: [User], centeredUserID newCenteredUserID: User.ID?, hiddenUserIDs newHiddenUserIDs: Set<User.ID> = []) {
        snapshotUsers = Array(newUsers.prefix(maximumUserCount))
        
        hiddenUserIDs = newHiddenUserIDs.intersection(Set(snapshotUsers.map(\.id)))
        
        requestedCenteredUserID = newCenteredUserID
        
        guard view != nil, size.width > 0, size.height > 0 else {
            return
        }
        
        reconcileSnapshot()
    }
    
    private func configureMode() {
        cameraVelocity = CGVector(dx: 0, dy: 0)
        rebuildBoundary()
        
        if mode == .maxCard {
            clusterCamera.position = .zero
        }
        
        refreshVisualFocus(immediately: true)
        wakeCluster()
    }
    
    private func reconcileSnapshot() {
        
        let snapshotIDs = Set(snapshotUsers.map(\.id))
        hiddenUserIDs.formIntersection(snapshotIDs)
        
        let activeUsers = snapshotUsers.filter {
            !hiddenUserIDs.contains($0.id)
        }
        
        let validUserIDs = Set(activeUsers.map(\.id))
        
        let removedUserIDs = circlesByUserID.keys.filter {
            !snapshotIDs.contains($0)
        }
        
        for userID in removedUserIDs {
            circlesByUserID[userID]?.removeFromParent()
            circlesByUserID.removeValue(forKey: userID)
        }
        
        for (index, user) in snapshotUsers.enumerated() {
            if let existingCircle = circlesByUserID[user.id] {
                existingCircle.update(with: user)
            } else {
                let circle = makeCircle(for: user, index: index)
                circlesByUserID[user.id] = circle
                addChild(circle)
            }
        }
        
        for (userID, circle) in circlesByUserID {
            let hidden = hiddenUserIDs.contains(userID)
            
            circle.isHidden = hidden
            circle.physicsBody?.categoryBitMask = hidden ? 0 : PhysicsCategory.user
            circle.physicsBody?.collisionBitMask = hidden ? 0 : PhysicsCategory.user | PhysicsCategory.boundary
            
            if hidden {
                circle.physicsBody?.isDynamic = false
                circle.physicsBody?.velocity = .zero
                circle.physicsBody?.angularVelocity = 0
            }
        }
        
        guard !activeUsers.isEmpty else {
            centeredUserID = nil
            attractionIsActive = false
            resetCamera()
            updateVisualCenteredUserID(nil)
            return
        }
        
        let validRequestedCenter = requestedCenteredUserID.flatMap {
            validUserIDs.contains($0) ? $0 : nil
        }
        
        let validCurrentCenter = centeredUserID.flatMap {
            validUserIDs.contains($0) ? $0 : nil
        }
        
        let resolvedCenter = validRequestedCenter ?? validCurrentCenter ?? activeUsers.first?.id
        
        updateCenteredUser(to: resolvedCenter)
        wakeCluster()
        
        refreshVisualFocus(immediately: circlesByUserID.count == 1)
    }
    
    private func makeCircle(for user: User, index: Int) -> PhysicsUserNode {
        let circle = PhysicsUserNode(radius: circleRadius, user: user)
        let largestScale: CGFloat = mode == .honeycomb ? maximumFocusScale : 1
        
        circle.position = spawnPosition(for: index, footprintRadius: circle.collisionFootprintRadius * largestScale)
        circle.zPosition = 100
        
        let body = circle.makeCollisionBody()
        
        body.affectedByGravity = false
        body.allowsRotation = false
        body.mass = 1
        body.linearDamping = 6.5
        body.angularDamping = 1
        body.friction = 0.18
        body.restitution = 0.06
        body.categoryBitMask = PhysicsCategory.user
        body.collisionBitMask = PhysicsCategory.user | PhysicsCategory.boundary
        body.contactTestBitMask = 0
        body.fieldBitMask = 0
        body.usesPreciseCollisionDetection = false
        
        circle.physicsBody = body
        return circle
    }
    
    private func spawnPosition(for index: Int, footprintRadius: CGFloat) -> CGPoint {
        let goldenAngle: CGFloat = 2.399963
        let angle = CGFloat(index) * goldenAngle
        
        if mode == .maxCard && usesRectangularBoundary {
            let xRadius = max(0, rectangularBoundary.width / 2 - footprintRadius - 4)
            let yRadius = max(0, rectangularBoundary.height / 2 - footprintRadius - 4)
            
            return CGPoint(
                x: cos(angle) * xRadius * 0.9,
                y: sin(angle) * yRadius * 0.9
            )
        }
        
        let usableRadius = max(0, boundaryRadius - footprintRadius - 4)
        
        let preferredRadius = max(circleRadius * 2.4, boundaryRadius * 0.72)
        
        let radius = min(usableRadius, preferredRadius)
        
        return CGPoint(
            x: cos(angle) * radius,
            y: sin(angle) * radius
        )
    }
    
    private func updateCenteredUser(to newCenteredUserID: User.ID?) {
        let oldCenteredUserID = centeredUserID
        
        if let oldCenteredUserID, oldCenteredUserID != newCenteredUserID,
           let oldCircle = circlesByUserID[oldCenteredUserID], !oldCircle.isHidden {
            oldCircle.physicsBody?.isDynamic = true
            
            let oldIndex = snapshotUsers.firstIndex {
                $0.id == oldCenteredUserID
            } ?? 0
            
            let angle = CGFloat(oldIndex) * 2.399963
            
            let largestScale: CGFloat = mode == .honeycomb ? maximumFocusScale : 1
            
            let releaseRadius = min(max(0, boundaryRadius - oldCircle.collisionFootprintRadius * largestScale - 4), circleRadius * 2.25)
            
            oldCircle.position = CGPoint(
                x: cos(angle) * releaseRadius,
                y: sin(angle) * releaseRadius
            )
            
            if mode == .maxCard && usesRectangularBoundary {
                oldCircle.position = spawnPosition(for: oldIndex, footprintRadius: oldCircle.collisionFootprintRadius)
            }
            
            oldCircle.physicsBody?.velocity = CGVector(
                dx: cos(angle) * 35,
                dy: sin(angle) * 35
            )
        }
        
        centeredUserID = newCenteredUserID
        
        for (userID, circle) in circlesByUserID {
            guard !circle.isHidden else {
                circle.physicsBody?.isDynamic = false
                continue
            }
            
            let shouldBeCentered = userID == newCenteredUserID
            circle.physicsBody?.isDynamic = !shouldBeCentered
            
            if shouldBeCentered {
                circle.position = .zero
                circle.physicsBody?.velocity = .zero
                circle.physicsBody?.angularVelocity = 0
            } else {
                circle.physicsBody?.isResting = false
            }
        }
    }
    
    private func rebuildBoundary() {
        boundaryNode?.removeFromParent()
        
        guard
            size.width > 0,
            size.height > 0
        else {
            return
        }
        
        let radius = boundaryRadius
        
        let path: CGPath
        
        if mode == .maxCard && usesRectangularBoundary {
            path = CGPath(rect: rectangularBoundary, transform: nil)
        } else {
            path = CGPath(
                ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2),
                transform: nil
            )
        }
        
        let boundary = SKShapeNode(path: path)
        
        boundary.strokeColor = .clear
        boundary.fillColor = .clear
        boundary.lineWidth = 0
        boundary.zPosition = -1_000
        
        let body = SKPhysicsBody(edgeLoopFrom: path)
        
        body.categoryBitMask = PhysicsCategory.boundary
        body.collisionBitMask = PhysicsCategory.user
        body.contactTestBitMask = 0
        body.isDynamic = false

        boundary.physicsBody = body

        addChild(boundary)
        boundaryNode = boundary
    }
    
    private func wakeCluster() {
        guard !circlesByUserID.isEmpty else {
            attractionIsActive = false
            return
        }
        
        attractionIsActive = true
        attractionStartedAt = nil
        stableFrameCount = 0
        
        for (userID, circle) in circlesByUserID where userID != centeredUserID {
            
            circle.physicsBody?.isResting = false
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        let deltaTime: TimeInterval
        
        if let lastUpdateTime {
            deltaTime = min(max(currentTime - lastUpdateTime, 0), 0.05)
        } else {
            deltaTime = 0
        }
        
        lastUpdateTime = currentTime
        
        updateCameraInertia(deltaTime: deltaTime)
        
        refreshVisualFocus(immediately: false)
        
        updateAttraction(currentTime: currentTime)
    }
    
    private func updateAttraction(currentTime: TimeInterval) {
        guard attractionIsActive else {
            return
        }
        
        if attractionStartedAt == nil {
            attractionStartedAt = currentTime
        }
        
        var greatestSpeed: CGFloat = 0
        
        for (userID, circle) in circlesByUserID {
            guard
                userID != centeredUserID,
                let body = circle.physicsBody,
                body.isDynamic
            else {
                continue
            }
            
            body.applyForce(CGVector(
                dx: -circle.position.x * attractionStrength,
                dy: -circle.position.y * attractionStrength)
            )
            
            let currentSpeed = hypot(body.velocity.dx, body.velocity.dy)
            
            if currentSpeed > maximumSpeed {
                let factor = maximumSpeed / currentSpeed
                
                body.velocity = CGVector(
                    dx: body.velocity.dx * factor,
                    dy: body.velocity.dy * factor
                )
            }
            
            greatestSpeed = max(greatestSpeed, currentSpeed)
        }
        
        if greatestSpeed < restSpeedThreshold {
            stableFrameCount += 1
        } else {
            stableFrameCount = 0
        }
        
        let elapsedTime = currentTime - (attractionStartedAt ?? currentTime)
        
        if stableFrameCount >= requiredStableFrames || elapsedTime >= maximumSimulationDuration {
            stopCluster()
        }
    }
    
    private func stopCluster() {
        attractionIsActive = false
        attractionStartedAt = nil
        stableFrameCount = 0
        
        for (userID, circle) in circlesByUserID where userID != centeredUserID {
            
            circle.physicsBody?.velocity = .zero
            circle.physicsBody?.angularVelocity = 0
        }
    }
    
    private func updateCameraInertia(deltaTime: TimeInterval) {
        guard
            mode == .honeycomb,
            !isDraggingCamera,
            deltaTime > 0
        else {
            return
        }
        
        let speed = hypot(cameraVelocity.dx, cameraVelocity.dy)
        
        guard speed > 5 else {
            cameraVelocity = .zero
            return
        }
        
        clusterCamera.position.x += cameraVelocity.dx * CGFloat(deltaTime)
        clusterCamera.position.y += cameraVelocity.dy * CGFloat(deltaTime)
        
        clampCameraPosition()
        
        let damping = CGFloat(pow(0.055, deltaTime))
        
        cameraVelocity = CGVector(dx: cameraVelocity.dx * damping, dy: cameraVelocity.dy * damping)
    }
    
    private func clampCameraPosition() {
        guard mode == .honeycomb else {
            clusterCamera.position = .zero
            return
        }
        
        let distance = hypot(clusterCamera.position.x, clusterCamera.position.y)
        
        let limit = maximumCameraOffset
        
        guard
            distance > limit,
            distance > 0
        else {
            return
        }
        
        let factor = limit / distance
        
        clusterCamera.position = CGPoint(
            x: clusterCamera.position.x * factor,
            y: clusterCamera.position.y * factor
        )
    }
    
    func resetCamera() {
        cameraVelocity = .zero
        clusterCamera.position = .zero
        refreshVisualFocus(immediately: true)
    }
    
    private func refreshVisualFocus(immediately: Bool) {
        let visibleCircles = circlesByUserID.filter {
            !$0.value.isHidden
        }
        
        guard !visibleCircles.isEmpty else {
            updateVisualCenteredUserID(nil)
            return
        }
        
        let focusPoint = mode == .honeycomb ? clusterCamera.position : CGPoint.zero
        
        let nearestUserID = visibleCircles.min { first, second in
            squaredDistance(first.value.position, focusPoint) < squaredDistance(second.value.position, focusPoint)
        }?.key
        
        updateVisualCenteredUserID(nearestUserID)
        
        for circle in visibleCircles.values {
            let distance = hypot(circle.position.x - focusPoint.x, circle.position.y - focusPoint.y)
            
            let targetScale: CGFloat
            
            if mode == .honeycomb {
                let progress = min(max(distance / focusFallofDistance, 0), 1)
                
                targetScale = maximumFocusScale - (maximumFocusScale - minimumFocusScale) * progress
            } else {
                targetScale = 1
            }
            
            circle.setVisualScale(targetScale, immediately: immediately)
            circle.zPosition = 500 - distance
        }
    }
    
    private func updateVisualCenteredUserID(_ newValue: User.ID?) {
        guard visualCenteredUserID != newValue else {
            return
        }
        
        visualCenteredUserID = newValue
        
        onVisualCenterUserChanged?(newValue)
    }
    
    private func squaredDistance(_ first: CGPoint, _ second: CGPoint) -> CGFloat {
        let dx = first.x - second.x
        let dy = first.y - second.y
        
        return dx * dx + dy * dy
    }
    
    private func physicsUserNode(at point: CGPoint) -> PhysicsUserNode? {
        var currentNode: SKNode? = atPoint(point)
        
        while let node = currentNode {
            if let userNode = node as? PhysicsUserNode, !userNode.isHidden {
                return userNode
            }
            
            currentNode = node.parent
        }
        
        return nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        touchedUserID = physicsUserNode(at: touch.location(in: self))?.userID
        cancelPendingLongPress()
        didTriggerLongPress = false
        
        if let view {
            lastTouchPointInView = touch.location(in: view)
        }
        
        lastTouchTimestamp = touch.timestamp
        
        accumulatedTouchDistance = 0
        isDraggingCamera = false
        cameraVelocity = .zero
        
        if let touchedUserID {
            scheduleLongPress(for: touchedUserID)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !didTriggerLongPress else { return }
        
        guard
            let touch = touches.first,
            let view,
            let previousPoint = lastTouchPointInView
        else {
            return
        }
        
        let currentPoint = touch.location(in: view)
        let deltaX = currentPoint.x - previousPoint.x
        let deltaY = currentPoint.y - previousPoint.y
        let movement = hypot(deltaX, deltaY)
        
        accumulatedTouchDistance += movement
        
        if accumulatedTouchDistance >= dragActivationDistance {
            cancelPendingLongPress()
        }
        
        lastTouchPointInView = currentPoint
        
        let previousTimestamp = lastTouchTimestamp ?? touch.timestamp
        let elapsed = max(touch.timestamp - previousTimestamp, 1.0 / 120.0)
        
        lastTouchTimestamp = touch.timestamp
        
        guard mode == .honeycomb else {
            return
        }
        
        if accumulatedTouchDistance >= dragActivationDistance {
            isDraggingCamera = true
        }
        
        guard isDraggingCamera else {
            return
        }
        
        let cameraDeltaX = -deltaX
        let cameraDeltaY = deltaY
        
        clusterCamera.position.x += cameraDeltaX
        clusterCamera.position.y += cameraDeltaY
        
        clampCameraPosition()
        
        cameraVelocity = CGVector(
            dx: cameraDeltaX / CGFloat(elapsed),
            dy: cameraDeltaY / CGFloat(elapsed)
        )
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            clearTouchState()
        }
        
        guard
            !didTriggerLongPress,
            !isDraggingCamera,
            accumulatedTouchDistance < dragActivationDistance,
            let touch = touches.first
        else {
            return
        }
        
        guard let touchedUserID else {
            onTapBackground?()
            return
        }
        
        let endNode = physicsUserNode(at: touch.location(in: self))
        
        guard endNode?.userID == touchedUserID else {
            return
        }
        
        if let onTapSelection,
           let selection = selection(for: touchedUserID) {
            if onTapSelection(selection) {
                setCirclesHidden(true, for: [touchedUserID])
            }
        } else {
            onTapUser?(touchedUserID)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        cameraVelocity = .zero
        clearTouchState()
    }
    
    private func clearTouchState() {
        cancelPendingLongPress()
        didTriggerLongPress = false
        touchedUserID = nil
        lastTouchPointInView = nil
        lastTouchTimestamp = nil
        accumulatedTouchDistance = 0
        isDraggingCamera = false
    }
    
    func selection(for userID: User.ID) -> PhysicsUserSelection? {
        guard
            view != nil,
            let circle = circlesByUserID[userID],
            !circle.isHidden
        else {
            return nil
        }
        
        let center = convertPoint(toView: circle.convert(.zero, to: self))
        
        let edge = convertPoint(toView: circle.convert(CGPoint(x: circleRadius, y: 0), to: self))
        
        return PhysicsUserSelection(userID: userID, centerInView: center, diameter: 2 * hypot(edge.x - center.x, edge.y - center.y))
    }
    
    func flightSelections(for userIDs: Set<User.ID>) -> [PhysicsUserSelection] {
        snapshotUsers.compactMap { user in
            userIDs.contains(user.id) ? selection(for: user.id) : nil
        }
    }
    
    func setCirclesHidden(_ hidden: Bool, for userIDs: Set<User.ID>) {
        if hidden {
            hiddenUserIDs.formUnion(userIDs)
        } else {
            hiddenUserIDs.subtract(userIDs)
        }
        
        reconcileSnapshot()
    }
    
    func removeCirclesImmediately(for userIDs: Set<User.ID>) {
        snapshotUsers.removeAll {
            userIDs.contains($0.id)
        }
        
        hiddenUserIDs.subtract(userIDs)
        reconcileSnapshot()
    }
    
    func cancelInteractions() {
        clearTouchState()
        cameraVelocity = .zero
        lastUpdateTime = nil
    }
    
    private func canLongPress(_ userID: User.ID) -> Bool {
        guard
            let circle = circlesByUserID[userID],
            !circle.isHidden
        else {
            return false
        }
        
        if mode == .maxCard || onLongPressUser != nil {
            return true
        }
        
        let nearest = circlesByUserID
            .filter { !$0.value.isHidden }
            .min {
                squaredDistance($0.value.position, clusterCamera.position) < squaredDistance($1.value.position, clusterCamera.position)
            }?.key
        
        return nearest == userID
    }
    
    private func scheduleLongPress(for userID: User.ID) {
        guard onLongPressUsers != nil || onLongPressUser != nil, canLongPress(userID) else {
            return
        }
        
        longPressHaptics.start(duration: longPressDuration, isHoneycomb: mode == .honeycomb)
        
        run(.sequence([
            .wait(forDuration: longPressDuration),
            .run { [weak self] in
                guard
                    let self,
                    self.touchedUserID == userID,
                    self.accumulatedTouchDistance < self.dragActivationDistance,
                    self.canLongPress(userID)
                else {
                    self?.cancelPendingLongPress()
                    return
                }
                
                if let onLongPressUser = self.onLongPressUser {
                    self.didTriggerLongPress = true
                    self.cameraVelocity = .zero
                    self.longPressHaptics.complete()
                    onLongPressUser(userID)
                    return
                }
                
                let userIDs = self.snapshotUsers
                    .filter {
                        !self.hiddenUserIDs.contains($0.id)
                    }
                    .map(\.id)
                
                guard !userIDs.isEmpty else { return }
                
                self.didTriggerLongPress = true
                self.cameraVelocity = .zero
                self.longPressHaptics.complete()
                
                self.onLongPressUsers?(userIDs)
            }
        ]), withKey: longPressActionKey)
    }
    
    private func cancelPendingLongPress() {
        removeAction(forKey: longPressActionKey)
        longPressHaptics.cancel()
    }
}
