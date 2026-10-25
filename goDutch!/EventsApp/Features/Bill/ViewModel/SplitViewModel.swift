//
//  SplitViewModel.swift
//  EventsApp
//
//  Created by Camila Parolin on 01/09/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class SplitViewModel {
    
    var expandedProductID: Product.ID?
    var showsCompletionAlert = false
    var showsCompletedScreen = false
    var showMissingAssigmentAlert = false
    
    //abre um card ou fecha o card que já está aberto
    func toggleCard(_ productID: Product.ID) {
        expandedProductID = expandedProductID == productID ? nil : productID
    }
    
    //avança do product atual para o próximo
    func advanceOrRequestCompletion(in products: [Product]){
        guard let expandedProductID else {
            showsCompletionAlert = true
            return
        }
        
        guard let currentIndex = products.firstIndex(where: { $0.id == expandedProductID }) else {
            showsCompletionAlert = true
            return
        }
        
        let nextIndex = products.index(after: currentIndex)
        
        guard nextIndex < products.endIndex else {
            showsCompletionAlert = true
            return
        }
        
        self.expandedProductID = products[nextIndex].id
    }
    
    func canCompleteDivision(with products: [Product]) -> Bool {
        guard !products.isEmpty else {
            return false
        }
        
        return products.allSatisfy { product in
            !product.assignedUserIDs.isEmpty
        }
    }
    
    func showCompletedScreen() {
        showsCompletedScreen = true
    }
}
