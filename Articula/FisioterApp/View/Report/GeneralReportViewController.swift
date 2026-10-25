//
//  GeneralReportViewController.swift
//  FisioterApp
//
//  Created by Pedro Henrique L. Moreiras on 14/04/26.
//

import Foundation
import UIKit

class GeneralReportViewController: UIViewController {
    
    let genReport: GeneralReportView = {
        let view = GeneralReportView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        view.backgroundColor = .systemBackground
    }
    
    private func createPdfFromView(aView: UIView, saveToDocumentsWithFileName fileName: String)
    {
//        sendButton.configuration?.background
        
        //colocar "transparente" = mesma cor do fundo
        genReport.shareButton.configuration?.baseForegroundColor = .white
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil)
        //abre o arquivo pdf
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        aView.layer.render(in: pdfContext)
        //tira o print da view no momento atual
        UIGraphicsEndPDFContext()
        //fecha o arquivo pdf
        
        
        //local onde o documento fica salvo
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + fileName + ".pdf"
            debugPrint(documentsFileName)
            let fileURL = URL(fileURLWithPath: documentsFileName)
            
            pdfData.write(toFile: documentsFileName, atomically: true)
            print("PDF salvo em \(documentsFileName)")
            
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            
            self.present(activityViewController, animated: true, completion: nil)
        }
        
        //volta para a cor normal
        genReport.shareButton.configuration?.baseForegroundColor = .red
    }
    
    private func setupController() {
        let pdfAction = UIAction { _ in
            self.createPdfFromView(aView: self.genReport, saveToDocumentsWithFileName: "relatório")
        }
        genReport.shareButton.addAction(pdfAction, for: .touchUpInside)
        
        view.addSubview(genReport)
        
        NSLayoutConstraint.activate([
            genReport.topAnchor.constraint(equalTo: view.topAnchor),
            genReport.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            genReport.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            genReport.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
    }
}

#Preview {
    let genReportPreview = GeneralReportViewController()
    return genReportPreview.view
}
