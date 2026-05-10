//
//  CounterView.swift
//  ViewcodeAtividade
//
//  Created by Diego Saragoza Da Silva on 20/03/26.
//

import UIKit

class DescriptionLabel: UIView {
    
    init(text1: String){
        self.text1 = text1
        super.init(frame: .zero)
        setupView()
    }
    
    public var text1 : String = ""{
        didSet {
            instructionLabel.text = text1
        }
    }
    
    lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont(name: "Montserrat-Regular", size: 20)
        label.textColor = .gray
        label.textAlignment = .center
        label.text = text1
        label.numberOfLines = 10

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
        addSubview(instructionLabel)
        
        
        // Create the constraints
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            instructionLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            instructionLabel.widthAnchor.constraint(equalToConstant: 350),
//            instructionLabel.heightAnchor.constraint(equalToConstant: 50),
            instructionLabel.topAnchor.constraint(equalTo: topAnchor),
            instructionLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            instructionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            instructionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

#Preview {
    let counterView = DescriptionLabel(text1: "Mantenha o aparelho na horizontal, com a tela voltada para cima. Flexione o pulso suavemente, inclinando o celular para a baixo e para cima.")
    counterView
}
