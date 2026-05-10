//
//  Header.swift
//  Tropicalia
//
//  Created by Dayô Araújo on 23/04/26.
//

import UIKit

class ImpostoView: UIView {
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
    
    let taxBackground: UIImageView = {
        let i = UIImageView(image: UIImage(named: "highlightDisplayRight"))
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let tax: UILabel = {
        let t = UILabel()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.text = "IMPOSTO A PAGAR"
        t.font = UIFont(name: "AfacadFlux-Light", size: 24)
        return t
    }()
    
    let taxValue: UILabel = {
        let t = UILabel()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.text = "R$9812,76"
        t.textColor = .tropicalRed
        t.font = UIFont(name: "Barriecito-Regular", size: 60)
        return t
    }()
    
    func setupView() {
    
        addSubview(taxBackground)
        addSubview(tax)
        addSubview(taxValue)
        
        NSLayoutConstraint.activate([

            taxBackground.widthAnchor.constraint(equalToConstant: 355),
            taxBackground.heightAnchor.constraint(equalToConstant: 134),
    
            taxBackground.topAnchor.constraint(equalTo: topAnchor),
            taxBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            taxBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            taxBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            tax.topAnchor.constraint(equalTo: taxBackground.topAnchor, constant: 22),
            tax.leadingAnchor.constraint(equalTo: taxBackground.leadingAnchor, constant: 23),
            taxValue.topAnchor.constraint(equalTo: tax.topAnchor, constant: 20),
            taxValue.leadingAnchor.constraint(equalTo: tax.leadingAnchor),

        ])
    }
}

#Preview {
    let header = ImpostoView()
    header
}
