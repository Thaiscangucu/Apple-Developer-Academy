//
//  ReportTitleDoubleLabel.swift
//  FisioterApp
//
//  Created by Thais Cangucu on 16/04/26.
//


//
//  ReportTitleDoubleLabel.swift
//  FisioterApp
//
//  Created by Pedro Henrique L. Moreiras on 12/04/26.
//

import Foundation
import UIKit

class DifficultyLabel: UIView {
        
    var difficultyLabel: TextLabel = {
        let label = TextLabel(text: "Dificuldade")
        return label
    }()
    
    var secondLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "ao realizar o exercício"
        label.textColor = UIColor(red: 0.402, green: 0.402, blue: 0.402, alpha: 1)
        label.textAlignment = .center
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .light).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 12)
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
        // add subviews
        addSubview(difficultyLabel)
        addSubview(secondLabel)
        
        // Create the constraints
        NSLayoutConstraint.activate([
            difficultyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            difficultyLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            secondLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            secondLabel.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: 20),
        ])
    }
}

#Preview {
    DifficultyLabel()
}
