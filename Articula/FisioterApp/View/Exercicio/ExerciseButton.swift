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
//
//class ExerciseButton: UIButton {
//    
//    let button: UIButton = {
//        let button = UIButton()
//        button.setTitle("Exercício 1", for: .normal)
//        button.layer.cornerRadius = 38
//        button.configuration = .filled()
//        button.frame = CGRect(x: 0, y: 0, width: 291, height: 99)
//        button.layer.backgroundColor = UIColor(red: 0.851, green: 0.851, blue: 0.851, alpha: 0.2).cgColor
////        button.tintColor = UIColor(red: 0.851, green: 0.851, blue: 0.851, alpha: 0.2)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        buttonSetup()
//    }
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        buttonSetup()
//        
//    }
//    func buttonSetup() {
//        addSubview(button)
//        NSLayoutConstraint.activate([
//            button.centerXAnchor.constraint(equalTo: centerXAnchor),
//            button.centerYAnchor.constraint(equalTo: centerYAnchor),
//            button.widthAnchor.constraint(equalToConstant: 291),
//            button.heightAnchor.constraint(equalToConstant: 99),
//        ])
//    }
//}


class ExerciseButton: UIButton {
    
    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemThinMaterial)
        let view = UIVisualEffectView(effect: effect)
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
//    public var number: String = "" {
//        didSet {
//            self.setTitle(number, for: .normal)
//        }
//    }
    
    public var newText: String = "" {
        didSet {
            self.setTitle(newText, for: .normal)
        }
    }
    

    init(newtext: String) {
        self.newText = newtext
        super.init(frame: .zero)
        setupButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    private func setupButton() {
        
        blurView.alpha = 0.8
        insertSubview(blurView, at: 0)
//        backgroundColor = .white
        
        setTitle(newText, for: .normal)
        
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .regular).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        titleLabel?.font = UIFont(descriptor: descriptor, size: 26)
        setTitleColor(UIColor(red: 0.402, green: 0.402, blue: 0.402, alpha: 1), for: .normal)
        layer.cornerRadius = 38
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.widthAnchor.constraint(equalToConstant: 291),
            blurView.heightAnchor.constraint(equalToConstant: 99),
        ])
    }
    
}

#Preview{
    let ExerciseView = ExerciseButton(newtext: "Punho")
    ExerciseView
}
