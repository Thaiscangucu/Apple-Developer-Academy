//
//  CoreDataModel.swift
//  LocalNotificationDemo
//
//  Created by Diego Saragoza Da Silva on 25/06/25.
//

import Foundation
import SwiftUI
import CoreData

class CoreDataModel {
    public static let shared = CoreDataModel()
    
    private let persistentContainer: NSPersistentContainer
    
    public var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            if let error = error {
                fatalError("[ERROR]: Could not load CoreData stack (\(error.localizedDescription))")
            }
        })
    }
    
    public func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            }
            catch {
                print("[WARNING]: Failed to save container view context (\(error.localizedDescription))")
            }
        }
    }
    
    public func fetchScheduledNotifications() -> [ScheduledNotification] {
        let fetchRequest: NSFetchRequest<ScheduledNotification> = ScheduledNotification.fetchRequest()
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result
        }
        catch {
            print("[WARNING]: Failed to fetch scheduled notifications (\(error.localizedDescription))")
            return []
        }
    }
    
    public func createScheduledNotification(id: UUID, date: Date) -> ScheduledNotification {
        let scheduledNotification: ScheduledNotification = ScheduledNotification(context: viewContext)
        scheduledNotification.id = id
        scheduledNotification.date = date
        saveContext()
        
        return scheduledNotification
    }
    
    public func deleteNotification(scheduledNotification: ScheduledNotification) {
        viewContext.delete(scheduledNotification)
        saveContext()
    }
}
