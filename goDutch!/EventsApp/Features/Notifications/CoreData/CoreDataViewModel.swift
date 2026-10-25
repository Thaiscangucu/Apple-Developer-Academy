//
//  CoreDataViewModel.swift
//  EventsApp
//
//  Created by Thais Cangucu on 20/08/26.
//


import Foundation
import CoreData
import Foundation
import CoreData

@Observable
class CoreDataViewModel {

    public var scheduledNotifications:
        [ScheduledNotification] = []

    // MARK: - Fetch

    public func getNotifications() {

        scheduledNotifications =
            CoreDataModel.shared
                .fetchScheduledNotifications()
    }

    // MARK: - Create

    public func createScheduledNotification(
        id: UUID,
        date: Date
    ) {

        let newScheduledNotification =
            CoreDataModel.shared
                .createScheduledNotification(id: id, date: date)

        scheduledNotifications.append(
            newScheduledNotification
        )
    }

    // MARK: - Delete

    public func deleteScheduledNotification(
        scheduledNotification:
            ScheduledNotification
    ) {

        CoreDataModel.shared
            .deleteNotification(scheduledNotification: scheduledNotification)

        if let id =
            scheduledNotification.id {

            scheduledNotifications.removeAll {
                $0.id == id
            }

        } else {

            scheduledNotifications.removeAll {
                $0 === scheduledNotification
            }
        }
    }
}
