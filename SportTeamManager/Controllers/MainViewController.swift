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
    
    private var players = [Player]()
    private let emptyPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playersTableView.delegate = self
        playersTableView.dataSource = self
        
        let presetter = PresetData()
        presetter.recordPresetData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchData()
        playersTableView.reloadData()
    }
    
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
        players.removeAll()
        fetchData(predicate: emptyPredicate)
        playersTableView.reloadData()
    }
    
    
    private func fetchData(predicate: NSCompoundPredicate? = nil) {
        
        var noResultsText = ""
        let fetchedPlayers = CoreDataManager.instance.fetchData(for: Player.self, predicate: predicate)
        
        var playersInPlay = [Player]()
        for player in fetchedPlayers {
            if player.inPlay {
                playersInPlay.append(player)
            }
        }
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            players = fetchedPlayers
            noResultsText = "Players catalog is empty"
        case 1:
            players = fetchedPlayers.filter {playersInPlay.contains($0)}
            noResultsText = "There are no players in play"
        case 2:
            players = fetchedPlayers.filter {!playersInPlay.contains($0)}
            noResultsText = "There are no players on bench"
        default:
            break
        }
        
        if players.count > 0 {
            playersTableView.isHidden = false
        } else {
            playersTableView.isHidden = true
            if predicate == nil || predicate == emptyPredicate {
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
        viewController(self, didPassedData: NSCompoundPredicate(andPredicateWithSubpredicates: []))
    }
    

}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            CoreDataManager.instance.delete(object: self.players[indexPath.row])
            self.fetchData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return [delete]
    }
    
}


extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath)
        if let cell = cell as? PlayerTableViewCell {
            cell.configureCell(with: players[indexPath.row])
        }
        return cell
    }
    
}

extension MainViewController: SearchDelegate {
    func viewController(_ viewController: UIViewController, didPassedData predicate: NSCompoundPredicate) {
        fetchData(predicate: predicate)
        playersTableView.reloadData()
    }
}
