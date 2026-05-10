//
//  Exercise.swift
//  FisioterApp
//
//  Created by Thais Cangucu on 30/03/26.
//

//
//  CollectionCell.swift
//  Atividade2
//
//  Created by Thais Cangucu on 25/03/26.
//

import UIKit

class StartButton: UIButton {
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("Confirmar", for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 267, height: 52)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        buttonSetup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buttonSetup()
    }
    
    func buttonSetup() {
        addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 267),
            button.heightAnchor.constraint(equalToConstant: 52),
            button.topAnchor.constraint(equalTo: self.topAnchor),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}

#Preview{
    let ExerciseView = StartButton()
    ExerciseView
}
