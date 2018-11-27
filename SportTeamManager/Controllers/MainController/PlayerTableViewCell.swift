//
//  PlayerTableViewCell.swift
//  SportTeamManager
//
//  Created by Вероника Данилова on 19/11/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playerNumberLabel: UILabel!
    @IBOutlet weak var playerFullnameLabel: UILabel!
    @IBOutlet weak var playerPhotoImageView: UIImageView!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var nationalityLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var inPlayLabel: UILabel!
    public var id: UUID!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    func configureCell(with player: Player) {

        id = player.id
        playerNumberLabel.text = player.number
        playerFullnameLabel.text = player.fullname
        playerPhotoImageView.image = player.image as? UIImage
        teamLabel.text = player.team
        nationalityLabel.text = player.nationality
        positionLabel.text = player.position
        ageLabel.text = "\(player.age)"
        
        if player.inPlay {
            inPlayLabel.text = "In Play"
            inPlayLabel.textColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
        } else {
            inPlayLabel.text = "On Bench"
            inPlayLabel.textColor = #colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1)
        }
    
    }
    
}
