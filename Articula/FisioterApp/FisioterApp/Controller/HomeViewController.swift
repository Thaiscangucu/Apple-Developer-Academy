//
//  ViewController.swift
//  FisioterApp
//
//  Created by Camila Parolin on 30/03/26.
//

import UIKit

class HomeViewController: UIViewController {
    
    let label: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 146, height: 65.3)
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .regular).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 20)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Foco\nPaciência Evolução"
        label.textColor = UIColor(red: 0.402, green: 0.402, blue: 0.402, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let exerciseScreen = ExerciseViewController()
    let exerciseButton: ExerciseButton = {
        let button = ExerciseButton(newtext: "Punho")
        return button
    }()
    let exercise2Button: ExerciseButton = {
        let button = ExerciseButton(newtext: "Ombro")
        return button
    }()
    let exercise3Button: ExerciseButton = {
        let button = ExerciseButton(newtext: "Tornozelo")
        return button
    }()
    
    let notificationsView = NotificationSheetViewController()
    let notificationsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "bell"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let reportView = GRViewController()
    let reportButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "report"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var viewlModel = CoreDataViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButton()
    }
    
    func setUpButton(){
        
        //Background
        let backgroundImage = UIImageView(frame: self.view.bounds)
        backgroundImage.image = UIImage(named: "background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
        view.backgroundColor = .white
        
        //Add subviews
        view.addSubview(label)
        view.addSubview(exerciseButton)
//        view.addSubview(exercise2Button)
//        view.addSubview(exercise3Button)
        view.addSubview(notificationsButton)
//        view.addSubview(reportButton)
        
        //Buttons actions setting
        exerciseButton.addTarget(self, action: #selector(goToExerciseScreen), for: .touchUpInside)
        notificationsButton.addTarget(self, action: #selector(goToNotificationScreen), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(goToReportScreen), for: .touchUpInside)
        
//        addChildController(popUp, frame: view.bounds.insetBy(dx: 10, dy: 150))
        
        //Constraints
        NSLayoutConstraint.activate([
//            reportButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            reportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
//            reportButton.widthAnchor.constraint(equalToConstant: 32),
//            reportButton.heightAnchor.constraint(equalToConstant: 36),
            
            notificationsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            notificationsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            notificationsButton.widthAnchor.constraint(equalToConstant: 32),
            notificationsButton.heightAnchor.constraint(equalToConstant: 36),
            
            label.widthAnchor.constraint(equalToConstant: 146),
            label.topAnchor.constraint(equalTo: notificationsButton.bottomAnchor, constant: 41),
            label.topAnchor.constraint(equalTo: notificationsButton.bottomAnchor, constant: 41),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 67),
            
            exerciseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exerciseButton.widthAnchor.constraint(equalToConstant: 291),
            exerciseButton.heightAnchor.constraint(equalToConstant: 99),
            exerciseButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 66),
            
//            exercise2Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            exercise2Button.topAnchor.constraint(equalTo: exerciseButton.bottomAnchor, constant: 32),
//            exercise2Button.widthAnchor.constraint(equalToConstant: 291),
//            exercise2Button.heightAnchor.constraint(equalToConstant: 99),
            
//            exercise3Button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            exercise3Button.topAnchor.constraint(equalTo: exercise2Button.bottomAnchor, constant: 32),
//            exercise3Button.widthAnchor.constraint(equalToConstant: 291),
//            exercise3Button.heightAnchor.constraint(equalToConstant: 99),
        ])
    }
    
    // Other screens functions
    @objc func goToExerciseScreen() {
        print("clicado")
        navigationController?.pushViewController(exerciseScreen, animated: true)
    }
    @objc func goToReportScreen() {
        navigationController?.pushViewController(reportView, animated: true)
    }
    
    @objc func goToNotificationScreen() {
        navigationController?.pushViewController(notificationsView, animated: true)
    }
}

#Preview{
    let vc = HomeViewController()
    return vc.view
}



