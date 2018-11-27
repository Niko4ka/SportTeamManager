//
//  EditingPlayer.swift
//  SportTeamManager
//
//  Created by Вероника Данилова on 27/11/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

struct EditingPlayer {
    
    var id: UUID
    var number: String
    var photo: UIImage
    var fullname: String
    var nationality: String
    var age: String
    var team: Team
    var position: String
    var inPlay: Bool
    
    init(playerID: UUID, playerNumber: String, playerPhoto: UIImage, playerFullname: String, playerNationality: String, playerAge: Int16, playerTeam: Team, playerPosition: String, playerInPlay: Bool) {
        
        self.id = playerID
        self.number = playerNumber
        self.photo = playerPhoto
        self.fullname = playerFullname
        self.nationality = playerNationality
        self.age = String(playerAge)
        self.team = playerTeam
        self.position = playerPosition
        self.inPlay = playerInPlay
    }
}
