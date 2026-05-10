//
//  NotificationViewController.swift
//  YourPush
//
//  Created by Yasmin Mendes  on 08/04/26.
//

import UIKit

class TitleView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleLabel()
    }
    // funcao?
    private func setupTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.text = "Notificação"
        
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        titleLabel.textColor = .gray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

#Preview {
       TitleView()
}

