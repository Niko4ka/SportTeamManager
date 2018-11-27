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
    private var playerShouldBeInPlay: Bool!

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
        
        let cell = tableView.cellForRow(at: indexPath) as! PlayerTableViewCell
        let inPlayStatusTitle = changePlayStatus(from: cell.inPlayLabel.text!)
        
        let inPlayStatus = UITableViewRowAction(style: .normal, title: inPlayStatusTitle) { (action, indexPath) in
            
            let context = CoreDataManager.instance.getContext()
            let selectedPlayer = CoreDataManager.instance.findPlayer(withID: cell.id).first
            selectedPlayer?.inPlay = self.playerShouldBeInPlay
            CoreDataManager.instance.save(context: context)
            tableView.reloadRows(at: [indexPath], with: .fade)
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
    
    private func changePlayStatus(from currentStatus: String) -> String {
        switch currentStatus {
        case "In Play":
            playerShouldBeInPlay = false
            return "To Bench"
        case "On Bench":
            playerShouldBeInPlay = true
            return "To Play"
        default:
            return "Unknown"
        }
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
