//
//  GeneralReport.swift
//  FisioterApp
//
//  Created by Pedro Henrique L. Moreiras on 02/04/26.
//

import UIKit
import Foundation
import CoreData
 
class GRViewController: UIViewController {

    var autonomieFeedback: String?
    var difficultyFeedback: String?
    let dateFormatter = DateFormatter()
    
    let viewModel = CoreDataViewModel()
    
    let generalReport: GeneralReportView2 = {
        let view = GeneralReportView2()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        viewModel.getReport()
        super.viewDidLoad()
        setupView()
        view.backgroundColor = .systemBackground
    }
    
    private func setupView() {
        let date1 = viewModel.reports.last?.datePeriod1 ?? Date.now
        let date2 = viewModel.reports.last?.datePeriod2 ?? Date.now
        let duration = viewModel.reports.last?.duration ?? "1:00"
        
        generalReport.datePeriod1.text = "\(dateFormatter.string(from: date1))"
        generalReport.datePeriod2.text = "\(dateFormatter.string(from: date2))"
        generalReport.duration.text = duration
        
        
        // add subviews
        view.addSubview(generalReport)
        
        // add contraints
        NSLayoutConstraint.activate([
        
            
        ])
    }
}

#Preview {
    let gr = GRViewController()
    gr
}
