//
//  ViewController.swift
//  Tropicalia
//
//  Created by Dayô Araújo on 23/04/26.
//

import UIKit

class LancamentosViewController: UIViewController {
    
    let progresso: ProgressoView = {
        let view = ProgressoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let prazosImportantes: UIView = {
        let view = PrazosImportantesView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let headerBackground: UIImageView = {
        let view = UIImageView(image: UIImage(named: "headerBackground"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let header: UIView = {
       let view = Header()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let alertView: AlertCardView = {
        let view = AlertCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let toggle: ToggleView = {
        let button = ToggleView(newText: "Declaração Completa")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubviews()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .yellowBackground
    }
    
    private func setupSubviews() {
        view.addSubview(headerBackground)
        view.addSubview(prazosImportantes)
        view.addSubview(progresso)
        view.addSubview(header)
        view.addSubview(alertView)
        view.addSubview(toggle)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerBackground.topAnchor.constraint(equalTo: view.topAnchor),
            headerBackground.widthAnchor.constraint(equalTo: view.widthAnchor),
            headerBackground.heightAnchor.constraint(equalToConstant: 450),
            header.topAnchor.constraint(equalTo: view.topAnchor),
            
            prazosImportantes.topAnchor.constraint(equalTo: headerBackground.bottomAnchor, constant: -90),
            
            toggle.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 15),
            toggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80),
            
            progresso.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progresso.widthAnchor.constraint(equalToConstant: 400),
            progresso.heightAnchor.constraint(equalToConstant: 560),
            progresso.topAnchor.constraint(equalTo: prazosImportantes.bottomAnchor, constant: 180),
            
            alertView.topAnchor.constraint(equalTo: headerBackground.bottomAnchor, constant: 10),
            alertView.leadingAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

#Preview {
    let main = LancamentosViewController()
    main
}
