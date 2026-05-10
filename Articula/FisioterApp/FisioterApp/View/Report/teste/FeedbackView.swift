//
//  ExerciseFeedbackView.swift
//  FisioterApp
//
//  Created by Pedro Henrique L. Moreiras on 09/04/26.
//

import Foundation
import UIKit
import CoreData

class FeedbackView: UIViewController{
    
    let viewModel: CoreDataViewModel = CoreDataViewModel()
    
    let difficultiesArray = ["Fácil", "Médio", "Difícil"]
    let autonomyArray = ["Precisei de ajuda", "Não precisei de ajuda"]
    
    var difficultiesOption = ""
    var autonomyOption = ""
    
    let questionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Como você se sentiu \n durante o exercício?"
        label.textColor = .gray
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .medium).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 20)
        
        return label
    }()
    
    let durationLabel: TextLabel = {
        let label = TextLabel(text: "Duração")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var duration: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "2:30"
        label.font = UIFont.systemFont(ofSize: 28)
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .medium).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 30)
        return label
    }()
    
    var painRateLabel: TextLabel = {
        let label = TextLabel(text: "Nível de dor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var painButton: PainButtons = {
        let buttons = PainButtons(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        buttons.translatesAutoresizingMaskIntoConstraints = false
        return buttons
    }()
    
    
    var difficultyLabel: DifficultyLabel = {
        let label = DifficultyLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var textField1: UITextField = {
            let tf = UITextField()
            tf.placeholder = "Selecione a dificuldade"
            tf.borderStyle = .roundedRect
            tf.textAlignment = .center
            tf.translatesAutoresizingMaskIntoConstraints = false
            return tf
        }()
    
    var autonomyLabel: TextLabel = {
        let label = TextLabel(text: "Autonomia")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var textField2: UITextField = {
            let tf = UITextField()
            tf.placeholder = "Selecione a autonomia"
            tf.borderStyle = .roundedRect
            tf.textAlignment = .center
            tf.translatesAutoresizingMaskIntoConstraints = false
            return tf
        }()
    
    let okButton: ButtonView = {
        let button = ButtonView(newtext: "OK", width: 161, height: 60)
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        viewDidLayoutSubviews()
        viewDidAppear(true)
        
        setUp()
        setupConstraints()
        setupPicker()
        setUpBlur()
        durationSetting()
        
    }
    
    override func viewDidLayoutSubviews() {
        let coresGradiente = [
            UIColor(red: 0.968, green: 0.767, blue: 0.465, alpha: 1),
            UIColor(red: 0.907, green: 0.456, blue: 0.93, alpha: 1)
        ]
        let imagemGradiente = UIImage.gradientImage(bounds: duration.bounds, colors: coresGradiente)
        duration.textColor = UIColor(patternImage: imagemGradiente)
    }
    
    func durationSetting(){
        duration.text = viewModel.reports.last?.duration
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.getReport()
    }
    
    func setUp(){
        view.addSubview(questionLabel)
        view.addSubview(durationLabel)
        view.addSubview(duration)
        view.addSubview(painRateLabel)
        view.addSubview(painButton)
        view.addSubview(difficultyLabel)
        view.addSubview(textField1)
        view.addSubview(textField2)
        view.addSubview(autonomyLabel)
        view.addSubview(okButton)
        
        
        let startAction = UIAction { _ in
            self.dismissPopUp()
        }
        okButton.addAction(startAction, for: .touchUpInside)
    }
    
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            // 1. Pergunta Principal
            questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            questionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // 2. Duração
            durationLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 30),
            durationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            duration.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 15),
            duration.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // 3. Nível de Dor
            painRateLabel.topAnchor.constraint(equalTo: duration.bottomAnchor, constant: 35),
            painRateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            painButton.topAnchor.constraint(equalTo: painRateLabel.bottomAnchor, constant: 20),
            painButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // 4. Dificuldade
            difficultyLabel.topAnchor.constraint(equalTo: painButton.bottomAnchor, constant: 51),
            difficultyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField1.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: 10),
            textField1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField1.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            textField1.heightAnchor.constraint(equalToConstant: 45),
            
            // 5. Autonomia
            autonomyLabel.topAnchor.constraint(equalTo: textField1.bottomAnchor, constant: 46),
            autonomyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textField2.topAnchor.constraint(equalTo: autonomyLabel.bottomAnchor, constant: 10),
            textField2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField2.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            textField2.heightAnchor.constraint(equalToConstant: 45),
            
            // 6. Botão OK
            okButton.topAnchor.constraint(equalTo: textField2.bottomAnchor, constant: 67),
            okButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
        ])
    }
    
    func setupPicker() {
            let difficultiesPickerView = UIPickerView()
            let autonomyPickerView = UIPickerView()
            
            difficultiesPickerView.delegate = self
            difficultiesPickerView.dataSource = self
            difficultiesPickerView.tag = 1
            
            autonomyPickerView.delegate = self
            autonomyPickerView.dataSource = self
            autonomyPickerView.tag = 2
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Feito", style: .plain, target: self, action: #selector(self.done))
            toolbar.setItems([doneButton], animated: true)
            toolbar.isUserInteractionEnabled = true
            
            textField1.inputView = difficultiesPickerView
            textField1.inputAccessoryView = toolbar
            
            textField2.inputView = autonomyPickerView
            textField2.inputAccessoryView = toolbar
        }
    
    func setUpBlur(){
        
        let blur: UIVisualEffectView = {
            let effect = UIBlurEffect(style: .systemThinMaterial)
            let view = UIVisualEffectView(effect: effect)
            view.isUserInteractionEnabled = false
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        blur.alpha = 0.99
        view.insertSubview(blur, at: 0)
        
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: view.topAnchor),
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    @objc func done() {
        view.endEditing(true)
    }
    
    
//    @objc private func okButtonAction() {
//        //        let genReport = GeneralReportView()
//        //        genReport.autonomieFeedback = "\(String(describing: textField1.text))"
//        //        genReport.difficultyFeedback = "\(String(describing: textField2.text))"
//        
//        viewModel.updateHabit(autonomy: autonomyOption, difficulty: difficultiesOption, painRate: 3)
//        
//        dismiss(animated: true, completion: nil)
//    }
    

    @objc func dismissPopUp() {
        viewModel.updateHabit(autonomy: autonomyOption, difficulty: difficultiesOption, painRate: 3)
        removeChild()
    }
}



#Preview {
    FeedbackView()
}

