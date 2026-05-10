//
//  Header.swift
//  Tropicalia
//
//  Created by Dayô Araújo on 23/04/26.
//

import UIKit

class RestituicaoView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    let restitutionBackground: UIImageView = {
        let i = UIImageView(image: UIImage(named: "highlightDisplay"))
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let restitution: UILabel = {
        let t = UILabel()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.text = "RESTITUIÇÃO PREVISTA"
        t.font = UIFont(name: "AfacadFlux-Light", size: 24)
    
        return t
    }()
    
    let restitutionValue: UILabel = {
        let t = UILabel()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.text = "R$5430,72"
        t.textColor = .tropicalGreen
        t.font = UIFont(name: "Barriecito-Regular", size: 50)
        return t
    }()
    
    func setupView() {
    
        addSubview(restitutionBackground)
        addSubview(restitution)
        addSubview(restitutionValue)
        
        NSLayoutConstraint.activate([

            restitutionBackground.widthAnchor.constraint(equalToConstant: 355),
            restitutionBackground.heightAnchor.constraint(equalToConstant: 134),
    
            restitutionBackground.topAnchor.constraint(equalTo: topAnchor),
            restitutionBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            restitutionBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            restitutionBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            restitution.topAnchor.constraint(equalTo: restitutionBackground.topAnchor, constant: 22),
            restitution.leadingAnchor.constraint(equalTo: restitutionBackground.leadingAnchor, constant: 57),
            
            restitutionValue.topAnchor.constraint(equalTo: restitution.topAnchor, constant: 20),
            restitutionValue.leadingAnchor.constraint(equalTo: restitution.leadingAnchor),

        ])
    }
}

#Preview {
    let header = RestituicaoView()
    header
}
