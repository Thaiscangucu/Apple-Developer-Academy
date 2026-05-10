//
//  AlertComponent.swift
//  Tropicalia
//
//  Created by anshu Li on 23/04/26.
//

import Foundation
import UIKit


class AlertComponent: UIView {
    
    public var newtext: String = "" {
        didSet {
            text.text = newtext
        }
    }
    
    public var imageStar: String = "" {
        didSet {
            stringImage = imageStar
        }
    }
    
    var stringImage = ""
    
    init(newText: String, image: String) {
        self.text.text = newText
        self.stringImage = image
        super.init(frame: .zero)
        setupView()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    
    let text: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont(name: "AfacadFlux-Light", size: 20)
        view.textColor = .amareloTrop
        return view
    }()
    
    
    
    private func setupView() {

        // Setup the view
        let starImage: UIImageView = {
            let view = UIImageView(image: UIImage(named: stringImage))
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        addSubview(starImage)
        addSubview(text)
        // Create the constraints
        NSLayoutConstraint.activate([
            starImage.widthAnchor.constraint(equalToConstant: 33),
            starImage.heightAnchor.constraint(equalToConstant: 33),
            text.centerYAnchor.constraint(equalTo: starImage.centerYAnchor),
            text.leadingAnchor.constraint(equalTo: starImage.trailingAnchor, constant: 12),
        ])
    }
}

#Preview {
    let ac = AlertComponent(newText: "Dívidas e ônus reais ausentes", image: "Star1")
    ac
}
