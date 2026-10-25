//
//  MaxCard.swift
//  EventsApp
//
//  Created by Camila Parolin on 31/08/26.
//

import SwiftUI
import UIKit
import CoreHaptics

//view do card quando "expandido"
struct MaxCard: View {
    
    @Environment(\.splitLayoutScale)
    private var layoutScale
    
    @Environment(\.splitCardWidth)
    private var responsiveCardWidth
    
    let product: Product
    let productNumber: Int
    let users: [User]
    
    let centeredUserID: User.ID?
    let returningUserID: User.ID?
    let returningAllUserIDs: Set<User.ID>
    
    var physicsScene: UserPhysicsClusterScene? = nil
    
    let animation: Namespace.ID
    let onRemoveUser: (CardUserSelection) -> Void
    let onRemoveAllUsers: () -> Void
    var onTapCard: () -> Void = {}
    
    @State private var localPhysicsScene = UserPhysicsClusterScene()

    private let minimumCardHeight: CGFloat = 214
    private let cardCornerRadius: CGFloat = 33
    private let cardHorizontalPadding: CGFloat = 19
    
    private var responsiveLiquidGlassWidth: CGFloat {
        responsiveCardWidth - scaled(cardHorizontalPadding) * 2
    }
    
    private var total: Double {
        product.price * Double(product.quantity)
    }
    
    private var displayedUsers: [User] {
        Array(
            users.filter {
                product.assignedUserIDs.contains($0.id)
            }
                .prefix(CirclePatternLayout.maximumCount)
        )
    }
    
    private var hiddenUserIDs: Set<User.ID> {
        var ids = returningAllUserIDs
        
        if let returningUserID {
            ids.insert(returningUserID)
        }
        
        return ids
    }
    
    private func scaled(_ value: CGFloat) -> CGFloat {
        value * layoutScale
    }
    
    var body: some View {
        VStack(spacing: scaled(8)) {
            HStack {
                Text(String(format: "%02d.", productNumber))
                    .font(Font.custom("Montserrat Alternates", size: scaled(15)) .weight(.bold))
                 
                 Text(product.name)
                    .font(Font.custom("Montserrat Alternates", size: scaled(15)) .weight(.medium))
                .lineLimit(1)
                
                Spacer()
            }
            .foregroundColor(Color("itemPrimaryCardColor"))
            .contentShape(Rectangle())
            .onTapGesture { onTapCard() }
            // Já faz parte do resumo do item logo abaixo.
            .accessibilityHidden(true)
            
            HStack {
                Text("\(product.quantity) Un.  x  \(product.price, format: CurrencyHelper.formatStyle)")
                    .font(Font.custom("Montserrat Alternates", size: scaled(14)) .weight(.medium))
        
                Spacer()
                
                Text(total, format: CurrencyHelper.formatStyle)
                    .font(Font.custom("Montserrat Alternates", size: scaled(16)) .weight(.bold))
            }
            .foregroundColor(Color("itemPrimaryCardColor"))
            .padding(.bottom, 10)
            .contentShape(Rectangle())
            .onTapGesture { onTapCard() }
            // VoiceOver: nome, quantidade e valores lidos juntos, como
            // título do item que está sendo dividido.
            .accessibilityRepresentation {
                Button(product.accessibilitySummary(number: productNumber)) {
                    onTapCard()
                }
                .accessibilityAddTraits([.isHeader, .isSelected])
                .accessibilityHint("Item aberto. Toque duas vezes para fechar.")
            }
            
            ZStack {
                SplitPhysicsClusterView(
                    users: displayedUsers,
                    centeredUserID: centeredUserID,
                    hiddenUserIDs: hiddenUserIDs,
                    mode: .maxCard,
                    circleRadius: scaled(ClusterLayout.circleSize / 2),
                    scene: physicsScene ?? localPhysicsScene,
                    onTapSelect: { selection in
                        guard let index = displayedUsers.firstIndex(where: { $0.id == selection.userID }) else {
                            return false
                        }
                        
                        onRemoveUser(CardUserSelection(userID: selection.userID, index: index, totalCount: displayedUsers.count))
                        return false
                    },
                    onLongPressUsers: { _ in onRemoveAllUsers() },
                    voiceOverRole: .itemMembers,
                    onTapBackground: onTapCard
                ) {
                    LiquidGlassRectangle(width: responsiveLiquidGlassWidth, height: ClusterLayout.clusterHeight)
                }

                if displayedUsers.isEmpty {
                    VStack (spacing: 8){
                        Text("**Clique** nos usuários deste item")
                            .font(Font.custom("Montserrat Alternates", size: scaled(14)) .weight(.light))
                            .foregroundColor(Color("itemSecondaryCardColor"))
                        
                        Image(systemName: "hand.tap")
                            .font(Font.custom("Montserrat Alternates", size: scaled(19)) .weight(.regular))
                            .foregroundStyle(Color("AccentColor"))
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { onTapCard() }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Ninguém neste item ainda. Escolha as pessoas na lista de pessoas disponíveis.")
                    
                }
            }
            .frame(width: responsiveLiquidGlassWidth, height: scaled(ClusterLayout.clusterHeight))
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(key: CardClusterFramePreferenceKey.self, value: proxy.frame(in: .named(SplitFlightCoordinateSpace.name)))
                }
            }
        }
        .padding(.horizontal, scaled(cardHorizontalPadding))
        .padding(.vertical, scaled(16))
        .frame(width: responsiveCardWidth)
        .frame(minHeight: scaled(minimumCardHeight))
        .background {
            RoundedRectangle(cornerRadius: scaled(cardCornerRadius), style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.14), radius: scaled(10), x: 0, y: scaled(6))
                .onTapGesture {
                    onTapCard()
                }
        }
    }
}

@MainActor
final class UserClusterHapticController {
    private var hapticEngine: CHHapticEngine?
    private var progressPlayer: (any CHHapticPatternPlayer)?
    
    private let completionGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private func prepareEngine() {
        guard CHHapticEngine
            .capabilitiesForHardware()
            .supportsHaptics else {
            return
        }
        
        do {
            if hapticEngine == nil {
                let engine = try CHHapticEngine()
                
                engine.isAutoShutdownEnabled = true
                
                engine.stoppedHandler = { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.progressPlayer = nil
                    }
                }
                
                engine.resetHandler = { [weak self] in
                    DispatchQueue.main.async {
                        guard let self = self else {
                            return
                        }
                        
                        self.progressPlayer = nil
                        try? self.hapticEngine?.start()
                    }
                }
                
                hapticEngine = engine
            }
            
            try hapticEngine?.start()
        } catch {
            hapticEngine = nil
            progressPlayer = nil
        }
    }
    
    func start(duration: TimeInterval, isHoneycomb: Bool = false) {
        cancel()
        
        guard AppSettings.isAnimationsOn else {
            return
        }
        
        prepareEngine()
        completionGenerator.prepare()
        
        guard let hapticEngine = hapticEngine else {
            return
        }
        
        let continuousEvent = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.12)
            ],
            relativeTime: 0,
            duration: duration
        )
        
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                .init(relativeTime: 0, value: 0.03),
                .init(relativeTime: duration * 0.45, value: isHoneycomb ? 0.15 : 0.07),
                .init(relativeTime: duration * 0.68, value: isHoneycomb ? 0.32 : 0.15),
                .init(relativeTime: duration * 0.82, value: isHoneycomb ? 0.58 : 0.32),
                .init(relativeTime: duration * 0.93, value: isHoneycomb ? 0.85 : 0.58),
                .init(relativeTime: duration, value: 0.85),
            ],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [continuousEvent], parameterCurves: [intensityCurve])
            let player = try hapticEngine.makePlayer(with: pattern)
            
            progressPlayer = player
            
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            progressPlayer = nil
        }
    }
    
    func cancel() {
        try? progressPlayer?.stop(atTime: CHHapticTimeImmediate)
        
        progressPlayer = nil
    }
    
    func complete() {
        cancel()
        
        guard AppSettings.isAnimationsOn else {
            return
        }
        
        completionGenerator.impactOccurred()
    }
}


