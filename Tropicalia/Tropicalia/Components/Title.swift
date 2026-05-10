//
//  Header.swift
//  Tropicalia
//
//  Created by Dayô Araújo on 23/04/26.
//

import UIKit

class Title: UIView {
    
    public var newtext: String = "" {
        didSet {
            title.text = newtext
        }
    }
    
    init(newText: String) {
        self.title.text = newText
        super.init(frame: .zero)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    let title: UILabel = {
        let t = UILabel()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.textColor = .yellowBackground
        t.font = UIFont(name: "Barriecito-Regular", size: 65)
        return t
    }()
    
    let titleBackground: UIImageView = {
        let i = UIImageView(image: UIImage(named: "greenRect"))
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    func setupView() {
        addSubview(titleBackground)
        addSubview(title)
        
        NSLayoutConstraint.activate([
            titleBackground.widthAnchor.constraint(equalToConstant: 410),
            titleBackground.heightAnchor.constraint(equalToConstant: 118),
            
            titleBackground.topAnchor.constraint(equalTo: topAnchor),
            titleBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            titleBackground.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleBackground.topAnchor.constraint(equalTo: topAnchor),
            title.centerYAnchor.constraint(equalTo: titleBackground.centerYAnchor),
            title.centerXAnchor.constraint(equalTo: titleBackground.centerXAnchor),
        ])
    }
}

#Preview {
    let header = Title(newText: "Dashboard")
    header
}
