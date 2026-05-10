//
//  ButtonView.swift
//  Tropicalia
//
//  Created by Thais Cangucu on 23/04/26.
//

import UIKit

class ButtonView: UIView {
   
    public var newtext: String = "" {
        didSet {
            text.text = newtext
        }
    }
    
    init(newText: String, newSymbol: String) {
        self.text.text = newText
        self.symbolName = newSymbol
        super.init(frame: .zero)
        setupView()
    }
    
    public var symbol: String = "" {
        didSet {
            symbolName = symbol
        }
    }
    var symbolName: String = ""
    
    let text: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont(name: "AfacadFlux-Regular", size: 24)
        view.textColor = .amareloTrop
        view.textAlignment = .right
        view.frame = CGRect(x: 0, y: 0, width: 258.3, height: 29)
        return view
    }()
    
    let image: UIImageView = {
        let view = UIImageView(image: UIImage(named: "buttonBG"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        let symbol: UIImageView = {
            let view = UIImageView(image: UIImage(named: symbolName))
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        addSubview(image)
        addSubview(text)
        addSubview(symbol)
        
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 327),
            image.heightAnchor.constraint(equalToConstant: 59),

            
            text.leadingAnchor.constraint(equalTo: image.leadingAnchor, constant: 16),
            text.centerYAnchor.constraint(equalTo: image.centerYAnchor),
            
            symbol.widthAnchor.constraint(equalToConstant: 26),
            symbol.heightAnchor.constraint(equalToConstant: 26),
            symbol.trailingAnchor.constraint(equalTo: image.trailingAnchor, constant: -16),
            symbol.centerYAnchor.constraint(equalTo: image.centerYAnchor),
        ])
    }
}

#Preview {
    ButtonView(newText: "Adicionar Lançamento", newSymbol: "Mais")
}
