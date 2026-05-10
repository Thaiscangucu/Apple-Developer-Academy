//
//  ExerciseFeedbackView.swift
//  FisioterApp
//
//  Created by Pedro Henrique L. Moreiras on 09/04/26.
//

import Foundation
import UIKit
import CoreData

class ExerciseFeedbackView: UIViewController {
    
    let viewModel: CoreDataViewModel = CoreDataViewModel()
    
    let difficultiesArray = ["Fácil", "Médio", "Difícil"]
    let autonomyArray = ["Precisei de ajuda", "Não precisei de ajuda"]
    
    var difficultiesOption = ""
    var autonomyOption = ""
    
    var dificultyTextField: UITextField!
    var autonomyTextField: UITextField!
    
    let okButton: ButtonView = {
            let button = ButtonView(newtext: "OK", width: 240, height: 60)
            return button
        }()
    
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
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Duração"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 22)
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .light).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 20)
        
        return label
    }()
    var duration: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 28)
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .medium).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 30)
        return label
    }()
    
    var painRateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Nível de dor"
        label.textColor = .gray
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .light).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 20)
        return label
    }()
    
    var difficultyLabel: ReportTitleDoubleLabel = {
        let label = ReportTitleDoubleLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var autonomyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Autonomia"
        label.textColor = .gray
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .light).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 20)
        return label
    }()
    
    var levelButtons: [UIButton] = []
    
    let buttonStack: UIStackView = {
        let stack = UIStackView()
        
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadView()
        self.levelButtons.forEach { button in
            button.addTarget(self, action: #selector(painLevelSelected(_:)), for: .touchUpInside)
        }
        viewModel.getReport()
        durationSetting()
        viewDidLayoutSubviews()
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
    
    
    
    func setupLevelButtons() {
        let _: [CGFloat] = [25, 25, 25, 25, 25]
        
        for i in 0..<5 {
            let button = UIButton()
            button.tag = i + 1
            button.backgroundColor = .systemGray5
            button.layer.cornerRadius = 10
            button.translatesAutoresizingMaskIntoConstraints = false
            levelButtons.append(button)
            buttonStack.addArrangedSubview(button)
        }
    }
    
    func setUpButton() {
    
        view.addSubview(okButton)
        okButton.addTarget(self, action: #selector(okButtonAction), for: .touchUpInside)
        okButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            okButton.topAnchor.constraint(equalTo: autonomyTextField.bottomAnchor, constant: 65),
            okButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            okButton.widthAnchor.constraint(equalToConstant: 150),
            okButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            questionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            durationLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 40),
            durationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            duration.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 10),
            
            duration.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            dificultyTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dificultyTextField.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: 70),
            dificultyTextField.heightAnchor.constraint(equalToConstant: 30),
            dificultyTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            
            autonomyTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            autonomyTextField.topAnchor.constraint(equalTo: dificultyTextField.bottomAnchor, constant: 70),
            autonomyTextField.heightAnchor.constraint(equalToConstant: 30),
            autonomyTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            
            painRateLabel.topAnchor.constraint(equalTo: duration.bottomAnchor, constant: 50),
            painRateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            difficultyLabel.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 60),
            
            difficultyLabel.bottomAnchor.constraint(equalTo: dificultyTextField.topAnchor, constant: -40),
            difficultyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            autonomyLabel.bottomAnchor.constraint(equalTo: autonomyTextField.topAnchor, constant: -10),
            autonomyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonStack.topAnchor.constraint(equalTo: painRateLabel.bottomAnchor, constant: 12),
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 120),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            
        ])
    }
    
    @objc func painLevelSelected(_ sender: UIButton) {
        let selectedLevel = sender.tag // Isso te dá o nível de 1 a 5
        
        // Lógica para "pintar" as bolinhas
        for (index, button) in self.levelButtons.enumerated() {
            if index < selectedLevel {
                // Bolinhas selecionadas (Ativas)
                button.backgroundColor = setGradient(bounds: button.bounds) // Cor de destaque
            } else {
                // Bolinhas restantes (Desativadas)
                button.backgroundColor = .systemGray5
            }
        }
    }
    
    func setGradient(bounds: CGRect) -> UIColor {
        let colors = [
            UIColor(red: 0.968, green: 0.767, blue: 0.465, alpha: 1),
            UIColor(red: 0.907, green: 0.456, blue: 0.93, alpha: 1)
        ]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)

        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { ctx in
            gradientLayer.render(in: ctx.cgContext)
        }
        return UIColor(patternImage: image)
    }
    
    func setupTextField() {
        dificultyTextField = UITextField(frame: .zero)
        dificultyTextField.borderStyle = .roundedRect
        dificultyTextField.translatesAutoresizingMaskIntoConstraints = false
        dificultyTextField.textAlignment = .center
        view.addSubview(dificultyTextField)
        
        
        autonomyTextField = UITextField(frame: .zero)
        autonomyTextField.borderStyle = .roundedRect
        autonomyTextField.translatesAutoresizingMaskIntoConstraints = false
        autonomyTextField.textAlignment = .center
        
        view.addSubview(autonomyTextField)
        view.addSubview(buttonStack)
        view.addSubview(questionLabel)
        view.addSubview(durationLabel)
        view.addSubview(duration)
        view.addSubview(painRateLabel)
        view.addSubview(difficultyLabel)
        view.addSubview(autonomyLabel)
        
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
        
        let button = UIBarButtonItem(title: "done", style: .plain, target: self, action: #selector(self.done))
        
        toolbar.setItems([button], animated: true)
        toolbar.isUserInteractionEnabled = true
        
        dificultyTextField.inputView = difficultiesPickerView
        dificultyTextField.inputAccessoryView = toolbar
        
        autonomyTextField.inputView = autonomyPickerView
        autonomyTextField.inputAccessoryView = toolbar
    }
    
    
    
    @objc func done() {
        view.endEditing(true)
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        setupTextField()
        setupConstraints()
        setupPicker()
        setUpButton()
        setupLevelButtons()
    }

    @objc private func okButtonAction() {
        viewModel.updateHabit(autonomy: autonomyOption, difficulty: difficultiesOption, painRate: 3)

        dismiss(animated: true, completion: nil)
    }
}

extension ExerciseFeedbackView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return difficultiesArray.count
        case 2:
            return autonomyArray.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return difficultiesArray[row]
        case 2:
            return autonomyArray[row]
        default:
            return "Data not found"
        }    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            dificultyTextField.text = difficultiesArray[row]
            difficultiesOption = difficultiesArray[row]
        case 2:
            autonomyTextField.text = autonomyArray[row]
            autonomyOption = autonomyArray[row]
        default:
            return
        }
    }
    
    
}

#Preview {
    let ef = ExerciseFeedbackView()
    ef
}



