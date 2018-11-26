//
//  PlayerViewController.swift
//  SportTeamManager
//
//  Created by Вероника Данилова on 19/11/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit
import CoreData

class PlayerViewController: UIViewController {
    
    struct PickerViewItems {
        static let positions = ["Centre", "Power forward", "Small forward", "Shooting guard", "Point guard", "Coach"]
        static let teams = ["Chicago Bulls", "Los Angeles Lakers", "Boston Celtics", "Golden State Warriors", "San Antonio Spurs", "Toronto Raptors"]
    }
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nationalityTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var selectTeamButton: UIButton!
    @IBOutlet weak var selectPositionButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    

    private var imagePickerController = UIImagePickerController()
    private var selectedTeam: String!
    private var selectedPosition: String!
    private var keyboardService: KeyboardService!
    private let hiddenTextField = UITextField(frame: .zero)
    private let pickerView = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        disableSaveButton()
        nameTextField.delegate = self
        numberTextField.delegate = self
        nationalityTextField.delegate = self
        ageTextField.delegate = self

        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        
        pickerView.dataSource = self
        pickerView.delegate = self
        view.addSubview(hiddenTextField)
        hiddenTextField.inputView = pickerView
        hiddenTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOutsideTextField(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        keyboardService = KeyboardService(self)
        keyboardService.addKeyboardObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        photoImageView.layer.borderWidth = 0.5
        photoImageView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func uploadImageButtonPressed(_ sender: UIButton) {
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func teamSelectButtonPressed(_ sender: UIButton) {
        
        pickerView.tag = 0
        hiddenTextField.frame.origin = CGPoint(x: selectTeamButton.frame.origin.x, y: selectTeamButton.frame.origin.y + 30.0)
        hiddenTextField.becomeFirstResponder()
    }
    
    @IBAction func positionSelectButtonPressed(_ sender: UIButton) {
        
        pickerView.tag = 1
        hiddenTextField.frame.origin = CGPoint(x: selectPositionButton.frame.origin.x, y: selectPositionButton.frame.origin.y + 30.0)
        hiddenTextField.becomeFirstResponder()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {

        guard let playerAge = Int16(ageTextField.text!), playerAge < 100 else {
            let errorMassage = "Age has incorrect type"
            showAlert(with: errorMassage)
            return
        }
        
        let context = CoreDataManager.instance.getContext()
        
        let team = CoreDataManager.instance.createObject(from: Team.self)
        team.name = selectedTeam
        
        let player = CoreDataManager.instance.createObject(from: Player.self)

        if nationalityTextField.text != "" {
            player.nationality = nationalityTextField.text
        }
        if numberTextField.text != "" {
            player.number = numberTextField.text
        }
        
        player.age = playerAge
        player.fullname = nameTextField.text
        player.position = selectedPosition
        player.team = selectedTeam
        player.image = photoImageView.image
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            player.inPlay = true
        case 1:
            player.inPlay = false
        default: ()
        }
        
        CoreDataManager.instance.save(context: context)
        navigationController?.popViewController(animated: true)
    }
    
    private func disableSaveButton() {
        saveButton.isEnabled = false
        saveButton.alpha = 0.5
    }
    
    private func enableSaveButton() {
        guard let fullname = nameTextField.text, let age = ageTextField.text, let _ = selectedTeam, let _ = selectedPosition else {
            return
        }
        
        if !fullname.isEmpty && !age.isEmpty {
            saveButton.isEnabled = true
            saveButton.alpha = 1.0
        }
    }
    
    func showAlert(with message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}

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
