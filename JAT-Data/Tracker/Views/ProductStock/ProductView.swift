import SwiftUI

struct ProductView: View {
    @ObservedObject public var product: Product
    @ObservedObject var viewModel = ContentViewModel()
    
    
    var body: some View {
        Grid (alignment: .leading) {
            
            Text(product.name ?? "No name found.")
                .font(.title3)
                .bold()
                .padding(.top, 0.5)
            Divider()
            Text("Stock: \(product.stock, specifier: "%.0f")")
                .font(.callout)
                .padding(.bottom, 0.5)
                .padding(.top)
            Text("Price (bought): R$\(product.priceBuy, specifier: "%.2f")")
                .font(.callout)
                .padding(.bottom, 0.5)
            Text("Price (sell): R$\(product.priceSell, specifier: "%.2f"))")
                .font(.callout)
                .padding(.bottom)
            Divider()
            Stepper("Sold: \(product.sold, specifier: "%.0f")", onIncrement: {
                viewModel.sellProduct(product)
            }, onDecrement: {
                viewModel.undoSell(product)
            })
            .padding(.top)
            .padding(.bottom, 0.5)
            
        }
    }
}

