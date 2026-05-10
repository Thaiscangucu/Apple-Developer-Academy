//
//  ProgressBarView.swift
//  Tropicalia
//
//  Created by Thomas Pinheiro Grandin on 23/04/26.
//

import UIKit

class ProgressBar: UIView {

    var progresso: CGFloat = 0
    var barSize: NSLayoutConstraint!
    let background: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .themeYellow
        view.cornerConfiguration = .capsule()
        return view
    }()
    
    let bar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .themeGreen
        view.cornerConfiguration = .capsule()
        return view
    }()
    let text: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.cornerConfiguration = .capsule()
        label.font = UIFont(name: "AfacadFlux-Light", size: 20)
        return label
    }()
    
    init(titulo: String, progresso: CGFloat = 0) {
        super.init(frame: CGRect())
        text.text = titulo
        self.progresso = progresso
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        //configs
        barSize = bar.trailingAnchor.constraint(equalTo: leadingAnchor, constant: 20 + progresso)
        //addSubviews
        addSubview(text)
        addSubview(background)
        addSubview(bar)
        //constraints
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 59),
            text.topAnchor.constraint(equalTo: topAnchor),
            text.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            background.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -20),
            background.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 8),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            background.heightAnchor.constraint(equalToConstant: 24),
            bar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -20),
            bar.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            bar.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 8),
            bar.heightAnchor.constraint(equalToConstant: 24)
            
        ])
        
        NSLayoutConstraint.activate([barSize])
    }
    
    func setProgresso(_ progresso: CGFloat) {
        self.progresso = progresso
        NSLayoutConstraint.deactivate([barSize])
        barSize = bar.trailingAnchor.constraint(equalTo: leadingAnchor, constant: 20 + progresso)
        NSLayoutConstraint.activate([barSize])
    }

}

#Preview {
    return ProgressBar(titulo: "PLACEHOLDER", progresso: 100)
}
