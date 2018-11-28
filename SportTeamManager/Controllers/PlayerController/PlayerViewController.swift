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
    
    // PickerViews DataSource
    struct PickerViewItems {
        static let positions = ["Centre", "Power forward", "Small forward", "Shooting guard", "Point guard", "Coach"]
        static let teams = ["Chicago Bulls", "Los Angeles Lakers", "Boston Celtics", "Golden State Warriors", "San Antonio Spurs", "Toronto Raptors"]
    }
    
    // Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nationalityTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var selectTeamButton: UIButton!
    @IBOutlet weak var selectPositionButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // Variables
    var imagePickerController = UIImagePickerController()
    var keyboardService: KeyboardService!
    let hiddenTextField = UITextField(frame: .zero)
    let pickerView = UIPickerView()
    var selectedTeam: String!
    var selectedPosition: String!
    public var editingPlayer: Player?

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let player = editingPlayer else { return }
        
        photoImageView.image = player.image as? UIImage
        numberTextField.text = player.number
        nameTextField.text = player.fullname
        nationalityTextField.text = player.nationality
        ageTextField.text = "\(player.age)"
        if let team = player.team {
            selectTeamButton.setTitle(team.name, for: .normal)
        }
        selectedTeam = selectTeamButton.title(for: .normal)
        selectPositionButton.setTitle(player.position, for: .normal)
        selectedPosition = selectPositionButton.title(for: .normal)
        
        if player.inPlay {
            segmentedControl.selectedSegmentIndex = 0
        } else {
            segmentedControl.selectedSegmentIndex = 1
        }
        
        enableSaveButton()
    }
    
    // MARK: - Actions
    
    @IBAction func uploadImageButtonPressed(_ sender: UIButton) {
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func teamSelectButtonPressed(_ sender: UIButton) {
        
        pickerView.tag = 0
        if selectedTeam != nil {
            for i in 0..<PickerViewItems.teams.count {
                if selectedTeam == PickerViewItems.teams[i] {
                    pickerView.selectRow(i, inComponent: 0, animated: false)
                    break
                }
            }
        }
        hiddenTextField.frame.origin = CGPoint(x: selectTeamButton.frame.origin.x, y: selectTeamButton.frame.origin.y + 30.0)
        hiddenTextField.becomeFirstResponder()
    }
    
    @IBAction func positionSelectButtonPressed(_ sender: UIButton) {
        
        pickerView.tag = 1
        if selectedPosition != nil {
            for i in 0..<PickerViewItems.positions.count {
                if selectedPosition == PickerViewItems.positions[i] {
                    pickerView.selectRow(i, inComponent: 0, animated: false)
                    break
                }
            }
        }
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
        
        var player: Player!
        
        if editingPlayer == nil {
            player = CoreDataManager.instance.createObject(from: Player.self)
        } else {
            guard let id = editingPlayer?.id else { return }
            player = CoreDataManager.instance.findPlayer(withID: id).first
        }
        
        if nationalityTextField.text != "" {
            player.nationality = nationalityTextField.text
        }
        if numberTextField.text != "" {
            player.number = numberTextField.text
        }
        
        player.id = UUID()
        player.age = playerAge
        player.fullname = nameTextField.text
        player.position = selectedPosition
        player.team = team
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
    
    // MARK: - Enable/Disable Save-button
    
    private func disableSaveButton() {
        saveButton.isEnabled = false
        saveButton.alpha = 0.5
    }
    
    internal func enableSaveButton() {
        guard let fullname = nameTextField.text, let age = ageTextField.text, let _ = selectedTeam, let _ = selectedPosition else {
            return
        }
        
        if !fullname.isEmpty && !age.isEmpty {
            saveButton.isEnabled = true
            saveButton.alpha = 1.0
        }
    }
    
    // MARK: - Show alert
    
    private func showAlert(with message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
