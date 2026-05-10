//
//  ProgressoView.swift
//  Tropicalia
//
//  Created by Thomas Pinheiro Grandin on 23/04/26.
//

import UIKit

class ProgressoView: UIView {

    var stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()
    let cadastros = ProgressBar(titulo: "Cadastros", progresso: 50)
    let rendimentos = ProgressBar(titulo: "Rendimentos", progresso: 140)
    let pagamentos = ProgressBar(titulo: "Pagamentos", progresso: 80)
    let bens = ProgressBar(titulo: "Bens", progresso: 200)
    let envios = ProgressBar(titulo: "Envios", progresso: 170)
    let dividaseonus = ProgressBar(titulo: "Dívidas e ônus", progresso: 30)
    
    let text: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AfacadFlux-Regular", size: 32)
        label.text = "PROGRESSO"
        return label
    }()
    
    let progressBackground: UIImageView = {
        let img = UIImageView(image: UIImage(named: "progressBackground"))
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        //addSubviews
        addSubview(progressBackground)
        addSubview(text)
        addSubview(stack)
        stack.addArrangedSubview(cadastros)
        stack.addArrangedSubview(rendimentos)
        stack.addArrangedSubview(pagamentos)
        stack.addArrangedSubview(bens)
        stack.addArrangedSubview(envios)
        stack.addArrangedSubview(dividaseonus)
        //constraints
        NSLayoutConstraint.activate([
            progressBackground.widthAnchor.constraint(equalToConstant: 397),
            progressBackground.heightAnchor.constraint(equalToConstant: 561),
            text.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            text.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stack.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.widthAnchor.constraint(equalToConstant: 274)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    return ProgressoView()
}
