//
//  File.swift
//  HabitosImprove
//
//  Created by Thais Cangucu on 16/07/25.
//
import Foundation
import CoreData

class CoreDataModel {
    public static let shared = CoreDataModel()
    private let persistentContainer: NSPersistentContainer
    
    public var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("[ERROR]: Could not load CoreData stack (\(error.localizedDescription)")
            }
        }
    }
    
    /// Saves the current view context if there are any pending changes.
    public func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("[WARNING]: Failed to save context (\(error.localizedDescription))")
            }
        }
    }
    
    /// Fetches all stored Habit entities from the database.
    /// - Returns: An array of Habit objects.
    public func fetchHabits() -> [Habit] {
        let fetchRequest: NSFetchRequest<Habit> = Habit.fetchRequest()
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("[WARNING]: Failed to fetch habits (\(error.localizedDescription)")
            return []
        }
    }
    
    /// Creates and persists a new Habit entity.
    /// - Parameters:
    ///   - title: The name of the habit.
    ///   - descricao: A brief description of the habit.
    ///   - goalQuantity: The daily target quantity.
    ///   - goalUnit: The measurement unit for the goal.
    ///   - reminders: Boolean indicating if notifications are enabled.
    ///   - reminderTime: The scheduled time for the reminder.
    /// - Returns: The newly created Habit instance.
    public func createHabit(title: String, descricao: String, goalQuantity: Int16, goalUnit: String, reminders: Bool, reminderTime: Date) -> Habit {
        let habit = Habit(context: viewContext)
        habit.title = title
        habit.descricao = descricao
        habit.goalQuantity = goalQuantity
        habit.goalUnit = goalUnit
        habit.reminders = reminders
        habit.reminderTime = reminderTime
        habit.habitCount = 0
        habit.totalCount = 0
        saveContext()
        return habit
    }
    
    /// Deletes a specific Habit entity from the database.
    /// - Parameter habit: The Habit instance to be removed.
    public func deleteHabit(habit: Habit) {
        viewContext.delete(habit)
        saveContext()
    }
    
    /// Updates an existing Habit entity with new values.
    public func updateHabit(habit: Habit, title: String, descricao: String, goalQuantity: Int16, goalUnit: String, reminders: Bool, reminderTime: Date, newCount: Int16, totalCount: Int16) {
        habit.title = title
        habit.descricao = descricao
        habit.goalQuantity = goalQuantity
        habit.goalUnit = goalUnit
        habit.reminders = reminders
        habit.reminderTime = reminderTime
        habit.habitCount = newCount
        habit.totalCount = totalCount
        saveContext()
    }
    
    /// Updates a specific Day entry linked to a habit.
    public func updateDay(day: Day, dailyCount: Int16, date: Date, color: String) {
        day.dailyCount = dailyCount
        day.date = date
        day.color = color
        saveContext()
    }
    
    /// Resets the daily count of a habit to zero.
    public func zeroDailyCount(habit: Habit) {
        habit.habitCount = 0
        saveContext()
    }
    
    /// Fetches all stored Day entities.
    /// - Returns: An array of Day objects.
    public func fetchDays() -> [Day] {
        let fetchRequest: NSFetchRequest<Day> = Day.fetchRequest()
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("[WARNING]: Failed to fetch days (\(error.localizedDescription)")
            return []
        }
    }

    /// Creates a new Day record to track habit completion on a specific date.
    public func createDay(habit: String, date: Date, color: String) -> Day {
        let day = Day(context: viewContext)
        day.habit = habit
        day.date = date
        day.color = color
        saveContext()
        return day
    }
    
    /// Deletes a specific Day record.
    public func deleteDay(day: Day) {
        viewContext.delete(day)
        saveContext()
    }
    
    /// Removes all Day records associated with a specific habit name.
    public func clearDays(days: [Day], habit: String) {
        days.filter { $0.habit == habit }.forEach { viewContext.delete($0) }
        saveContext()
    }
    
    /// Fetches all scheduled notification records.
    public func fetchScheduledNotifications() -> [ScheduledNotification] {
        let fetchRequest: NSFetchRequest<ScheduledNotification> = ScheduledNotification.fetchRequest()
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("[WARNING]: Failed to fetch notifications (\(error.localizedDescription))")
            return []
        }
    }
    
    /// Persists a record of a scheduled notification.
    public func createScheduledNotification(id: UUID, date: Date) -> ScheduledNotification {
        let notification = ScheduledNotification(context: viewContext)
        notification.id = id
        notification.date = date
        saveContext()
        return notification
    }
    
    /// Deletes a scheduled notification record.
    public func deleteNotification(scheduledNotification: ScheduledNotification) {
        viewContext.delete(scheduledNotification)
        saveContext()
    }
    
    /// Fetches all streak records.
    public func fetchStreaks() -> [Streak] {
        let fetchRequest: NSFetchRequest<Streak> = Streak.fetchRequest()
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("[WARNING]: Failed to fetch streaks (\(error.localizedDescription))")
            return []
        }
    }
    
    /// Creates a new streak record starting at zero.
    public func createStreak() -> Streak {
        let streak = Streak(context: viewContext)
        streak.number = 0
        streak.date = .now
        saveContext()
        return streak
    }
    
    /// Increases the counter for all provided streaks by one.
    public func increaseStreak(streaks: [Streak]) {
        streaks.forEach { $0.number += 1 }
        saveContext()
    }
    
    /// Resets all provided streaks to zero.
    public func resetStreak(streaks: [Streak]) {
        streaks.forEach { $0.number = 0 }
        saveContext()
    }
    
    /// Deletes a specific streak record.
    public func deleteStreak(streak: Streak) {
        viewContext.delete(streak)
        saveContext()
    }
    
    /// Checks if a Day record already exists for a specific habit and date.
    func dayExists(habit: String, date: Date) -> Bool {
        let request: NSFetchRequest<Day> = Day.fetchRequest()
        request.predicate = NSPredicate(format: "habit == %@ AND date == %@", habit, date as NSDate)
        request.fetchLimit = 1
        return (try? viewContext.count(for: request)) ?? 0 > 0
    }
}
