//
//  SettingsView.swift
//  EventsApp
//
//  Created by Thais Cangucu on 23/09/26.
//

import SwiftUI

struct SettingsView: View {
    @Binding var notifications: Bool
    @Binding var animation: Bool
    var body: some View {
        VStack(alignment: .leading){
            Text("Notificações")
                .font(.app(.callout))
                .foregroundColor(Color(red: 0.36, green: 0.36, blue: 0.36))
                // O próprio toggle já anuncia o nome do ajuste.
                .accessibilityHidden(true)
            
            OnOffToggle(isOn: $notifications, accessibilityTitle: "Notificações")
                .padding(.bottom, 37)
            
            Text("Animações & Haptics")
                .font(.app(.callout))
                .foregroundColor(Color(red: 0.36, green: 0.36, blue: 0.36))
                .accessibilityHidden(true)
            
            OnOffToggle(isOn: $animation, accessibilityTitle: "Animações & Haptics")
            
        }
        .containerRelativeFrame(.horizontal) { width, _ in
            width * 0.85
        }
        .adaptiveRelativeHeight(0.40, accessibilityPadding: 28)
        .adaptiveGlass(in: .rect(cornerRadius: 38))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Ajustes")

    }
}
