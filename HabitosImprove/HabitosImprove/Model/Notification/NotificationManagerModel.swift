//
//  NotificationManagerModel.swift
//  LocalNotificationDemo
//
//  Created by Diego Saragoza Da Silva on 25/06/25.
//

import Foundation
import SwiftUI

/// A model that abstracts a manager to send and schedule notifications.
struct NotificationManagerModel {
    public static var shared: NotificationManagerModel = {
        let instance = NotificationManagerModel()
        
        return instance
    }()
    
    private init() {}
    
    private static var coreDataViewModel: CoreDataViewModel = CoreDataViewModel()

    
    /// Request all the necessary permissions to ensure that local notifications will work.
    public static func requirePermissions() {
        // Ask permission to send alerts, use badges and play sounds.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { status, error in
            if !status, let error = error {
                fatalError("[ERROR]: Unable to request permissions for notifications (\(error.localizedDescription))")
            }
        }
    }
    
    /// Send a non-repeating local notification. Wait waitTime before sending the notification.
    /// - Parameters:
    ///     - notification: A notification model representing the local notification.
    ///     - waitTime: The time to wait before sending the notification. The default is 1.0 seconds.
    public static func sendNotification(notification: NotificationModel, waitTime: Double = 1.0) {
        // Notification content creation
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.subtitle = notification.subtitle
        content.body = notification.body
        content.sound = UNNotificationSound.default

        // Notification time trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: waitTime, repeats: false)

        // Notification send request
        let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    /// Schedule a local notification to be sent at a specific time (hour:minute), with the option to repeat it every day at this time.
    /// - Parameters:
    ///     - notification: A notification model representing the local notification.
    ///     - hour: The hour to send the notification.
    ///     - minute: The minute to send the notification.
    ///     - repeating: If true, repeat this notification every day at the same time (hour:minute), if not, send only once. The default is false.
    public static func scheduleNotification(notification: NotificationModel, hour: Int, minute: Int, repeating: Bool = false) {
        // Notification content creation
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.subtitle = notification.subtitle
        content.body = notification.body
        content.sound = UNNotificationSound.default

        // Notification calendar trigger with date components
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeating)

        // Notification send request
        let request = UNNotificationRequest(identifier: notification.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
        // Create a scheduled notification entry using core data to retrieve it later
        if repeating {
            let date: Date = Calendar.current.date(from: dateComponents) ?? .now
            coreDataViewModel.createScheduledNotification(id: notification.id, date: date)
        }
    }
    
    /// Schedule a local notification to be sent at a specific time (hour:minute), with the option to repeat it after some interval.
    /// The scheduling is calculated to fit the maximum amount of notifications in a month with the specified interval.
    /// - Parameters:
    ///     - notification: A notification model representing the local notification.
    ///     - hour: The hour to send the notification.
    ///     - minute: The minute to send the notification.
    ///     - interval: The interval, in seconds, to space the notifications.
    public static func scheduleRepeatingNotification(notification: NotificationModel, hour: Int, minute: Int, interval: Double) {
        // Notification content creation
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.subtitle = notification.subtitle
        content.body = notification.body
        content.sound = UNNotificationSound.default
        
        // Today date components
        let today: Date = Date.now
        let todayComponents: DateComponents = Calendar.current.dateComponents([.day, .month, .year], from: today)
        
        // Calculate the amount of notifications that can fit in a month
        let monthSeconds: Int = 2628000
        let notificationAmount: Int = monthSeconds / Int(interval)
        
        // Generate all the notifications
        var currentDateComponents: DateComponents = todayComponents
        currentDateComponents.hour = hour
        currentDateComponents.minute = minute
        var currentDate: Date = Calendar.current.date(from: currentDateComponents) ?? .now
        for _ in 0..<notificationAmount {
            // Notification calendar trigger with date components
            let trigger = UNCalendarNotificationTrigger(dateMatching: currentDateComponents, repeats: false)
            
            // Notification send request
            let uuid: UUID = UUID()
            let request = UNNotificationRequest(identifier: uuid.uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
    
            // Create a scheduled notification entry using core data to retrieve it later
            coreDataViewModel.createScheduledNotification(id: uuid, date: currentDate)
            
            // Shift current date by the interval
            currentDate = currentDate.advanced(by: interval)
            currentDateComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: currentDate)
        }

    }
    
    /// Cancel a scheduled notification, canceling it from the notification center and removing it from core data.
    /// - Parameters:
    ///     - scheduledNotification: A ScheduledNotification to be canceled and removed.
    public static func cancelScheduledNotification(scheduledNotification: ScheduledNotification) {
        // Cancel the notification using its id
        if let id = scheduledNotification.id?.uuidString {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        }
        
        // Delete the scheduled notification from core data
        coreDataViewModel.deleteScheduledNotification(scheduledNotification: scheduledNotification)
    }
}
