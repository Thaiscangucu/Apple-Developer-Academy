//
//  Header.swift
//  Tropicalia
//
//  Created by Dayô Araújo on 23/04/26.
//

import UIKit

class Header: UIView {
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    let viewTitle: Title = {
       let view = Title(newText: "Dashboard")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let restitution: RestituicaoView = {
        let t = RestituicaoView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    let tax: ImpostoView = {
        let t = ImpostoView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    func setupView() {
        addSubview(viewTitle)
        addSubview(tax)
        addSubview(restitution)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: trailingAnchor),
            
            viewTitle.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            viewTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            
            restitution.topAnchor.constraint(equalTo: viewTitle.bottomAnchor, constant: 22),
            restitution.leadingAnchor.constraint(equalTo: viewTitle.leadingAnchor),
            
            tax.topAnchor.constraint(equalTo: restitution.topAnchor),
            tax.leadingAnchor.constraint(equalTo: restitution.trailingAnchor, constant: 60),
        ])
    }
}

#Preview {
    let header = Header()
    header
}
