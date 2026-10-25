//
//  SelectedDraggableCircle.swift
//  EventsApp
//
//  Created by Camila Parolin on 31/08/26.
//

import SwiftUI

//representa um círculo que já foi colocado dentro do card
struct SelectedDraggableCircle: View {
    
    @Environment(\.splitLayoutScale)
    private var layoutScale
    
    let user: User
    let index: Int
    let totalCount: Int
    let animation: Namespace.ID
    let onTap: () -> Void
    
    let longPressDuration: TimeInterval
    let onPressingChanged: (Bool) -> Void
    let onLongPress: () -> Void
    
    @State private var didCompleteLongPress = false
    
    private var circleSize: CGFloat {
        ClusterLayout.circleSize * layoutScale
    }
    
    private var nameWidth: CGFloat {
        ClusterLayout.horizontalSpacing * layoutScale
    }
    
    var body: some View {
        VStack(spacing: 2 * layoutScale) {
            ZStack {
                Circle()
                    .fill(user.color)
                
                Text(user.emoji)
                    .font(.system(size: circleSize * 0.5))
            }
            .frame(width: circleSize, height: circleSize)
            .contentShape(Circle())
            .matchedGeometryEffect(id: user.id, in: animation)
            .onLongPressGesture(
                minimumDuration: longPressDuration,
                maximumDistance: 10,
                perform: {
                    didCompleteLongPress = true
                    onLongPress()
            },
                onPressingChanged: { isPressing in
                    if isPressing {
                        didCompleteLongPress = false
                    }
                    
                    onPressingChanged(isPressing)
                }
            )
            .highPriorityGesture(
                TapGesture().onEnded {
                    guard !didCompleteLongPress else {
                        didCompleteLongPress = false
                        return
                    }
                    
                    onTap()
                }
            )
            
            Text(user.name)
                .font(.system(size: 9 * layoutScale, weight: .regular))
                .foregroundStyle(Color("gray89"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: nameWidth)
            
        }
        .alignmentGuide(VerticalAlignment.center) { _ in
            circleSize / 2
        }
        .transition(.scale.combined(with: .opacity))
        .offset(ClusterLayout.offset(for: index, count: totalCount, scale: layoutScale))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(user.accessibilityName)
        .accessibilityHint("Toque duas vezes para tirar esta pessoa do item.")
        .accessibilityAddTraits(.isButton)
        // Ações diretas: não dependem do toque simulado cair no círculo.
        .accessibilityAction {
            onTap()
            AccessibilityAnnouncer.announce(String(localized: "\(user.name) saiu do item"))
        }
        .accessibilityAction(named: "Remover todas as pessoas do item") {
            onLongPress()
            AccessibilityAnnouncer.announce(String(localized: "Todas as pessoas saíram do item"))
        }
    }
}
