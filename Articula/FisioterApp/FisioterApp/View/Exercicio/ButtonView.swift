import UIKit

class ButtonView: UIButton {
    private let gradientLayer = CAGradientLayer()
    
    public var newText: String = "" {
        didSet {
            self.setTitle(newText, for: .normal)
        }
    }

    init(newtext: String, width: CGFloat, height: CGFloat) {
        self.newText = newtext
        super.init(frame: .zero)
        
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: width),
            self.heightAnchor.constraint(equalToConstant: height)
        ])
        setupButton()
        setupGradient()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
        self.layer.cornerRadius = 26
    }

    private func setupButton() {
        self.setTitle(newText, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitleColor(.white, for: .normal)
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .semibold).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        self.titleLabel?.font = UIFont(descriptor: descriptor, size: 28)
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.968, green: 0.767, blue: 0.465, alpha: 1).cgColor,
            UIColor(red: 0.907, green: 0.456, blue: 0.93, alpha: 1).cgColor
            ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.clipsToBounds = true
    }
}

#Preview {
    // Chamada agora muito mais simples:
    ButtonView(newtext: "Confirmar", width: 240, height: 100)
}
