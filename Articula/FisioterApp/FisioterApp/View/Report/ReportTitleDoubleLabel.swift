//
//  ReportTitleDoubleLabel.swift
//  FisioterApp
//
//  Created by Pedro Henrique L. Moreiras on 12/04/26.
//

import Foundation
import UIKit

class ReportTitleDoubleLabel: UIView {
    
    let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }()
    
    var topTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Dificuldade"
        label.textColor = .gray
        label.textAlignment = .center
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .light).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 20)
        return label
    }()
    
    var bottomTitle: UILabel = {
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
        addSubview(titleStack)
        addSubview(topTitle)
        addSubview(bottomTitle)
        
        titleStack.addArrangedSubview(topTitle)
        titleStack.addArrangedSubview(bottomTitle)
        // Create the constraints
        NSLayoutConstraint.activate([
            titleStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            
        ])
    }
}

#Preview {
    ReportTitleDoubleLabel()
}
