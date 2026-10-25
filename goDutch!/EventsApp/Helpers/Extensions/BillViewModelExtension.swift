//
//  BillViewModel+.swift
//  EventsApp
//
//  Created by Camila Parolin on 01/09/26.
//
//Esse  arquivo talvez possa ser mesclado ao BillViewModel padrão.
//Ele foi criado pensando apenas em futuros merges para não darem problema

import Foundation

extension BillViewModel {
    
    //retira a atribuição de um usuário de um produto
//    func unassignUser(_ userID: User.ID, fromProductID productID: Product.ID) {
//        guard var product = bill.items.first(where: {
//                $0.id == productID
//            }
//        ) else {
//            return
//        }
//        
//        product.assignedUserIDs.remove(userID)
//        
//        updateItem(product)
//    }
    
    func totalToPay(for user: User) -> Double {
        bill.items.reduce(0) { accumulatedTotal, product in
            guard product.assignedUserIDs.contains(user.id) else {
                return accumulatedTotal
            }
            
            let assignedUserCount = product.assignedUserIDs.count
            
            guard assignedUserCount > 0 else {
                return accumulatedTotal
            }
            
            let productTotal = product.price * Double(product.quantity)
            
            let valuePerUser = productTotal / Double(assignedUserCount)
            
            return accumulatedTotal + valuePerUser
        }
    }
}

