//
//  ViewController.swift
//  SportTeamManager
//
//  Created by Вероника Данилова on 19/11/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var noResultsAdditionalLabel: UILabel!
    @IBOutlet weak var resetFiltersButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    struct Predicates {
        static let emptyPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [])
        static let inPlayPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "inPlay = true")])
        static let onBenchPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "inPlay = false")])
    }
    
    private var playerShouldBeInPlay: Bool!
    private var fetchedResultController: NSFetchedResultsController<Player>!
    private var noResultsText = "Players catalog is empty"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playersTableView.delegate = self
        playersTableView.dataSource = self
        
        let presetter = PresetData()
        presetter.recordPresetData()
        
        fetchData()
    }
    
    @IBAction func addPlayerButtonPressed(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: "PlayerViewController", bundle: nil)
        let playerViewController = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        navigationController?.pushViewController(playerViewController, animated: true)
    }
    
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        let searchViewController = SearchViewController(segmentIndex: segmentedControl.selectedSegmentIndex)
        searchViewController.delegate = self
        searchViewController.modalTransitionStyle = .crossDissolve
        searchViewController.modalPresentationStyle = .overCurrentContext
        present(searchViewController, animated: true, completion: nil)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
 
        switch sender.selectedSegmentIndex {
        case 0:
            noResultsText = "Players catalog is empty"
            fetchData(predicate: Predicates.emptyPredicate)
        case 1:
            noResultsText = "There are no players in play"
            fetchData(predicate: Predicates.inPlayPredicate)
        case 2:
            noResultsText = "There are no players on bench"
            fetchData(predicate: Predicates.onBenchPredicate)
        default:
            break
        }
        
        playersTableView.reloadData()
    }
    
    
    private func fetchData(predicate: NSCompoundPredicate? = nil) {
        
        fetchedResultController = CoreDataManager.instance.fetchDataWithController(for: Player.self, sectionNameKeyPath: "position", predicate: predicate)
        fetchedResultController.delegate = self
        
        fetchedObjectsCheck(predicate: predicate)
    }
    
    private func fetchedObjectsCheck(predicate: NSCompoundPredicate? = nil) {
        
        guard let objects = fetchedResultController.fetchedObjects else {
            return
        }
        
        print("Number of objects - \(objects.count)")


        if objects.count > 0 {
            playersTableView.isHidden = false
        } else {
            playersTableView.isHidden = true
            if predicate == nil || predicate == Predicates.emptyPredicate || predicate == Predicates.onBenchPredicate || predicate == Predicates.inPlayPredicate {
                noResultsLabel.text = noResultsText
                noResultsAdditionalLabel.text = "Add a player by pressing +"
                resetFiltersButton.isHidden = true
            } else {
                noResultsLabel.text = "No matching results"
                noResultsAdditionalLabel.text = ""
                resetFiltersButton.isHidden = false
            }
        }
    }
    
    @IBAction func resetFiltersButtonPressed(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            viewController(self, didPassedData: Predicates.emptyPredicate)
        case 1:
            viewController(self, didPassedData: Predicates.inPlayPredicate)
        case 2:
            viewController(self, didPassedData: Predicates.onBenchPredicate)
        default:
            return
        }
    }

}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            let item = self.fetchedResultController.object(at: indexPath)
            CoreDataManager.instance.delete(object: item)
        }
        
        var inPlayStatusTitle: String
        let cell = tableView.cellForRow(at: indexPath) as! PlayerTableViewCell
        
        switch cell.inPlayLabel.text {
        case "In Play":
            playerShouldBeInPlay = false
            inPlayStatusTitle = "To Bench"
        case "On Bench":
            playerShouldBeInPlay = true
            inPlayStatusTitle = "To Play"
        default:
            playerShouldBeInPlay = false
            inPlayStatusTitle = "Unknown"
        }
        
        let inPlayStatus = UITableViewRowAction(style: .normal, title: inPlayStatusTitle) { (action, indexPath) in
            
            let context = CoreDataManager.instance.getContext()
            let selectedPlayer = CoreDataManager.instance.findPlayer(withID: cell.id).first
            selectedPlayer?.inPlay = self.playerShouldBeInPlay
            CoreDataManager.instance.save(context: context)
        }
        inPlayStatus.backgroundColor = UIColor.purple
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            
            guard let selectedPlayer = CoreDataManager.instance.findPlayer(withID: cell.id).first,
                let number = selectedPlayer.number,
                let photo = selectedPlayer.image as? UIImage,
                let fullname = selectedPlayer.fullname,
                let nationality = selectedPlayer.nationality,
                let team = selectedPlayer.team,
                let position = selectedPlayer.position else {
                print("Problems with finding player")
                return
            }
            
            let editingPlayer = EditingPlayer(playerID: cell.id, playerNumber: number, playerPhoto: photo, playerFullname: fullname, playerNationality: nationality, playerAge: selectedPlayer.age, playerTeam: team, playerPosition: position, playerInPlay: selectedPlayer.inPlay)
            
            let storyboard = UIStoryboard(name: "PlayerViewController", bundle: nil)
            let playerViewController = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
            playerViewController.editingPlayer = editingPlayer
            self.navigationController?.pushViewController(playerViewController, animated: true)
        }
        edit.backgroundColor = UIColor.orange
        
        return [delete, edit, inPlayStatus]
    }
    
}


extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultController.sections else {
            return 0
        }
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultController.sections else {
            return nil
        }
        
        return sections[section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultController.sections else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath)
        if let cell = cell as? PlayerTableViewCell {
            
            let item = fetchedResultController.object(at: indexPath)
            cell.configureCell(with: item)
        }
        return cell
    }
    
}

extension MainViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        playersTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            playersTableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            playersTableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                playersTableView.deleteRows(at: [indexPath], with: .fade)
                fetchedObjectsCheck()
            }
            
        case .insert:
            if let indexPath = newIndexPath {
                playersTableView.insertRows(at: [indexPath], with: .fade)
                fetchedObjectsCheck()
            }
            
        case .move:
            if let indexPath = indexPath {
                let cell = playersTableView.cellForRow(at: indexPath) as! PlayerTableViewCell
                let item = fetchedResultController.object(at: indexPath)
                cell.configureCell(with: item)
            }
            
        case .update:
            print("Update")
            if let indexPath = indexPath {
                let cell = playersTableView.cellForRow(at: indexPath) as! PlayerTableViewCell
                let item = fetchedResultController.object(at: indexPath)
                cell.configureCell(with: item)
            }

        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        playersTableView.endUpdates()
    }
}

extension MainViewController: SearchDelegate {
    func viewController(_ viewController: UIViewController, didPassedData predicate: NSCompoundPredicate) {
        fetchData(predicate: predicate)
        playersTableView.reloadData()
    }
}
