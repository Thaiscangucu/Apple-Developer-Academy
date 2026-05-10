//
//  ReportCell.swift
//  FisioterApp
//
//  Created by Pedro Henrique L. Moreiras on 02/04/26.
//
import UIKit
import Foundation

class ReportCell: UICollectionViewCell {
    
     let vStack = UIStackView()
    
    var dateCreate = UIDatePicker()
    var datePeriod = UIDatePicker()
    var levelsPain = UInt()
    var duration =  UInt()
    var difficulties = UInt()
    var autonomiesLabel = UILabel()
    var completedBool = Bool()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupContraints()
    }
    
    private func setupLayout() {
        dateCreate.date = .now
        dateCreate.translatesAutoresizingMaskIntoConstraints = false
        
        datePeriod.date = .now
        datePeriod.translatesAutoresizingMaskIntoConstraints = false
        
        autonomiesLabel.font = UIFont.systemFont(ofSize: 20)
        autonomiesLabel.textAlignment = .center
        autonomiesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        contentView.layer.borderColor = UIColor.black.cgColor
        
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 10
        
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(vStack)
        vStack.addArrangedSubview(dateCreate)
        vStack.addArrangedSubview(datePeriod)
        
    }
    
    func setup(report: ReportModel) {
        
        dateCreate.date = report.dateCreate
        datePeriod.date = report.period
    }
    
    func setupContraints() {
        NSLayoutConstraint.activate([
            
            vStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            vStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

#Preview {
    let rp = ReportCell()
    rp
}
