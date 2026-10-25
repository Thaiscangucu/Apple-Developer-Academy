import Foundation
import UIKit

class PainButtons: UIView {
    
    var levelButtons: [UIButton] = []
    
    let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLevelButtons()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLevelButtons()
        setupView()
    }
    
    private func setupView() {
        addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
                buttonStack.topAnchor.constraint(equalTo: topAnchor),
                buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor),
                buttonStack.centerXAnchor.constraint(equalTo: centerXAnchor),
                buttonStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
                buttonStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20)
            ])
    }
    
    func setupLevelButtons() {
//        levelButtons.forEach { $0.removeFromSuperview() }
//        levelButtons.removeAll()
        
        for i in 0..<5 {
            let button = UIButton()
            button.tag = i + 1
            button.backgroundColor = .systemGray5
            button.layer.cornerRadius = 12.5
            button.translatesAutoresizingMaskIntoConstraints = false
            

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 25),
                button.heightAnchor.constraint(equalToConstant: 25)
            ])
            
            button.addTarget(self, action: #selector(painLevelSelected(_:)), for: .touchUpInside)
            
            levelButtons.append(button)
            buttonStack.addArrangedSubview(button)
        }
    }
    
    @objc func painLevelSelected(_ sender: UIButton) {
        let selectedLevel = sender.tag
        for (index, button) in self.levelButtons.enumerated() {
            if index < selectedLevel {
                button.backgroundColor = getPainGradient(bounds: button.bounds)
            } else {
                button.backgroundColor = .systemGray5
            }
        }
    }
    
    func getPainGradient(bounds: CGRect) -> UIColor {
        let actualBounds = bounds.width > 0 ? bounds : CGRect(x: 0, y: 0, width: 25, height: 25)
        let colors = [
            UIColor(red: 0.968, green: 0.767, blue: 0.465, alpha: 1),
            UIColor(red: 0.907, green: 0.456, blue: 0.93, alpha: 1)
        ]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = actualBounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        let renderer = UIGraphicsImageRenderer(bounds: actualBounds)
        let image = renderer.image { ctx in
            gradientLayer.render(in: ctx.cgContext)
        }
        return UIColor(patternImage: image)
    }
}

#Preview {
    PainButtons(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
}
