//
//  UIPicker.swift
//  FisioterApp
//
//  Created by Thais Cangucu on 17/04/26.
//

import UIKit
extension FeedbackView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 1 ? difficultiesArray.count : autonomyArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView.tag == 1 ? difficultiesArray[row] : autonomyArray[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            textField1.text = difficultiesArray[row]
            difficultiesOption = difficultiesArray[row]
        } else {
            textField2.text = autonomyArray[row]
            autonomyOption = autonomyArray[row]
        }
    }
}
