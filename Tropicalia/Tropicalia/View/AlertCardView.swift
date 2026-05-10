//
//  AlertCardView.swift
//  Tropicalia
//
//  Created by anshu Li on 23/04/26.
//

import Foundation
import UIKit


class AlertCardView: UIView {
    
    let backgroundImage: UIImageView = {
        let view = UIImageView(image: UIImage(named: "Rectangle1"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let title: UILabel = {
        let view = UILabel()
        view.text = "PENDÊNCIAS E ALERTAS"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont(name: "AfacadFlux-Regular", size: 32)
        view.textColor = .amareloTrop
        return view
    }()
    
    let alertStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .vertical
        stack.spacing = 40
        return stack
    }()
    
    let topic1: AlertComponent = {
        let view = AlertComponent(newText: "Dívidas e ônus reais ausentes", image: "Star1")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let topic2: AlertComponent = {
        let view = AlertComponent(newText: "Bens e direitos incompletos", image: "Star1")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let topic3: AlertComponent = {
        let view = AlertComponent(newText: "Importar informe do banco", image: "Star2")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let topic4: AlertComponent = {
        let view = AlertComponent(newText: "CPF de dependentes validados", image: "Star3")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let topic5: AlertComponent = {
        let view = AlertComponent(newText: "DIRF conferida automaticamente", image: "Star3")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 85
        return stack
    }()
    
    let button1: ButtonView = {
        let square = ButtonView(newText: "Adicionar lançamento", newSymbol: "Mais")
        square.translatesAutoresizingMaskIntoConstraints = false
        return square
    }()
    let button2: ButtonView = {
        let square = ButtonView(newText: "Importar documentos", newSymbol: "setaCima")
        square.translatesAutoresizingMaskIntoConstraints = false
        return square
    }()
    let button3: ButtonView = {
        let square = ButtonView(newText: "Revisar e enviar", newSymbol: "setaDireita")
        square.translatesAutoresizingMaskIntoConstraints = false
        return square
    }()
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {

        addSubview(backgroundImage)
        addSubview(title)
        addSubview(alertStack)
        alertStack.addArrangedSubview(topic1)
        alertStack.addArrangedSubview(topic2)
        alertStack.addArrangedSubview(topic3)
        alertStack.addArrangedSubview(topic4)
        alertStack.addArrangedSubview(topic5)
        
        addSubview(buttonStack)
        buttonStack.addArrangedSubview(button1)
        buttonStack.addArrangedSubview(button2)
        buttonStack.addArrangedSubview(button3)
        
        NSLayoutConstraint.activate([
            backgroundImage.widthAnchor.constraint(equalToConstant: 397),
            backgroundImage.heightAnchor.constraint(equalToConstant: 318),
//            backgroundImage.topAnchor.constraint(equalTo: topAnchor),
//            backgroundImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            title.leadingAnchor.constraint(equalTo: backgroundImage.leadingAnchor, constant: 34),
            title.topAnchor.constraint(equalTo: backgroundImage.topAnchor, constant: 18),
            alertStack.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            alertStack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 17),
            
            buttonStack.topAnchor.constraint(equalTo: backgroundImage.bottomAnchor, constant: 32),
            buttonStack.leadingAnchor.constraint(equalTo: backgroundImage.leadingAnchor),
        ])
        
    }
    
}

#Preview {
    let ac = AlertCardView()
    ac
}
