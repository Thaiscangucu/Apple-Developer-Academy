import Foundation
import CoreData

//MARK: -  Content View Model

class ContentViewModel: ObservableObject {
    @Published var products: [Product] = []
    
    func getProduct() {
        products = CoreDataController.shared.fetchAllProducts()
    }
    
    func createProduct(id: UUID, name: String, priceBuy: Double, priceSell: Double,sold: Double, stock: Double) {
        let result = CoreDataController.shared.createProduct(id: id, name: name, priceBuy: priceBuy, priceSell: priceSell, sold: sold, stock: stock)
        
        self.products.append(result)
    }
    
    func deleteProduct(_ product: Product) {
        CoreDataController.shared.deleteProduct(product)
    }
    
    func sellProduct(_ product: Product){
        CoreDataController.shared.sellProduct(product)
    }
    
    func undoSell(_ product: Product){
        CoreDataController.shared.sellProduct(product)
    }
}
