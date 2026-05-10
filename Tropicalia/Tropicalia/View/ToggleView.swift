//
//  ButtonView.swift
//  Tropicalia
//
//  Created by Thais Cangucu on 23/04/26.
//

import UIKit

class ToggleView: UIView {
   
    public var newtext: String = "" {
        didSet {
            text.text = newtext
        }
    }
    
    init(newText: String) {
        self.text.text = newText
        super.init(frame: .zero)
        setupView()
    }
    
    let text: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont(name: "Barriecito-Regular", size: 25)
        view.textColor = .amareloTrop
        view.textAlignment = .right
        view.frame = CGRect(x: 0, y: 0, width: 258.3, height: 29)
        return view
    }()
    
    let image: UIImageView = {
        let view = UIImageView(image: UIImage(named: "toggleBG"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let toggle: Toggle = {
        let button = Toggle()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }


    private func setupView() {
        
        addSubview(image)
        addSubview(text)
        addSubview(toggle)
        
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 312),
            image.heightAnchor.constraint(equalToConstant: 73),
            image.topAnchor.constraint(equalTo: topAnchor),
            image.bottomAnchor.constraint(equalTo: bottomAnchor),
            image.leadingAnchor.constraint(equalTo: leadingAnchor),
            image.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            text.leadingAnchor.constraint(equalTo: image.leadingAnchor, constant: 16),
            text.centerYAnchor.constraint(equalTo: image.centerYAnchor, constant: 3),
            
            toggle.widthAnchor.constraint(equalToConstant: 33),
            toggle.heightAnchor.constraint(equalToConstant: 58),
            toggle.leadingAnchor.constraint(equalTo: text.trailingAnchor, constant: 30),
            toggle.topAnchor.constraint(equalTo: topAnchor, constant: 6),
        ])
    }
}

#Preview {
    ToggleView(newText: "Declaração Completa")
}
