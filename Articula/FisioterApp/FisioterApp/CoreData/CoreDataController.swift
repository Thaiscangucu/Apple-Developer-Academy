//
//  CoreDataController.swift
//  ToDoListEmpty
//
//  Created by Laura C. Balbachan dos Santos on 23/05/25.


import CoreData
import Foundation

class CoreDataController {
    static let shared = CoreDataController()
    
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Model")
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Could not load CoreData stack: \(error.localizedDescription)")
            }
            
        }
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
    
    func createSesssion(_ autonomy: Bool, _ completed: Bool, _ date: Date, _ difficulty: Int16, _ duration: Int16, _ painRate: Int16, _ repetitions: Int16) -> Session {
        
        let session = Session(context: viewContext)
        
        session.autonomy = autonomy
        session.completed = completed
        session.date = date
        session.difficulty = difficulty
        session.duration = duration
        session.id = UUID()
        session.painRate = painRate
        session.repetitions = repetitions
        
        saveContext()
        return session
    }
    
    func fetchAllToDos() -> [Session] {
        let fetchRequest: NSFetchRequest<Session> = Session.fetchRequest()
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("Error fetching ToDos: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteToDo(_ session: Session) {
        viewContext.delete(session)
        
        saveContext()
    }
    
    func createReport(_ autonomy: String, _ completed: String, _ difficulty: String, _ duration: String, _ painRate: Int16, _ dateCreate: Date, _ datePeriod1: Date, _ datePeriod2: Date) -> Report {
        
        let report = Report(context: viewContext)
        
        report.id = UUID()
        report.autonomy = autonomy
        report.dateCreate = dateCreate
        report.completed = completed
        report.datePeriod1 = datePeriod1
        report.datePeriod2 = datePeriod2
        report.difficulty = difficulty
        report.duration = duration
        report.painRate = painRate
        saveContext()
        return report
    }
    
    public func updateReport(report: Report, autonomy: String, difficulty: String, painRate: Int16) {
        report.autonomy = autonomy
        report.difficulty = difficulty
        report.painRate = painRate
    }
    
    
    func fetchAllReportTopics() -> [Report] {
        let fetchRequest: NSFetchRequest<Report> = Report.fetchRequest()
        
        do {
            let report = try viewContext.fetch(fetchRequest)
            return report
        } catch {
            print("Error fetching ToDos: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteReportTopics(_ report: Report) {
        viewContext.delete(report)
        
        saveContext()
    }
    
    
}
