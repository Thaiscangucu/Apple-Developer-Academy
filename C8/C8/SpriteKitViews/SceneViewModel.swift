//
//  GenericSceneView.swift
//  C8
//
//  Created by Isabela Hissa Pinto on 27/10/25.
//

import SwiftUI
import SpriteKit
import CoreData

@Observable
class GenericScene: SKScene {
    var background: SKSpriteNode
    var selectedObj: SKSpriteNode?
    var garbage: SKSpriteNode
    var objName: [String]
    var isUnlocked: [Bool] = []
    var viewModel: CoreDataViewModel =  CoreDataViewModel()
    var hapitcs: Haptics = Haptics()
    var ambient: String
    var Mechanics: ObjectsMechanicsViewModel
    var firstAccess: Bool = false
    
    var obj: SKSpriteNode
    var onboardingObj: SKSpriteNode
    var lastUpdateTime: TimeInterval = 0
    var isFirstTouche: Bool = true
    var blackRectangle: SKShapeNode
    init(backgroundName: String, objetos: [String], ambient: String) {
        self.background = SKSpriteNode(imageNamed: backgroundName)
        self.selectedObj = nil
        self.garbage = SKSpriteNode(imageNamed: "Garbage")
        self.objName = objetos
        self.ambient = ambient
        self.Mechanics = ObjectsMechanicsViewModel(objName: objetos, ambient: ambient)
        
        self.obj = SKSpriteNode(imageNamed: "C\(objetos.first!)")
        self.onboardingObj = SKSpriteNode(imageNamed: objetos.first!)
        self.blackRectangle = SKShapeNode()
        super.init(size: CGSize(width: 100, height: 100))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Funções de criaçao ----------------------------------------------------------------------------------------
    
    func onboardingInit(){
        var show: Bool = true
        viewModel.getObjeto()
        for obj in viewModel.objetos{
            if obj.canMove == "Movable" && obj.ambient == ambient{
                show = false
            }
        }
        if show{
            
            self.obj.position = CGPoint(x: frame.midX - 125, y: 193)
            self.obj.size = CGSize(width: 71, height: 70)
            self.obj.name = "Locked"
            self.obj.zPosition = 8
            self.obj.userData = ["imageNamed" : "C\(objName.first)", "id" : UUID()]
            
            self.onboardingObj.position = CGPoint(x: frame.midX, y: frame.midY)
            self.onboardingObj.size = CGSize(width: 71, height: 70)
            self.onboardingObj.name = "Locked"
            self.onboardingObj.zPosition = 8
            self.onboardingObj.userData = ["imageNamed" : "O\(objName.first)", "id" : UUID()]
            self.onboardingObj.alpha = 0.6
            
            blackRectangle.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: 1000, height: 1000)), cornerRadius: 20).cgPath
    //        stroke.position = CGPoint(x: frame.midX - 176.5, y: 143)
            blackRectangle.position = CGPoint(x: frame.midX - 300, y: frame.minY)
            blackRectangle.fillColor = SKColor.black
            blackRectangle.zPosition = 7
            blackRectangle.alpha = 0.3
            addChild(blackRectangle)
            addChild(onboardingObj)
            addChild(obj)
        }
    }
    
    func initIsUnlocked(){
            isUnlocked = []
            viewModel.getObjeto()
            for obj in objName{
                if obj == objName.first{
                    isUnlocked.append(true)
                }
                for coreDataObj in viewModel.objetos{
                    if coreDataObj.name == obj && coreDataObj.canMove == "Fixed" && self.ambient == coreDataObj.ambient {
                        isUnlocked.append(true)
                    }
                }
            }
            if isUnlocked.count < objName.count{
                for _ in 0..<(objName.count-isUnlocked.count){
                    isUnlocked.append(false)
                }
            }
    }
    
    func createBackground(){
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = CGSize(width: frame.width * 0.75, height: frame.height)
        background.zPosition = -1
        addChild(background)
    }
    
    func BKRectangle(){
        let bkRectangle = SKShapeNode()
        bkRectangle.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: 324, height: 92)), cornerRadius: 16).cgPath
//        bkRectangle.position = CGPoint(x: frame.midX - 170.5, y: 149)
        bkRectangle.position = CGPoint(x: frame.midX - 162, y: frame.minY + 149)
        bkRectangle.fillColor = SKColor.white
        bkRectangle.zPosition = 2
        addChild(bkRectangle)
        let stroke = SKShapeNode()
        stroke.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: 335, height: 104)), cornerRadius: 20).cgPath
//        stroke.position = CGPoint(x: frame.midX - 176.5, y: 143)
        stroke.position = CGPoint(x: frame.midX - 167.5, y: frame.minY + 143)
        stroke.fillColor = SKColor.black
        stroke.zPosition = 1
        addChild(stroke)
    }
    
    func createObj(imageNamed: String, x: Double, y: Double, isLocked: Bool){
        let obj = SKSpriteNode(imageNamed: imageNamed)
        obj.position = CGPoint(x: x, y: y)
        obj.size = CGSize(width: 71, height: 70)
        if isLocked {
            obj.name = "Locked"
            obj.zPosition = 6
        }else{
            obj.name = "Fixed"
            obj.zPosition = 7
        }
        obj.userData = ["imageNamed" : imageNamed, "id" : UUID()]
        
        addChild(obj)
    }
    
    func deleteObject(obj: SKSpriteNode, garbage: SKNode){
        if obj.intersects(garbage) {
                        
            SoundManager.instance.playSound(sound: .GarbageAudio)
            viewModel.deleteObjeto(obj)
            obj.removeFromParent()
        }
    }
    
    func createTexture(obj: SKSpriteNode) -> [SKTexture]{
        guard let img1 = obj.userData?.value(forKey: "imageNamed") else { return [] }
        let img2 = "T\(img1)"
        let textures: [SKTexture] = [SKTexture(imageNamed: img1 as! String), SKTexture(imageNamed: img2)]
        return textures
    }
    
    func animation(obj: SKSpriteNode){
        let textures: [SKTexture] = createTexture(obj: obj)
        let change: SKAction = SKAction.animate(with: textures, timePerFrame: 0.3)
        obj.run(SKAction.repeatForever(change))
    }
    
    func createGarbage(){
        garbage.name = "garbage"
        garbage.position = CGPoint(x: frame.midX, y: 193)
        garbage.size = CGSize(width: 65, height: 74)
        garbage.zPosition = 10
        background.zPosition = 8
        addChild(garbage)
    }
    
    func deleteGarbate(){
        garbage.removeFromParent()
    }
    
    func playSound(){
        for obj in objName{
            if selectedObj?.userData?["imageNamed"] as? String? ?? "" == obj{
                SoundManager.instance.playSound(sound: .none, soundName: obj)
            }
        }
    }
    
    func unlockNewObj(index: Int, x: Double, y: Double){
        createObj(imageNamed: objName[index], x: x, y: y, isLocked: false)
    }
    
    func unlockObj(){
        initIsUnlocked()
        Mechanics.setObjSound(isUnlocked: isUnlocked)
        if let (i, status) = Mechanics.checkStrings() {
            let tempX = Double(frame.midX - 125)
            let x = tempX + Double((83 * (i)))
            createObj(imageNamed: objName[i], x: x, y: 193, isLocked: false)
            viewModel.createObjeto(name: objName[i], x: x, y: 193, id: UUID(), ambient: ambient, canMove: "Fixed")
            hapitcs.unlockedObject()
        }
    }
    
//Funções que rodam a Scene --------------------------------------------------------------------------------
    
    override func didMove(to view: SKView) {
        ProgramStart()
    }
    
    func ProgramStart(){
        print("ProgramStart")
        if self.firstAccess == false {
            initIsUnlocked()
            onboardingInit()
            createBackground()
            AddSavedObjs()
            self.firstAccess = true
        }
        for i in 0..<objName.count {
            let tempX = Double(frame.midX - 125)
            let x = tempX + Double((83 * (i)))
            createObj(imageNamed: "L\(objName[i])", x: x, y: 193, isLocked: true)
        }
        BKRectangle()
        //Create first obj
        createObj(imageNamed: objName[0], x: frame.midX - 125, y: 193, isLocked: false)
        hapitcs.prepateHaptics()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        print("touchesBegan")
        guard let touch = touches.first else { return }
        let locationInScene = touch.location(in: self)
     
        if let touchedNode = atPoint(locationInScene) as? SKSpriteNode, touchedNode.name == "Fixed" {
            
            obj.removeFromParent()
            onboardingObj.removeFromParent()
            blackRectangle.removeFromParent()
            let newObj = SKSpriteNode(imageNamed: (touchedNode.userData?["imageNamed"] as? String ?? ""))
            newObj.name = "Movable"
            newObj.position = touchedNode.position
            newObj.size = CGSize(width: 71, height: 70)
            newObj.userData = ["imageNamed" : touchedNode.userData?["imageNamed"] as? String ?? "", "id" : UUID()]
            newObj.zPosition = 11
            addChild(newObj)
            selectedObj = newObj
        }
        
        if let touchedNode = atPoint(locationInScene) as? SKSpriteNode, touchedNode.name == "Movable" {
            selectedObj = touchedNode
            animation(obj: selectedObj!)
        }
        if let touchedNode = atPoint(locationInScene) as? SKSpriteNode, touchedNode.name == "Fixed" || touchedNode.name == "Movable"  {
            createGarbage()
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let locationInScene = touch.location(in: self)
        
        if selectedObj?.name == "Movable" {
            selectedObj?.position = locationInScene
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded")
        checkCoreData()
        selectedObj?.zPosition = 11
        hapitcs.droppedObjetc()
        playSound()
        if let selectedObj = selectedObj {
            deleteObject(obj: selectedObj, garbage: garbage)
            deleteGarbate()
        }
        background.zPosition = -1
        
        unlockObj()
        Mechanics.checkValues()
        selectedObj = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isFirstTouche{
            _ = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
            
            if obj.position.x >= onboardingObj.position.x && obj.position.y >= onboardingObj.position.y{
                obj.position.x = frame.midX - 125
                obj.position.y = 193
            }
            
            if obj.position.x <= onboardingObj.position.x {
                obj.position.x += 1
            }
            if obj.position.y <= onboardingObj.position.y {
                obj.position.y -= (frame.midY - 193) / (frame.midX - frame.midX - 125)
            }
        }
        
        
    }
    
    
    //Funções do CoreData ---------------------------------------------------------------------------------------
    
    func checkCoreData(){
        var isFound = false
        // Fetch dos objetos salvos no core data
        viewModel.getObjeto()
        
        // Se o array estiver vazio cria o primeiro objeto no Core Data
        if viewModel.objetos.isEmpty{
            
            if let x = selectedObj?.position.x, let y = selectedObj?.position.y, let _ = selectedObj {
                if let name = selectedObj?.userData?["imageNamed"] as? String{
                    viewModel.createObjeto(name: name, x: x, y: y, id: selectedObj?.userData?["id"] as! UUID, ambient: ambient, canMove: "Movable")
                    
                }
            }
        }
        
        // Se já houver objetos salvos no array
        else{
            for objeto in viewModel.objetos{
                // Se o id de cada objeto é igual ao do objeto selecionado, atualiza as coordenadas no Core Data
                if selectedObj?.userData?["id"] as? UUID == objeto.id{
                    isFound = true
                    if let x = selectedObj?.position.x, let y = selectedObj?.position.y {
                        objeto.x = x
                        objeto.y = y
                        viewModel.saveContext()
                    }
                    return
                }
            }
            // Se os ids forem diferentes, cria um novo objeto no Core Data
            if !isFound{
                if let x = selectedObj?.position.x, let y = selectedObj?.position.y, let obj = selectedObj {
                    viewModel.createObjeto(name: obj.userData?["imageNamed"] as! String, x: x, y: y, id: obj.userData?["id"] as! UUID, ambient: ambient, canMove: "Movable")
                    
                }
            }
        }
    }
    
    func AddSavedObjs(){
        viewModel.getObjeto()
        if !viewModel.objetos.isEmpty{
            for objeto in viewModel.objetos{
                if objeto.ambient == ambient{
                    let newObj = SKSpriteNode(imageNamed: objeto.name ?? "Shaver")
                    newObj.name = objeto.canMove
                    newObj.position.x = objeto.x
                    newObj.position.y = objeto.y
                    newObj.size = CGSize(width: 71, height: 70)
                    newObj.userData = ["imageNamed" : objeto.name!, "id" : objeto.id!]
                    newObj.physicsBody?.contactTestBitMask = newObj.physicsBody?.collisionBitMask ?? 0
                    newObj.zPosition = 7
                    addChild(newObj)
                    if objeto.canMove == "Movable" {
                        animation(obj: newObj)
                        newObj.zPosition = 11
                    }
                }
            }
        }
    }
}

#Preview{
    AmbientView(background: "Airport", objetos: ["Scissor", "Shaver","BlowDryer","Shower"], ambiente: "Barber")
}
