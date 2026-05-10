//
//  GeneralReport.swift
//  FisioterApp
//
//  Created by Pedro Henrique L. Moreiras on 02/04/26.
//


import UIKit
import Foundation
import CoreData
 
class GeneralReportView2: UIView {

    var autonomieFeedback: String?
    var difficultyFeedback: String?
        
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Relatório de \nDesempenho"
        label.textColor = .gray
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .medium).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 28)
        return label
    }()
    
    let dadosColetadosLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Dados coletados até"
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .thin).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 12)
        
        return label
    }()
    
    var dateCreateLabel: UILabel = {
        let dateC = UILabel()
        let today = Date.now
        dateC.translatesAutoresizingMaskIntoConstraints = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateC.text = "\(dateFormatter.string(from: today))"
        
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .regular).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        dateC.font = UIFont(descriptor: descriptor, size: 20)
        dateC.textColor = UIColor(red: 0.402, green: 0.402, blue: 0.402, alpha: 1)
        return dateC
    }()
    
    var datePeriod1: UILabel = {
        let dateP1 = UILabel()
        let today = Date.now
        dateP1.translatesAutoresizingMaskIntoConstraints = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
//        dateP1.text = "\(dateFormatter.string(from: today))"
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .regular).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        dateP1.font = UIFont(descriptor: descriptor, size: 15)
        
        return dateP1
    }()
    
    var datePeriod2: UILabel = {
        let dateP2 = UILabel()
        let P2 = Date.distantPast
        dateP2.translatesAutoresizingMaskIntoConstraints = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
//        dateP2.text = "\(dateFormatter.string(from: P2))"
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .regular).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        dateP2.font = UIFont(descriptor: descriptor, size: 15)
        
        return dateP2
    }()
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Duração"
        label.textColor = .gray
        let descriptor = UIFont.systemFont(ofSize: 20, weight: .light).fontDescriptor
            .addingAttributes([
                .traits: [UIFontDescriptor.TraitKey.width: 0.5]
            ])
        label.font = UIFont(descriptor: descriptor, size: 20)
        
        return label
    }()
    
    var duration: UILabel = {
        let drtn = UILabel()
        var min = 12
        var sec = 39
        
        drtn.translatesAutoresizingMaskIntoConstraints = false
        drtn.text = "\(min):\(sec)"
        drtn.font = UIFont.systemFont(ofSize: 22)
        return drtn
    }()
    
    let autonomyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Autonomia"
        label.textColor = .gray
        return label
    }()
    
    var autonomy: UILabel = {
        let auto = UILabel()
        auto.translatesAutoresizingMaskIntoConstraints = false
//        auto.text = CoreDataViewModel.shared.reports.first?.autonomy
        auto.font = UIFont.systemFont(ofSize: 14)
        auto.textColor = .white
        return auto
    }()
    
    var difficultyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Dificuldade"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 22)
        
        return label
    }()
    
    var difficulty: UILabel = {
        let diff = UILabel()
        diff.translatesAutoresizingMaskIntoConstraints = false
//        diff.text = CoreDataViewModel.shared.reports.first?.difficulty
        diff.font = UIFont.systemFont(ofSize: 14)
        diff.textColor = .white
        return diff
    }()
    
    var painLabel: UILabel = {
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
    
    
    var pain: UILabel = {
        let lvlPain = UILabel()
        var numbPain = 3
        lvlPain.translatesAutoresizingMaskIntoConstraints = false
//        lvlPain.text = "\(numbPain)"
        lvlPain.font = UIFont.systemFont(ofSize: 22)
        lvlPain.textColor = .white
        return lvlPain
    }()
    
    var completedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "O exercício foi completo?"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 24)
        
        return label
    }()
    
    var completed: UILabel = {
        let comp = UILabel()
        comp.translatesAutoresizingMaskIntoConstraints = false
//        comp.text = "Sim"
        comp.font = UIFont.systemFont(ofSize: 24)
        comp.textColor = .white
        return comp
    }()
    
    var shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var configuration = UIButton.Configuration.plain()
        
        configuration.image = UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        configuration.baseForegroundColor = UIColor.red
        button.configuration = configuration
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        
        // add subviews
        addSubview(titleLabel)
        addSubview(dadosColetadosLabel)
        addSubview(dateCreateLabel)
        addSubview(datePeriod1)
        addSubview(datePeriod2)
        addSubview(durationLabel)
        addSubview(duration)
        addSubview(pain)
        addSubview(painLabel)
        addSubview(autonomyLabel)
        addSubview(autonomy)
        addSubview(difficultyLabel)
        addSubview(difficulty)
        addSubview(completedLabel)
        addSubview(completed)
        addSubview(shareButton)
        
        // add contraints
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            
            dadosColetadosLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            
            dadosColetadosLabel.centerXAnchor.constraint(equalTo: dateCreateLabel.centerXAnchor),
            
            dateCreateLabel.topAnchor.constraint(equalTo: dadosColetadosLabel.topAnchor, constant: 20),
            
            dateCreateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            
            
            datePeriod1.topAnchor.constraint(equalTo: dateCreateLabel.bottomAnchor, constant: 100),
            
            datePeriod1.leadingAnchor.constraint(equalTo: dateCreateLabel.leadingAnchor),
            
            
            datePeriod2.leadingAnchor.constraint(equalTo: datePeriod1.trailingAnchor, constant: 110),
            
            datePeriod2.topAnchor.constraint(equalTo: datePeriod1.topAnchor),
            
            
            durationLabel.topAnchor.constraint(equalTo: datePeriod2.bottomAnchor, constant: 37),
            
            durationLabel.centerXAnchor.constraint(equalTo: datePeriod2.centerXAnchor),
            
            duration.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 20),
            
            duration.centerXAnchor.constraint(equalTo: durationLabel.centerXAnchor),
            
            autonomyLabel.topAnchor.constraint(equalTo: duration.bottomAnchor, constant: 60),
            
            autonomyLabel.centerXAnchor.constraint(equalTo: durationLabel.centerXAnchor),
            
            autonomy.topAnchor.constraint(equalTo: autonomyLabel.bottomAnchor, constant: 20),
            
            autonomy.centerXAnchor.constraint(equalTo: duration.centerXAnchor),
            
            difficultyLabel.topAnchor.constraint(equalTo: autonomyLabel.topAnchor),
            
            difficultyLabel.centerXAnchor.constraint(equalTo: difficulty.centerXAnchor),
            
            difficulty.topAnchor.constraint(equalTo: autonomy.topAnchor),
            
            difficulty.centerXAnchor.constraint(equalTo: datePeriod1.centerXAnchor),
            
            completedLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            completedLabel.topAnchor.constraint(equalTo: difficulty.bottomAnchor, constant: 50),
            
            completed.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            completed.topAnchor.constraint(equalTo: completedLabel.bottomAnchor, constant: 38),
            
            
            painLabel.topAnchor.constraint(equalTo: durationLabel.topAnchor),
            
            painLabel.centerXAnchor.constraint(equalTo: difficulty.centerXAnchor),
            
            pain.topAnchor.constraint(equalTo: duration.topAnchor),
            
            pain.centerXAnchor.constraint(equalTo: painLabel.centerXAnchor),
            
            shareButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            shareButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
}

#Preview {
    let gr = GeneralReportView2()
    gr
}
