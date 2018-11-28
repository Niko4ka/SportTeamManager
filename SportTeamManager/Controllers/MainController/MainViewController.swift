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
    
    // Outlets
    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var noResultsAdditionalLabel: UILabel!
    @IBOutlet weak var resetFiltersButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // Predicates
    struct Predicates {
        static let emptyPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [])
        static let inPlayPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "inPlay = true")])
        static let onBenchPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "inPlay = false")])
    }
    
    // Variables
    
    var fetchedResultController: NSFetchedResultsController<Player>!
    private var searchPredicate: NSCompoundPredicate?
    private var noResultsText = "Players catalog is empty"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playersTableView.delegate = self
        playersTableView.dataSource = self
        
        let presetter = PresetData()
        presetter.recordPresetData()
        
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        playersTableView.reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func addPlayerButtonPressed(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: "PlayerViewController", bundle: nil)
        let playerViewController = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        navigationController?.pushViewController(playerViewController, animated: true)
    }
    
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        let searchViewController = SearchViewController()
        searchViewController.delegate = self
        searchViewController.modalTransitionStyle = .crossDissolve
        searchViewController.modalPresentationStyle = .overCurrentContext
        present(searchViewController, animated: true, completion: nil)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
 
        switch sender.selectedSegmentIndex {
        case 0:
            noResultsText = "Players catalog is empty"
        case 1:
            noResultsText = "There are no players in play"
        case 2:
            noResultsText = "There are no players on bench"
        default:
            break
        }
        
        updateUI()
        playersTableView.reloadData()
    }
    
    @IBAction func resetFiltersButtonPressed(_ sender: Any) {
        
        viewController(self, didPassedData: Predicates.emptyPredicate)
    }
    
    // MARK: - Fetch data
    
    private func updateUI() {
        
        switch (searchPredicate, segmentedControl.selectedSegmentIndex) {
            
        case (nil, 0):
            fetchData()
            
        case (nil, 1):
            fetchData(predicate: Predicates.inPlayPredicate)
            
        case (nil, 2):
            fetchData(predicate: Predicates.onBenchPredicate)

        case (let notNil, 0) where notNil != nil:
            fetchData(predicate: searchPredicate)
            
        case (let notNil, 1) where notNil != nil:
            if let searchPredicate = searchPredicate {
                let combinedPredicate = NSCompoundPredicate(type: .and, subpredicates: [Predicates.inPlayPredicate, searchPredicate])
                fetchData(predicate: combinedPredicate)
            }
            
        case (let notNil, 2) where notNil != nil:
            if let searchPredicate = searchPredicate {
                let combinedPredicate = NSCompoundPredicate(type: .and, subpredicates: [Predicates.onBenchPredicate, searchPredicate])
                fetchData(predicate: combinedPredicate)
            }
            
        default:
            return
        }
        
    }
    
    private func fetchData(predicate: NSCompoundPredicate? = nil) {
        
        fetchedResultController = CoreDataManager.instance.fetchDataWithController(for: Player.self, sectionNameKeyPath: "team.name", predicate: predicate)
        fetchedResultController.delegate = self
        
        fetchedObjectsCheck(predicate: predicate)
    }
    
    private func fetchedObjectsCheck(predicate: NSCompoundPredicate? = nil) {
        
        guard let objects = fetchedResultController.fetchedObjects else {
            return
        }
        
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

}

// MARK: - NSFetchedResultsControllerDelegate

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

// MARK: - SearchDelegate

extension MainViewController: SearchDelegate {
    func viewController(_ viewController: UIViewController, didPassedData predicate: NSCompoundPredicate) {
        
        if predicate == Predicates.emptyPredicate {
            searchPredicate = nil
        } else {
            searchPredicate = predicate
        }
        
        updateUI()
        playersTableView.reloadData()
    }
}
