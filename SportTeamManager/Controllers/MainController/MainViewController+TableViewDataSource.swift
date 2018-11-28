//
//  MainViewController+TableViewDataSource.swift
//  SportTeamManager
//
//  Created by Вероника Данилова on 28/11/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

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
