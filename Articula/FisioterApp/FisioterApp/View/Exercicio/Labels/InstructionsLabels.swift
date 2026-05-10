//
//  CounterView.swift
//  ViewcodeAtividade
//
//  Created by Diego Saragoza Da Silva on 20/03/26.
//

import UIKit

class InstructionsLabels: UIView {
    
    let counterStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    init(text1: String, text2: String){
        self.text1 = text1
        self.text2 = text2
        super.init(frame: .zero)
        setupView()
    }
    
    public var text1 : String = ""{
        didSet {
            instructionLabel.text = text1
        }
    }
    
    public var text2 : String = ""{
        didSet {
            instruction2Label.text = text2
        }
    }
    
    lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .medium).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 28)
        label.textColor = .gray
        label.textAlignment = .center
        label.text = text1
        return label
    }()
    
    lazy var instruction2Label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .light).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 20)
        label.textColor = .gray
        label.textAlignment = .center
        label.text = text2
        return label
    }()
    
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
//        addSubview(instructionLabel)
//        addSubview(instruction2Label)
        addSubview(counterStack)
        
        counterStack.addArrangedSubview(instructionLabel)
        counterStack.addArrangedSubview(instruction2Label)
        
        // Create the constraints
        NSLayoutConstraint.activate([
            counterStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            counterStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            counterStack.topAnchor.constraint(equalTo: topAnchor),
            counterStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            counterStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            counterStack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

#Preview {
    let counterView = InstructionsLabels(text1: "Mova a bolinha", text2: "de cima para baixo")
    return counterView
}
