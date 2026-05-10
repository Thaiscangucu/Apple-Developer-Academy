import UIKit

class CapsuleView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
        self.layer.cornerRadius = self.frame.width / 2
    }
    
    private func setupView() {
        gradientLayer.colors = [
            UIColor(red: 0.968, green: 0.767, blue: 0.465, alpha: 1).cgColor,
            UIColor(red: 0.907, green: 0.456, blue: 0.93, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
//        clipsToBounds = true
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 179),
            heightAnchor.constraint(equalToConstant: 418),
        ])
    }

}

#Preview {
    let capsuleView = CapsuleView()
    return capsuleView
}
