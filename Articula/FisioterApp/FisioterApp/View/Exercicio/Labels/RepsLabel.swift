//
//  CounterView.swift
//  ViewcodeAtividade
//
//  Created by Diego Saragoza Da Silva on 20/03/26.
//

import UIKit

class RepsLabel: UIView {
    
    let counterStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .horizontal
        stack.spacing = 10.0
        return stack
    }()
    
    let counterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .medium).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 16)
        label.textColor = .gray
        label.textAlignment = .center
        label.text = "0"
        return label
    }()
    
    let goalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .medium).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 16)
        label.textColor = .gray
        label.textAlignment = .center
        label.text = "de 5"
        return label
    }()
    
    let repsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .light).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 15)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.text = "repetições"
        return label
    }()

    
    public var counter: Int = 0 {
        didSet {
            counterLabel.text = counter.description
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
    
        // Add subchilds
        addSubview(repsLabel)
        addSubview(counterLabel)
        addSubview(goalLabel)
        addSubview(counterStack)
        
        counterStack.addArrangedSubview(counterLabel)
        counterStack.addArrangedSubview(goalLabel)
        
        // Create the constraints
        NSLayoutConstraint.activate([
            
            counterStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            counterStack.centerYAnchor.constraint(equalTo: centerYAnchor),

            repsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            repsLabel.topAnchor.constraint(equalTo: counterStack.bottomAnchor)
        ])
    }
}

#Preview {
    let counterView = RepsLabel()
    return counterView
}
