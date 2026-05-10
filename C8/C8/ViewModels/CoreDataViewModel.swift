//
//  CoreDataViewModel.swift
//  Challenge8
//
//  Created by Thais Cangucu on 10/10/25.
//

import Foundation
import SpriteKit

@Observable
class CoreDataViewModel {
    var objetos: [Objeto] = []
    var actualProgress: [Double] = [0.0, 0.0, 0.0, 0.0]
    var levels: [Bool] = [true, false, false, false]
    
    func setActualProgress(objName: [String]){
        self.getObjeto()
        actualProgress = [0.0, 0.0, 0.0, 0.0]
        
        for obj in self.objetos{
            for i in 0..<objName.count{
                if obj.name == objName[i] && obj.canMove == "Fixed"{
                    self.levels[i] = true
                    for j in 0..<i {
                        actualProgress[j] = 3
                    }
                }
                if self.levels[i] == true{
                    if obj.name == objName[i] && obj.canMove == "Movable"{
                      
                            actualProgress[i] += 1
                        
                    }
                }
            }
        }
    }
    
    func getObjeto() {
        objetos = CoreDataController.shared.fetchAllObjetos()
    }
    
    func createObjeto(name: String, x: Double, y: Double, id: UUID, ambient: String, canMove: String) {
        let result = CoreDataController.shared.createObjeto(name, x, y, id, ambient, canMove)
        self.objetos.append(result)
    }
    
    func deleteObjeto(_ objeto: SKSpriteNode) {
        for obj in objetos{
            if objeto.userData!["id"] as? UUID == obj.id{
                CoreDataController.shared.deleteToDo(obj)
            }
        }
    }
    
    func saveContext(){
        CoreDataController.shared.saveContext()
    }
    
}
