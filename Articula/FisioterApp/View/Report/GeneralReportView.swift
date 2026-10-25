//
//  GeneralReport.swift
//  FisioterApp
//
//  Created by Pedro Henrique L. Moreiras on 02/04/26.
//


import UIKit
import Foundation
import CoreData
 
class GeneralReportView: UIView {

    var autonomieFeedback: String?
    var difficultyFeedback: String?
    
    let viewModel = CoreDataViewModel()
    
    
    let reportStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .vertical
        stack.spacing = 26
        return stack
    }()
    
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
    
    let dateCTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Dados coletados até"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
    }()
    
    var dateCreate: UILabel = {
        let dateC = UILabel()
        let today = Date.now
        dateC.translatesAutoresizingMaskIntoConstraints = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        
        dateC.text = "\(dateFormatter.string(from: today))"
        
        dateC.font = UIFont.systemFont(ofSize: 24)
        
        return dateC
    }()
    
    var datePeriod1: UILabel = {
        let dateP1 = UILabel()
        let today = Date.now
        dateP1.translatesAutoresizingMaskIntoConstraints = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        
        dateP1.text = "\(dateFormatter.string(from: today))"
        
        dateP1.font = UIFont.systemFont(ofSize: 22)
        
        return dateP1
    }()
    
    var datePeriod2: UILabel = {
        let dateP2 = UILabel()
        let P2 = Date.distantPast
        dateP2.translatesAutoresizingMaskIntoConstraints = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        dateP2.text = "\(dateFormatter.string(from: P2))"
        
        dateP2.font = UIFont.systemFont(ofSize: 22)
        
        return dateP2
    }()
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Duração"
        //        label.text =
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 22)
        
        return label
    }()
    
    var duration: UILabel = {
        let drtn = UILabel()
        var min = 12
        var sec = 39
        
        drtn.translatesAutoresizingMaskIntoConstraints = false
        drtn.text = "\(min):\(sec)"
        //        drtn.text = "\(dataDuration)"
        drtn.font = UIFont.systemFont(ofSize: 22)
        return drtn
    }()
    
    let autonomieTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Autonomia"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 22)
        
        return label
    }()
    
    var autonomieLabel: UILabel = {
        CoreDataViewModel.shared.getReport()
        print(CoreDataViewModel.shared.reports)
        let auto = UILabel()
        auto.translatesAutoresizingMaskIntoConstraints = false
        auto.text = CoreDataViewModel.shared.reports.first?.autonomy
        auto.font = UIFont.systemFont(ofSize: 14)
        auto.textColor = .white
        return auto
    }()
    
    var difficultTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Dificuldade"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 22)
        
        return label
    }()
    
    var difficultLabel: UILabel = {
        let diff = UILabel()
        diff.translatesAutoresizingMaskIntoConstraints = false
        diff.text = CoreDataViewModel.shared.reports.first?.difficulty
        diff.font = UIFont.systemFont(ofSize: 14)
        diff.textColor = .white
        return diff
    }()
    
    var levelPainTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Nível de dor"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 22)
        return label
    }()
    
    var levelPain: UILabel = {
        let lvlPain = UILabel()
        var numbPain = 3
        lvlPain.translatesAutoresizingMaskIntoConstraints = false
        lvlPain.text = "\(numbPain)"
        lvlPain.font = UIFont.systemFont(ofSize: 22)
        lvlPain.textColor = .white
        return lvlPain
    }()
    
    var completedTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "O exercício foi completo?"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 24)
        
        return label
    }()
    
    var completedLabel: UILabel = {
        let comp = UILabel()
        comp.translatesAutoresizingMaskIntoConstraints = false
        comp.text = "Sim"
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
        addSubview(dateCTitle)
        addSubview(dateCreate)
        addSubview(datePeriod1)
        addSubview(datePeriod2)
        addSubview(durationLabel)
        addSubview(duration)
        addSubview(levelPain)
        addSubview(levelPainTitle)
        addSubview(autonomieTitle)
        addSubview(autonomieLabel)
        addSubview(difficultTitle)
        addSubview(difficultLabel)
        addSubview(completedTitle)
        addSubview(completedLabel)
        addSubview(shareButton)
        
        
        
        // add contraints
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 100),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            
            dateCTitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            
            dateCTitle.centerXAnchor.constraint(equalTo: dateCreate.centerXAnchor),
            
            dateCreate.topAnchor.constraint(equalTo: dateCTitle.topAnchor, constant: 20),
            
            dateCreate.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            
            
            datePeriod1.topAnchor.constraint(equalTo: dateCreate.bottomAnchor, constant: 100),
            
            datePeriod1.leadingAnchor.constraint(equalTo: dateCreate.leadingAnchor),
            
            
            datePeriod2.leadingAnchor.constraint(equalTo: datePeriod1.trailingAnchor, constant: 110),
            
            datePeriod2.topAnchor.constraint(equalTo: datePeriod1.topAnchor),
            
            
            durationLabel.topAnchor.constraint(equalTo: datePeriod2.bottomAnchor, constant: 37),
            
            durationLabel.centerXAnchor.constraint(equalTo: datePeriod2.centerXAnchor),
            
            duration.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 20),
            
            duration.centerXAnchor.constraint(equalTo: durationLabel.centerXAnchor),
            
            autonomieTitle.topAnchor.constraint(equalTo: duration.bottomAnchor, constant: 60),
            
            autonomieTitle.centerXAnchor.constraint(equalTo: durationLabel.centerXAnchor),
            
            autonomieLabel.topAnchor.constraint(equalTo: autonomieTitle.bottomAnchor, constant: 20),
            
            autonomieLabel.centerXAnchor.constraint(equalTo: duration.centerXAnchor),
            
            difficultTitle.topAnchor.constraint(equalTo: autonomieTitle.topAnchor),
            
            difficultTitle.centerXAnchor.constraint(equalTo: difficultLabel.centerXAnchor),
            
            difficultLabel.topAnchor.constraint(equalTo: autonomieLabel.topAnchor),
            
            difficultLabel.centerXAnchor.constraint(equalTo: datePeriod1.centerXAnchor),
            
            completedTitle.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            completedTitle.topAnchor.constraint(equalTo: difficultLabel.bottomAnchor, constant: 50),
            
            completedLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            completedLabel.topAnchor.constraint(equalTo: completedTitle.bottomAnchor, constant: 38),
            
            
            levelPainTitle.topAnchor.constraint(equalTo: durationLabel.topAnchor),
            
            levelPainTitle.centerXAnchor.constraint(equalTo: difficultLabel.centerXAnchor),
            
            levelPain.topAnchor.constraint(equalTo: duration.topAnchor),
            
            levelPain.centerXAnchor.constraint(equalTo: levelPainTitle.centerXAnchor),
            
            shareButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            shareButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
            
            
            
        ])
    }
}

#Preview {
    let gr = GeneralReportView()
    gr
}
