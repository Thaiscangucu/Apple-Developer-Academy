//
//  NotificationModel.swift
//  LocalNotificationDemo
//
//  Created by Diego Saragoza Da Silva on 24/06/25.
//

import Foundation
import SwiftUI

/// A model that abstracts a local notification
struct NotificationModel {
    public var id: UUID = UUID()
    public var title: String
    public var subtitle: String
    public var body: String
    
    init(title: String, subtitle: String, body: String) {
        self.title = title
        self.subtitle = subtitle
        self.body = body
    }
}
