//
//  objectsMecanics.swift
//  C8
//
//  Created by Isabela Hissa Pinto on 20/10/25.
//

import Foundation
import CoreData
import SpriteKit
import CoreHaptics

@Observable public class ObjectsMechanicsViewModel {
    var objName: [String]
    var ambient: String
    private var objCount: [Int]
    var objSound: [Bool]
    var viewModel: CoreDataViewModel = CoreDataViewModel()

    init(objName: [String], ambient: String) {
        self.objName = objName
        self.ambient = ambient
        self.objCount = [0,0,0,0,0,0,0,0,0,0,0,0,0] //ajeitar com a quantidade de objetos (generificar)
        self.objSound = [false, false, false]
    }
    
    func populateCount(objName: [String]){
        for _ in 0..<objName.count{
            objCount.append(0)
        }
    }
    
    func checkStrings() -> (Int, Bool)? {
        
        objCount = [0,0,0,0,0,0,0,0,0,0,0,0,0]
        viewModel.getObjeto()
        populateCount(objName: objName)
        
        for obj in viewModel.objetos{
            for i in 0..<objName.count{
                if obj.ambient == ambient && obj.canMove == "Movable" && obj.name == objName[i]{
                    objCount[i] += 1
                }
            }
        }
        

        for i in 0..<objName.count-1{
            if (objCount[i] == 3 && objSound[i + 1] == false) {
                SoundManager.instance.playSound(sound: .popAudio)
                objSound[i+1] = true
                return (i+1, true)
            }
        }
        
        return nil
    }
    
    func checkValues(){
        for i in 0..<objName.count{
            print("\(objName[i]): \(objCount[i]) ")
        }
    }
    func setObjSound(isUnlocked: [Bool]){
        objSound = isUnlocked
    }
}
