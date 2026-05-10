//
//  PrazosImportantesView.swift
//  Tropicalia
//
//  Created by Thomas Pinheiro Grandin on 24/04/26.
//

import UIKit

class PrazosImportantesView: UIView {
    
    let titulo: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AfacadFlux-Regular", size: 32)
        label.text = "Prazos Importantes"
        return label
    }()
    let entrega: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AfacadFlux-Light", size: 20)
        label.text = "Entrega da declaração"
        return label
    }()
    let dias: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AfacadFlux-Light", size: 20)
        label.text = "Dias restantes"
        return label
    }()
    let entregaData: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AfacadFlux-Light", size: 20)
        label.text = "01/05/2026"
        return label
    }()
    let diasNumero: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AfacadFlux-Light", size: 20)
        label.text = "7 dias"
        return label
    }()
    let prazosBackground: UIImageView = {
        let img = UIImageView(image: UIImage(named: "prazosBackground"))
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        //addSubviews
        addSubview(prazosBackground)
        addSubview(titulo)
        addSubview(entrega)
        addSubview(entregaData)
        addSubview(dias)
        addSubview(diasNumero)
        //constraints
        NSLayoutConstraint.activate([
            prazosBackground.widthAnchor.constraint(equalToConstant: 393),
            prazosBackground.heightAnchor.constraint(equalToConstant: 152),
            titulo.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titulo.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            entrega.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            entrega.topAnchor.constraint(equalTo: titulo.bottomAnchor, constant: 8),
            entregaData.topAnchor.constraint(equalTo: entrega.bottomAnchor, constant: 1),
            entregaData.leadingAnchor.constraint(equalTo: entrega.leadingAnchor),
            dias.topAnchor.constraint(equalTo: titulo.bottomAnchor, constant: 8),
            dias.leadingAnchor.constraint(equalTo: entrega.trailingAnchor, constant: 24),
            diasNumero.topAnchor.constraint(equalTo: dias.bottomAnchor, constant: 1),
            diasNumero.leadingAnchor.constraint(equalTo: dias.leadingAnchor)
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    return PrazosImportantesView()
}
