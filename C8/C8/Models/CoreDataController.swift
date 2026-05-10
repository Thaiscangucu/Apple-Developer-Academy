//
//  Untitled.swift
//  Challenge8
//
//  Created by Thais Cangucu on 10/10/25.
//

import Foundation
import CoreData

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
    

    func createObjeto(_ name: String, _ x: Double, _ y: Double, _ id: UUID, _ ambient: String, _ canMove: String) -> Objeto {

        let objeto = Objeto(context: viewContext)
        
        objeto.canMove = canMove
        objeto.name = name
        objeto.x = x
        objeto.y = y
        objeto.id = id
        objeto.ambient = ambient

        saveContext()
        return objeto
    }
    
    func fetchAllObjetos() -> [Objeto] {
        let fetchRequest: NSFetchRequest<Objeto> = Objeto.fetchRequest()
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("Error fetching ToDos: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteToDo(_ objeto: Objeto) {
        viewContext.delete(objeto)
        
        saveContext()
    }
}
