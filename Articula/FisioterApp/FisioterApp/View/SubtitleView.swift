import UIKit

class SubtitleView: UIView {
    
    private let miniLabel: UILabel = {
        let label = UILabel()
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .light).fontDescriptor
                    .addingAttributes([
                        .traits: [UIFontDescriptor.TraitKey.width: 0.5]
                    ])
        label.font = UIFont(descriptor: descriptor, size: 20)
        label.text = "Para"
        label.textColor = .gray
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Exercício 1"
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .semibold).fontDescriptor
                    .addingAttributes([
                        .traits: [UIFontDescriptor.TraitKey.width: 0.5]
                    ])
        label.font = UIFont(descriptor: descriptor, size: 28)
        //label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .darkGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(miniLabel)
        addSubview(titleLabel)
        
        miniLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // miniLabel
                miniLabel.topAnchor.constraint(equalTo: topAnchor),
                miniLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                        
            // titleLabel
                titleLabel.topAnchor.constraint(equalTo: miniLabel.bottomAnchor, constant: 4),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

#Preview{
    SubtitleView()
}
