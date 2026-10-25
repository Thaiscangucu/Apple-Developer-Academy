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

class ExerciseView: UIButton {
    
    let instructions: InstructionsLabels = {
        let view = InstructionsLabels(text1: "Mova o celular", text2: "de baixo para cima")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let capsule: UIView = {
        let view = CapsuleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let circle: UIImageView = {
        let view = UIImageView(image: UIImage(named: "exerciseCircle"))
//        view.center.y =
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var counter: RepsLabel = {
        let view = RepsLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        backgroundColor = .white

        // Add subchilds
        addSubview(instructions)
        addSubview(counter)
        addSubview(capsule)
        addSubview(circle)

        
        //Create the constraints
        NSLayoutConstraint.activate([
            instructions.centerXAnchor.constraint(equalTo: centerXAnchor),
            instructions.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: -300),
            
            counter.centerXAnchor.constraint(equalTo: centerXAnchor),
            counter.topAnchor.constraint(equalTo: instructions.bottomAnchor, constant: 500),
            
            circle.widthAnchor.constraint(equalToConstant: 168),
            circle.heightAnchor.constraint(equalToConstant: 168),
            circle.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            capsule.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            capsule.centerYAnchor.constraint(equalTo: centerYAnchor),
            
        ])
    }
}



#Preview{
    let ExerciseView = ExerciseView()
    ExerciseView
}
