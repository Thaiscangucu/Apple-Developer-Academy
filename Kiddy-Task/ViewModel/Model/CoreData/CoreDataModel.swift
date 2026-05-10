//
//  CoreDataController.swift
//  KiddyTask
//
//  Created by Camila Parolin on 15/07/25.
//

import Foundation
import CoreData
import PhotosUI

final class CoreDataModel {
    static let shared = CoreDataModel()
    
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

    func createTarefa(title: String, desc: String, done: Bool, image: String, symbols: [String], color: String, date: Date, picAfter: UIImage) -> Tarefa {
        let tarefa = Tarefa(context: viewContext)
        
        tarefa.title = title
        tarefa.desc = desc
        tarefa.done = done
        tarefa.image = image
        
        // Agora aceitando o array de strings corretamente
        tarefa.symbols = symbols
        
        // Corrigindo a atribuição (estava salvando title em tudo)
        tarefa.color = color
        tarefa.date = date
        
        tarefa.id = UUID()
        
        // Transformando a imagem em Data
        tarefa.picAfter = picAfter.jpegData(compressionQuality: 0.8) // 0.8 é um bom equilíbrio de qualidade/tamanho
        
        saveContext()
        return tarefa
    }
    
    func createRecompensa(title: String, freq: Int16, symbol: String, color: String) -> Recompensa {
        let recompensa = Recompensa(context: viewContext)
        
        recompensa.title = title
        recompensa.freq = freq
        recompensa.symbol = symbol
        recompensa.color = color
                
        saveContext()
        return recompensa
    }
    
    
    public func createScheduledNotification(id: UUID, date: Date) -> ScheduledNotification {
        let scheduledNotification: ScheduledNotification = ScheduledNotification(context: viewContext)
        scheduledNotification.id = id
        scheduledNotification.date = date
        saveContext()
        
        return scheduledNotification
    }

    //READ
    func fetchTarefas() -> [Tarefa] {
        let request: NSFetchRequest<Tarefa> = Tarefa.fetchRequest()
        
        // Opcional: Adicione um SortDescriptor para manter a ordem sempre igual
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Tarefa.date, ascending: true)]
        
        do {
            // Isso força o contexto a buscar do disco e não apenas da memória
            // viewContext.reset() // Use apenas se o problema persistir muito
            return try viewContext.fetch(request)
        } catch {
            print("Erro ao buscar: \(error)")
            return []
        }
    }
    
    func fetchRecompensas() -> [Recompensa] {
        let request: NSFetchRequest<Recompensa> = Recompensa.fetchRequest()
        // Ordena por título para garantir uma lista estável
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Recompensa.title, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            return []
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
    
    func updateAfterImage(task: Tarefa, imageAfter: UIImage) {
        task.picAfter = imageAfter.jpegData(compressionQuality: 0.8)
        saveContext()
    }
    

    func toggleTarefa(_ tarefa: Tarefa) {
        tarefa.done.toggle()
        saveContext()
    }
 

    public func deleteNotification(scheduledNotification: ScheduledNotification) {
        viewContext.delete(scheduledNotification)
        saveContext()
    }
    
    
    
}
