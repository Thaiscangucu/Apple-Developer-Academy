//
//  NotificationToggleView.swift
//  FisioterApp
//
//  Created by Yasmin Mendes  on 10/04/26.
//

import UIKit

class NotificationToggleView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Notificação"
        label.textColor = .darkGray
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .light).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 20)
        return label
    }()
    
    let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .clear
        toggle.backgroundColor = .clear
        return toggle
    }()

    private let gradientView = UIView()
    private let gradientLayer = CAGradientLayer()

    private let switchWidth: CGFloat  = 51
    private let switchHeight: CGFloat = 31
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(titleLabel)
        addSubview(gradientView)
        addSubview(toggleSwitch)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 50),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: trailingAnchor),
            toggleSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            gradientView.centerXAnchor.constraint(equalTo: toggleSwitch.centerXAnchor),
            gradientView.centerYAnchor.constraint(equalTo: toggleSwitch.centerYAnchor),
            //gradientView.widthAnchor.constraint(equalToConstant: switchWidth),
            //gradientView.heightAnchor.constraint(equalToConstant: switchHeight),
        ])
        
        setupGradientView()
        gradientView.isHidden = true
        toggleSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }
    
    private func setupGradientView() {
        gradientLayer.colors = [
            UIColor(red: 0.968, green: 0.767, blue: 0.465, alpha: 1).cgColor,
            UIColor(red: 0.907, green: 0.456, blue: 0.930, alpha: 1).cgColor
        ]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        
        gradientView.layer.cornerRadius = switchHeight / 2
        gradientView.clipsToBounds = true
        
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        gradientView.isUserInteractionEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.frame = toggleSwitch.frame
        gradientView.layer.cornerRadius = toggleSwitch.bounds.height / 2
        gradientLayer.frame = gradientView.bounds
    }
    
    @objc private func switchChanged() {
        gradientView.isHidden = !toggleSwitch.isOn
    }
    
    func syncGradient() {
        gradientView.isHidden = !toggleSwitch.isOn
    }
}

#Preview {
    NotificationToggleView()
}
