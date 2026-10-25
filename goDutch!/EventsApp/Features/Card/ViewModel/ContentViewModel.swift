import SwiftUI
import SpriteKit

@Observable
final class ContentViewModel{

    let scene: CloseAccountScene = {
        let scene = CloseAccountScene(size: CGSize(width: 393, height: 852))
        scene.scaleMode = .resizeFill
        return scene
    }()
    
    var onPaymentCompleted: (() -> Void)? {
            get { scene.onPaymentCompleted }
            set { scene.onPaymentCompleted = newValue }
        }

    func onAppear() {
        scene.size = UIScreen.main.bounds.size
    }

    func updateSceneSize(_ newSize: CGSize) {
        scene.size = newSize
    }
}
