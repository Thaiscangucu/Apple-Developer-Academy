//
//  ReportModel.swift
//  FisioterApp
//
//  Created by Pedro Henrique L. Moreiras on 02/04/26.
//
import UIKit
import Foundation

struct ReportModel {
    var dateCreate: Date
    var period: Date
    var levelPains: Int
    var durations: [Int]
    var difficulties: Int
    var autonomies: [String]
    var completed: [Bool]
    var typeReport: String
}


