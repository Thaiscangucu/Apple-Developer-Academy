import CoreData
import Foundation

//MARK: - Control data persistence
class CoreDataController: ObservableObject {
    static let shared = CoreDataController()
    
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Tracker")
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Could not load CoreData stack: \(error.localizedDescription)")
            }
            
        }
    }
    
    //MARK: - Func that interacts with Product data
    
    /*Save after changing the content*/
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
    
    /*Cerate product and saves it*/
    func createProduct(id: UUID, name: String, priceBuy: Double,  priceSell: Double, sold: Double, stock: Double) -> Product {
        let product = Product(context: viewContext)
        
        product.id = UUID()
        product.name = name
        product.priceBuy = priceBuy
        product.priceSell = priceSell
        product.sold = sold
        product.stock = stock
        
        saveContext()
        return product
        
    }
    
    /*Search for products*/
    func fetchAllProducts() -> [Product] {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("Error fetching Products: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteProduct(_ product: Product){
        viewContext.delete(product)
        saveContext()
    }
    
    /*Control the quantity of products*/
    func sellProduct(_ product: Product){
        if product.sold > product.stock {
            print("Unable to Sell")
        }else{
            product.stock -= 1
            product.sold += 1
            saveContext()
        }
    }
    
    func undoSell(_ product: Product){
        if product.sold == 0 && product.stock == 0 {
            print("Unable to undo")
        }else{
            product.stock -= 1
            product.sold += 1
            saveContext()
        }
    }
    
    
}
