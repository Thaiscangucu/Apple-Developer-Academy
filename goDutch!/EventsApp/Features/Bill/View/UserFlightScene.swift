//
//  UserFlightScene.swift
//  EventsApp
//
//  Created by Camila Parolin on 18/09/26.
//

import SpriteKit
import Foundation

final class UserFlightScene: SKScene {
    
    private var activeIndividualFlightNodes: [UUID: SKNode] = [:]
    private var exclusiveIndividualFlightID: UUID?
    private var groupFlightNode: SKNode?
    
    private var nextIndividualFlightZPosition: CGFloat = 1_000
    
    var isFlying: Bool {
        groupFlightNode != nil || !activeIndividualFlightNodes.isEmpty
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        backgroundColor = .clear
        anchorPoint = .zero
        isPaused = false
        speed = 1
        
        view.backgroundColor = .clear
        view.isOpaque = false
        view.allowsTransparency = true
        view.isPaused = false
        view.preferredFramesPerSecond = 60
        
        print("UserFlightScene conectada. Tamanho: ", size)
    }
    
    @discardableResult
    func fly(user: User,
             from startInView: CGPoint,
             to endInView: CGPoint,
             viewportSize: CGSize,
             sourceDiameter: CGFloat,
             targetDiameter: CGFloat,
             duration: TimeInterval = 0.70,
             allowsConcurrentFlights: Bool = false,
             onArrival: @escaping () -> Void,
             onFinished: @escaping () -> Void
    ) -> Bool {
        guard
            groupFlightNode == nil,
            exclusiveIndividualFlightID == nil,
            allowsConcurrentFlights || activeIndividualFlightNodes.isEmpty,
            viewportSize.width > 0,
            viewportSize.height > 0,
            duration > 0
        else {
            print("Voo bloqueado: ", "isFlying = ", isFlying, "viewport = ", viewportSize, "duration = ", duration)
            return false
        }
        
        isPaused = false
        speed = 1
        view?.isPaused = false
        size = viewportSize
        
        let safeSourceDiameter = max(sourceDiameter, 1)
        let safeTargetDiameter = max(targetDiameter, 1)
        
        let start = CGPoint(x: startInView.x, y: viewportSize.height - startInView.y)
        
        let end = CGPoint(x: endInView.x, y: viewportSize.height - endInView.y)
        
        let horizontalBend: CGFloat = start.x <= end.x ? -36 : 36
        
        let controlPoint = CGPoint(x: ((start.x + end.x) / 2) + horizontalBend, y: ((start.y + end.y) / 2) + 40)
        
        let flightID = UUID()
        
        let flightNode = CircleNode(radius: safeSourceDiameter / 2, user: user)
        
        flightNode.alpha = 1
        flightNode.isHidden = false
        flightNode.position = start
        
        if activeIndividualFlightNodes.isEmpty {
            nextIndividualFlightZPosition = 1_000
        }
        
        flightNode.zPosition = nextIndividualFlightZPosition
        nextIndividualFlightZPosition += 1
        
        addChild(flightNode)
        
        activeIndividualFlightNodes[flightID] = flightNode
        
        if !allowsConcurrentFlights {
            exclusiveIndividualFlightID = flightID
        }
        
        let targetScale = safeTargetDiameter / safeSourceDiameter
        let durationAsCGFloat = CGFloat(duration)
        
        let flightAction = SKAction.customAction(withDuration: duration) { animatedNode, elapsedTime in
            let linearProgress = min(max(elapsedTime / durationAsCGFloat, 0), 1)
            
            let progress = linearProgress * linearProgress * (3 - (2 * linearProgress))
            
            let inverseProgress = 1 - progress
            
            let currentX = inverseProgress * inverseProgress * start.x + 2 * inverseProgress * progress * controlPoint.x + progress * progress * end.x
            let currentY = inverseProgress * inverseProgress * start.y + 2 * inverseProgress * progress * controlPoint.y + progress * progress * end.y
            
            animatedNode.position = CGPoint(x: currentX, y: currentY)
            
            let currentScale = 1 + ((targetScale - 1) * progress)
            animatedNode.setScale(currentScale)
        }
        
        flightNode.run(flightAction) { [weak self, weak flightNode] in
            guard let flightNode else {
                self?.finishIndividualFlight(id: flightID, node: nil)
                onFinished()
                return
            }
            
            flightNode.position = end
            flightNode.setScale(targetScale)
            
            onArrival()
            
            let landingAction = SKAction.sequence([.wait(forDuration: 0.04), .fadeOut(withDuration: 0.10)])
            
            flightNode.run(landingAction) { [weak self, weak flightNode] in
                self?.finishIndividualFlight(id: flightID, node: flightNode)
                
                onFinished()
            }
        }
        
        return true
    }
    
    private func finishIndividualFlight(id flightID: UUID, node: SKNode?) {
        let storedNode = activeIndividualFlightNodes.removeValue(forKey: flightID)
        
        (node ?? storedNode)?.removeFromParent()
        
        if exclusiveIndividualFlightID == flightID {
            exclusiveIndividualFlightID = nil
        }
        
        if activeIndividualFlightNodes.isEmpty {
            nextIndividualFlightZPosition = 1_000
        }
    }
    
    @discardableResult
    func flyGroup(
        items: [UserGroupFlightItem],
        to endInView: CGPoint,
        viewportSize: CGSize,
        targetScale: CGFloat = 0.55,
        duration: TimeInterval = 0.25,
        onArrival: @escaping () -> Void,
        onFinished: @escaping () -> Void
    ) -> Bool {
        guard
            !isFlying,
            !items.isEmpty,
            viewportSize.width > 0,
            viewportSize.height > 0,
            duration > 0
        else {
            return false
        }
        
        isPaused = false
        speed = 1
        view?.isPaused = false
        size = viewportSize
        
        let convertedItems = items.map { item in
            (
                item: item,
                center: CGPoint(x: item.centerInView.x, y: viewportSize.height - item.centerInView.y)
            )
        }
        
        let minX = convertedItems.map {
            $0.center.x - (max($0.item.diameter, 1) / 2)
        }.min() ?? 0
        
        let maxX = convertedItems.map {
            $0.center.x + (max($0.item.diameter, 1) / 2)
        }.max() ?? 0
        
        let minY = convertedItems.map {
            $0.center.y - (max($0.item.diameter, 1) / 2)
        }.min() ?? 0
        
        let maxY = convertedItems.map {
            $0.center.y + (max($0.item.diameter, 1) / 2)
        }.max() ?? 0
        
        let start = CGPoint(x: (minX + maxX) / 2, y: (minY + maxY) / 2)
        
        let end = CGPoint(x: endInView.x, y: viewportSize.height - endInView.y)
        
        let groupNode = SKNode()
        
        groupNode.position = start
        groupNode.zPosition = 1_000
        
        let orderedItems = convertedItems.sorted {
            $0.item.diameter < $1.item.diameter
        }
        
        for (index, convertedItem) in orderedItems.enumerated() {
            let diameter = max(convertedItem.item.diameter, 1)
            
            let circle = CircleNode(radius: diameter / 2, user: convertedItem.item.user)
            
            circle.position = CGPoint(x: convertedItem.center.x - start.x, y: convertedItem.center.y - start.y)
            
            circle.zPosition = CGFloat(index)
            
            groupNode.addChild(circle)
        }
        
        addChild(groupNode)
        
        groupFlightNode = groupNode
        
        let safeTargetScale = max(targetScale, 0.01)
        let horizontalBend: CGFloat = start.x <= end.x ? -36 : 36
        
        let controlPoint = CGPoint(x: ((start.x + end.x) / 2) + horizontalBend, y: ((start.y + end.y) / 2) + 40)
        
        let durationAsCGFloat = CGFloat(duration)
        
        let flightAction = SKAction.customAction(withDuration: duration) { animatedNode, elapsedTime in
            let linearProgress = min(max(elapsedTime / durationAsCGFloat, 0), 1)
            
            let progress = linearProgress * linearProgress * (3 - (2 * linearProgress))
            
            let inverseProgress = 1 - progress
            
            let currentX = inverseProgress * inverseProgress * start.x +
            2 * inverseProgress * progress * controlPoint.x +
            progress * progress * end.x
            
            let currentY = inverseProgress * inverseProgress * start.y +
            2 * inverseProgress * progress * controlPoint.y +
            progress * progress * end.y
            
            animatedNode.position = CGPoint(x: currentX, y: currentY)
            
            let currentScale = 1 + ((safeTargetScale - 1) * progress)
            
            animatedNode.setScale(currentScale)
        }
        
        groupNode.run(flightAction) { [weak self, weak groupNode] in
            guard let groupNode else {
                self?.groupFlightNode = nil
                onFinished()
                return
            }
            
            groupNode.position = end
            groupNode.setScale(safeTargetScale)
            
            onArrival()
            
            let landingAction = SKAction.sequence([
                .wait(forDuration: 0.04),
                .fadeOut(withDuration: 0.10)
            ])
            
            groupNode.run(landingAction) { [weak self, weak groupNode] in
                groupNode?.removeFromParent()
                
                self?.groupFlightNode = nil
                
                onFinished()
            }
        }
        
        return true
    }
}
