//
//  OverLayerPopUp.swift
//  FisioterApp
//
//  Created by Thais Cangucu on 08/04/26.
//

import UIKit

class ExercisePopUp: UIViewController {
    
    private let blur: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemThinMaterial)
        let view = UIVisualEffectView(effect: effect)
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let instructions: InstructionsLabels = {
        let view = InstructionsLabels(text1: "Mova o celular", text2: "de baixo para cima")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let image: UIImageView = {
        let view = UIImageView(image: UIImage(named: "Exercise"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let descriptions: DescriptionLabel = {
        let view = DescriptionLabel(text1: "Segure o aparelho com a mão lesionada na vertical, com a tela voltada para cima. Flexione o pulso suavemente, inclinando o celular para a cima e para baixo.")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let button: ButtonView = {
        let view = ButtonView(newtext: "Confirmar", width: 240, height: 60)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let VStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        blur.alpha = 0.99
        view.insertSubview(blur, at: 0)
        
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: view.topAnchor),
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        

        let startAction = UIAction { _ in
            self.dismissPopUp()
        }
        button.addAction(startAction, for: .touchUpInside)
        
        view.addSubview(instructions)
        view.addSubview(image)
        view.addSubview(descriptions)
        view.addSubview(button)
        
    
        NSLayoutConstraint.activate([
            instructions.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructions.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            
            image.centerXAnchor.constraint(equalTo: instructions.centerXAnchor),
            image.widthAnchor.constraint(equalToConstant: 150),
            image.heightAnchor.constraint(equalToConstant: 180),
            image.topAnchor.constraint(equalTo: instructions.bottomAnchor),
            
            descriptions.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 18),
            descriptions.centerXAnchor.constraint(equalTo: image.centerXAnchor),
            descriptions.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20), // Padding lateral
            descriptions.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            button.topAnchor.constraint(equalTo: descriptions.bottomAnchor, constant: 27),
            button.centerXAnchor.constraint(equalTo: image.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
        ])
    }
    @objc func dismissPopUp() {
        removeChild()
    }
    
}

#Preview {
    let counterVC = ExercisePopUp()
    return counterVC.view
}
