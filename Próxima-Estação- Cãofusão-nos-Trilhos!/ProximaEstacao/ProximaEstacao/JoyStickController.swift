//
//  JoyStickController.swift
//  JoyStick
//
//  Created by Lucca Pivoto on 24/02/26.
//

import Foundation
import SwiftUI
import GameController
#if os(iOS)

extension GCVirtualController{
    static func setUpVirtualController() -> GCVirtualController{
        let controllerConfic = GCVirtualController.Configuration()
        controllerConfic.elements = [GCInputLeftThumbstick]
        let controller = GCVirtualController(configuration: controllerConfic)
        controller.connect()
        return controller
    }
    
    func getPosX() -> CGFloat{
        return CGFloat((self.controller?.extendedGamepad?.leftThumbstick.xAxis.value)!)
    }
    
    func getPosY() -> CGFloat{
        return CGFloat((self.controller?.extendedGamepad?.leftThumbstick.yAxis.value)!)
    }
    
}
#endif
