//
//  MainViewController+TableViewDelegate.swift
//  SportTeamManager
//
//  Created by Вероника Данилова on 28/11/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Action, that changes inPlay status
        
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
        
        // Delete action
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            let item = self.fetchedResultController.object(at: indexPath)
            CoreDataManager.instance.delete(object: item)
        }
        
        // Edit action
        
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
