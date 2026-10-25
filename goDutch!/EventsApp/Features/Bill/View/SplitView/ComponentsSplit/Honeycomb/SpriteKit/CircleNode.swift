//
//  CircleNode.swift
//  EventsApp
//
//  Created by Camila Parolin on 31/08/26.
//

import SpriteKit
import SwiftUI
import UIKit

// essa tela já tem algumas partes levando em consideração um emoji do círculo

//representa visualmente cada círculo dentro do SpriteKit
final class CircleNode: SKShapeNode {
    let userID: User.ID
    
    private var iconLabel: SKLabelNode?
    private var userNameLabel: SKLabelNode?
    
    init(radius: CGFloat, user: User) {
        self.userID = user.id
        
        super.init()

        path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        fillColor = UIColor(user.color)
        strokeColor = .clear
        lineWidth = 0
        glowWidth = 0
        name = "circleNode"
        
        configureEmoji(user.emoji, radius: radius)
        
        configureName(user.name, radius: radius)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) não implementado")
    }
    
    private func configureEmoji(_ emoji: String, radius: CGFloat) {
        let label = SKLabelNode(text: emoji)
        
        label.fontSize = radius * 1.1
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = .zero
        label.zPosition = 1
        label.name = "emojiLabel"
        
        iconLabel = label
        addChild(label)
    }
    
    private func configureName(_ userName: String, radius: CGFloat) {
        let label = SKLabelNode()
        let sfProFont = UIFont.systemFont(ofSize: radius * 0.375, weight: .regular)
        let nameColor = UIColor(named: "gray89") ?? UIColor.black
        
        label.attributedText = NSAttributedString(string: userName, attributes: [.font: sfProFont, .foregroundColor: nameColor])
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .top
        label.position = CGPoint(x: 0, y: -radius - (radius * 0.10))
        label.zPosition = 2
        label.name = "userNameLabel"
        
        userNameLabel = label
        addChild(label)
    }
    
    /// Atualiza cor, emoji e nome quando o participante é editado,
    /// sem recriar o círculo (mantém posição e animações).
    func update(with user: User) {
        fillColor = UIColor(user.color)
        iconLabel?.text = user.emoji

        if let userNameLabel, let current = userNameLabel.attributedText, current.length > 0 {
            let attributes = current.attributes(at: 0, effectiveRange: nil)
            userNameLabel.attributedText = NSAttributedString(string: user.name, attributes: attributes)
        }
    }

    //altera a escala e a transparência do círculo conforme sua distância do centro
    func applyFocusEffect(scale: CGFloat) {
        setScale(scale)
    }
}
