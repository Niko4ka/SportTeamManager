//
//  PlayerViewController+Extensions.swift
//  SportTeamManager
//
//  Created by Вероника Данилова on 28/11/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension PlayerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        photoImageView.image = image
        
        defer {
            imagePickerController.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension PlayerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            selectTeamButton.setTitle(PickerViewItems.teams[row], for: .normal)
            selectedTeam = PickerViewItems.teams[row]
        case 1:
            selectPositionButton.setTitle(PickerViewItems.positions[row], for: .normal)
            selectedPosition = PickerViewItems.positions[row]
        default:
            ()
        }
        
        hiddenTextField.resignFirstResponder()
        enableSaveButton()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return PickerViewItems.teams.count
        case 1:
            return PickerViewItems.positions.count
        default:
            ()
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 0:
            return PickerViewItems.teams[row]
        case 1:
            return PickerViewItems.positions[row]
        default:
            ()
        }
        return nil
    }
}

// MARK: - UITextFieldDelegate

extension PlayerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        keyboardService.textFieldRealYPosition = textField.frame.maxY + textField.frame.height
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.placeholder == "Name" {
            enableSaveButton()
        }
    }
    
    @objc func tapOutsideTextField(gesture: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        numberTextField.resignFirstResponder()
        nationalityTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
        hiddenTextField.resignFirstResponder()
    }
}
