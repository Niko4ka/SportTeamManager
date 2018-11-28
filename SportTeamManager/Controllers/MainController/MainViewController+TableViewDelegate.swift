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
        
        let currentPlayer = self.fetchedResultController.object(at: indexPath)
        let isCurrentPlayerInPlay = currentPlayer.inPlay
        let inPlayStatusTitle = isCurrentPlayerInPlay ? "To Bench" : "To Game"
        
        // Action, that changes inPlay status
        
        let inPlayStatus = UITableViewRowAction(style: .normal, title: inPlayStatusTitle) { (action, indexPath) in
            
            currentPlayer.inPlay = !isCurrentPlayerInPlay
            let context = CoreDataManager.instance.getContext()
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
            
            let storyboard = UIStoryboard(name: "PlayerViewController", bundle: nil)
            let playerViewController = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
            playerViewController.editingPlayer = currentPlayer
            self.navigationController?.pushViewController(playerViewController, animated: true)
        }
        edit.backgroundColor = UIColor.orange
        
        
        return [delete, edit, inPlayStatus]
    }
    
}
