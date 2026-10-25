//
//  TextLabel.swift
//  FisioterApp
//
//  Created by Thais Cangucu on 16/04/26.
//


import Foundation
import UIKit

class TextLabel: UIView {
    
    init(text: String){
        self.text = text
        super.init(frame: .zero)
        setupView()
    }
    
    public var text : String = ""{
        didSet {
            textLabel.text = text
        }
    }

    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = .gray
        label.textAlignment = .center
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .light).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 20)
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

        addSubview(textLabel)
        
        // Create the constraints
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}


#Preview {
    TextLabel(text: "Dificuldade")
}
