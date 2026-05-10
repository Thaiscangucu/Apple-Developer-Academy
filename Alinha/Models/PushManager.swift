//
//  PushManager.swift
//  Front
//
//  Created by João Vitor Rocha Miranda on 04/09/25.
//

import SwiftUI
import UserNotifications
import Combine

final class PushManager: NSObject, ObservableObject {
    static let shared = PushManager()

    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var deviceTokenHex: String?  //Enviado no post appointment

    // MARK: Pedir autorização
    func requestAuthorizationAndRegister() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
            }
        }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, err in
            if let err { print("Notif auth error:", err) }
            DispatchQueue.main.async {
                UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.authorizationStatus = settings.authorizationStatus
                    }
                }
            }
            guard granted else { return }
            // Registrar no APNs
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}


