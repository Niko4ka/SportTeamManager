//
//  SearchViewController.swift
//  SportTeamManager
//
//  Created by Вероника Данилова on 25/11/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

protocol SearchDelegate: class {
    func viewController(_ viewController: UIViewController, didPassedData predicate: NSCompoundPredicate)
}

class SearchViewController: UIViewController {
    // Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var ageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var selectPositionButton: UIButton!
    @IBOutlet weak var selectTeamButton: UIButton!
    @IBOutlet weak var positionPickerView: UIPickerView!
    @IBOutlet weak var teamPickerView: UIPickerView!
    // Variables
    weak var delegate: SearchDelegate?
    private var selectedSegmentIndex: Int = 0
    private var selectedTeam: String = ""
    private var selectedPosition: String = ""
    
    convenience init(segmentIndex: Int) {
        self.init()
        self.selectedSegmentIndex = segmentIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        positionPickerView.isHidden = true
        positionPickerView.delegate = self
        positionPickerView.dataSource = self
        teamPickerView.isHidden = true
        teamPickerView.delegate = self
        teamPickerView.dataSource = self
        
        fullnameTextField.delegate = self
        ageTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOutsideTextField(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(closeTapGesture(_:)))
        bgView.addGestureRecognizer(closeTap)
    }
    
    @objc func closeTapGesture(_ recognizer: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func selectPositionButtonPressed(_ sender: UIButton) {
        positionPickerView.isHidden = false
        teamPickerView.isHidden = true
    }
    
    @IBAction func selectTeamButtonPressed(_ sender: UIButton) {
        positionPickerView.isHidden = true
        teamPickerView.isHidden = false
    }
    
    @IBAction func startSearchButtonPressed(_ sender: UIButton) {
        
        let compoundPredicate = makeCompoundPredicate(fullname: fullnameTextField.text!, age: ageTextField.text!, position: selectedPosition, team: selectedTeam)
        delegate?.viewController(self, didPassedData: compoundPredicate)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        switch selectedSegmentIndex {
        case 0:
            delegate?.viewController(self, didPassedData: MainViewController.Predicates.emptyPredicate)
        case 1:
            delegate?.viewController(self, didPassedData: MainViewController.Predicates.inPlayPredicate)
        case 2:
            delegate?.viewController(self, didPassedData: MainViewController.Predicates.onBenchPredicate)
        default:
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private
    
    private func makeCompoundPredicate(fullname: String, age: String, position: String, team: String) -> NSCompoundPredicate {
        
        var predicates = [NSPredicate]()
        
        if !fullname.isEmpty {
            let fullnamePredicate = NSPredicate(format: "fullname CONTAINS[cd] '\(fullname)'")
            predicates.append(fullnamePredicate)
        }
        
        if !age.isEmpty {
            let selectedSegmentControl = ageSearchCondition(index: ageSegmentedControl.selectedSegmentIndex)
            let agePredicate = NSPredicate(format: "age \(selectedSegmentControl) '\(age)'")
            predicates.append(agePredicate)
        }
        
        if !position.isEmpty {
            let positionPredicate = NSPredicate(format: "position CONTAINS[cd] '\(position)'")
            predicates.append(positionPredicate)
        }
        
        if !team.isEmpty{
            let teamPredicate = NSPredicate(format: "team.name CONTAINS[cd] '\(team)'")
            predicates.append(teamPredicate)
        }
        
        switch selectedSegmentIndex {
        case 1:
            let inPlayPredicate = NSPredicate(format: "inPlay = true")
            predicates.append(inPlayPredicate)
        case 2:
            let onBenchPredicate = NSPredicate(format: "inPlay = false")
            predicates.append(onBenchPredicate)
        default:
            break
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    private func ageSearchCondition(index: Int) -> String {
        var condition: String!
        
        switch index {
        case 0:
            condition = ">="
        case 1:
            condition = "="
        case 2:
            condition = "<="
        default:
            break
        }
        
        return condition
    }

}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension SearchViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case 0:
            selectTeamButton.setTitle(PlayerViewController.PickerViewItems.teams[row], for: .normal)
            selectedTeam = PlayerViewController.PickerViewItems.teams[row]
            teamPickerView.isHidden = true
        case 1:
            selectPositionButton.setTitle(PlayerViewController.PickerViewItems.positions[row], for: .normal)
            selectedPosition = PlayerViewController.PickerViewItems.positions[row]
            positionPickerView.isHidden = true
        default:
            ()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return PlayerViewController.PickerViewItems.teams.count
        case 1:
            return PlayerViewController.PickerViewItems.positions.count
        default:
            ()
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 0:
            return PlayerViewController.PickerViewItems.teams[row]
        case 1:
            return PlayerViewController.PickerViewItems.positions[row]
        default:
            ()
        }
        return nil
    }
    
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func tapOutsideTextField(gesture: UITapGestureRecognizer) {
        fullnameTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
    }
}
