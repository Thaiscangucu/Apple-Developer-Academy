//
//  ConfirmView.swift
//  YourPush
//
//  Created by Yasmin Mendes  on 08/04/26.
//


import UIKit

class ConfirmView: UIView {

    private let confirmGradientLayer = CAGradientLayer()
    
    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("confirmar", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .bold)
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .semibold).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        button.titleLabel?.font = UIFont(descriptor: descriptor, size: 25)
        button.backgroundColor = .clear
        button.clipsToBounds = true
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    let deleteButton: UIButton = {
        let button = UIButton()
//        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
//        let image = UIImage(systemName: "x.circle", withConfiguration: config)
        let image = UIImage(named: "deleteButton")
        
        button.setImage(image, for: .normal)
//        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill

        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        
//        addSubview(deleteButton)
        addSubview(confirmButton)
        
        confirmGradientLayer.colors = [
            UIColor(red: 0.968, green: 0.767, blue: 0.465, alpha: 1).cgColor,
            UIColor(red: 0.907, green: 0.456, blue: 0.930, alpha: 1).cgColor
        ]
        confirmGradientLayer.locations = [0, 1]
        confirmGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        confirmGradientLayer.endPoint   = CGPoint(x: 0.5, y: 1)
        confirmGradientLayer.cornerRadius = 26
        confirmButton.layer.insertSublayer(confirmGradientLayer, at: 0)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52),

//            deleteButton.leadingAnchor.constraint(equalTo: leadingAnchor),
//            //deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
//            deleteButton.widthAnchor.constraint(equalToConstant: 60),
//            deleteButton.heightAnchor.constraint(equalToConstant: 60),

            confirmButton.leadingAnchor.constraint(equalTo: trailingAnchor, constant: 13),
            confirmButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            //confirmButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 200),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        confirmGradientLayer.frame = confirmButton.bounds
    }
}

#Preview {
    ConfirmView()
}
