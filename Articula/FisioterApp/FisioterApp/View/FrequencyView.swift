//
//  FrequencyView.swift
//  FisioterApp
//
//  Created by Yasmin Mendes  on 10/04/26.
//

import UIKit

class FrequencyView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Frequência"
        label.textColor = .darkGray
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .light).fontDescriptor
                    .addingAttributes([
                        .traits: [UIFontDescriptor.TraitKey.width: 0.5]
                    ])
        label.font = UIFont(descriptor: descriptor, size: 20)
        return label
    }()
    
    private let days: [(title: String, key: String)] = [
        ("D","D"),
        ("S","S2"),
        ("T","T"),
        ("Q","Q"),
        ("Q","Q2"),
        ("S","S"),
        ("S","S3")
    ]
    
    private var buttons: [UIButton] = []
    
    // Nome da layer de gradiente nos botões, para identificar e remover
    private let buttonGradientLayerName = "buttonGradient"
    
    var selectedIndexes: [Int] {
        var result: [Int] = []
        for (index, button) in buttons.enumerated() {
            if buttonHasGradient(button) {
                result.append(index)
            }
        }
        return result
    }
    
    var selectedDays: [String] {
        var result: [String] = []
        for (index, button) in buttons.enumerated() {
            if buttonHasGradient(button) {
                result.append(days[index].key)
            }
        }
        return result
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(label)
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        
        addSubview(stack)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 27),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.heightAnchor.constraint(equalToConstant: 40),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        for day in days {
            let button = UIButton(type: .system)
            button.setTitle(day.title, for: .normal)
           // button.backgroundColor = .lightGray
            button.backgroundColor = UIColor(red: 0.514, green: 0.165, blue: 0.165, alpha: 0.16)
            button.layer.cornerRadius = 14
            button.clipsToBounds = true
            button.setTitleColor(.black, for: .normal)
            
            button.addTarget(self, action: #selector(toggleDay(_:)), for: .touchUpInside)
            
            buttons.append(button)
            stack.addArrangedSubview(button)
        }
    }
    
    @objc private func toggleDay(_ sender: UIButton) {
        if buttonHasGradient(sender) {

            removeGradient(from: sender)
            sender.backgroundColor = UIColor(red: 0.514, green: 0.165, blue: 0.165, alpha: 0.16)
            sender.setTitleColor(.black, for: .normal)
        } else {
            sender.backgroundColor = .clear
            applyGradient(to: sender)
            sender.setTitleColor(.white, for: .normal)
        }
    }
    
    private func applyGradient(to button: UIButton) {
        let gradient = CAGradientLayer()
        gradient.name = buttonGradientLayerName
        gradient.colors = [
            UIColor(red: 0.968, green: 0.767, blue: 0.465, alpha: 1).cgColor,
            UIColor(red: 0.907, green: 0.456, blue: 0.930, alpha: 1).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.frame = button.bounds
        gradient.cornerRadius = button.layer.cornerRadius

        button.layer.insertSublayer(gradient, at: 0)
    }
    
    private func removeGradient(from button: UIButton) {
        button.layer.sublayers?
            .filter { $0.name == buttonGradientLayerName }
            .forEach { $0.removeFromSuperlayer() }
    }
    
    private func buttonHasGradient(_ button: UIButton) -> Bool {
        return button.layer.sublayers?.contains(where: { $0.name == buttonGradientLayerName }) ?? false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
        self.layer.cornerRadius = 26

        for button in buttons {
            button.layer.sublayers?
                .filter { $0.name == buttonGradientLayerName }
                .forEach { $0.frame = button.bounds }
        }
    }
}

#Preview {
    FrequencyView()
}
