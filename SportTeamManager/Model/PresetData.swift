//
//  PresetData.swift
//  SportTeamManager
//
//  Created by Вероника Данилова on 20/11/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

//  Структура, создающая пресет данных для наглядности при первом запуске приложения. Данные создаются только один раз, после чего в UserDefaults записывается флаг isPresetDataStored в значении true.

struct PresetData {
    
    private let players = [
        
        ["fullname" : "Jonas Valanciunas", "number" : "17", "nationality" : "Lithuanian", "age" : "26", "position" : "Centre", "team" : "Toronto Raptors", "inPlay": "yes", "image" : "Jonas-Valanciunas"],
        
        ["fullname" : "Kris Dunn", "number" : "32", "nationality" : "", "age" : "24", "position" : "Point guard", "team" : "Chicago Bulls", "image" : "Kris-Dunn"],
        
        ["fullname" : "Robin Lopez", "number" : "42", "nationality" : "American", "age" : "30", "position" : "Centre", "team" : "Chicago Bulls", "inPlay": "yes", "image" : "Robin-Lopez"],
        
        ["fullname" : "Chris Boucher", "number" : "25", "nationality" : "Canadian", "age" : "25", "position" : "Power forward", "team" : "Toronto Raptors", "image" : "Chris-Boucher"],
        
        ["fullname" : "Fred Hoiberg", "number" : "--", "nationality" : "American", "age" : "46", "position" : "Coach", "team" : "Chicago Bulls", "image" : "Fred-Hoiberg"]
        
    ]
    
    public func recordPresetData() {
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "isPresetDataStored") {
            return
        } else {
            userDefaults.set(true, forKey: "isPresetDataStored")
            
            for player in players {
                let context = CoreDataManager.instance.getContext()
                
                let teamEntity = CoreDataManager.instance.createObject(from: Team.self)
                teamEntity.name = player["team"]
                
                let playerEntity = CoreDataManager.instance.createObject(from: Player.self)
                if player["age"] != "" {
                    if let playerAge = Int16(player["age"]!) {
                        playerEntity.age = playerAge
                    }
                }
                if player["nationality"] != "" {
                    playerEntity.nationality = player["nationality"]
                }
                if player["number"] != "" {
                    playerEntity.number = player["number"]
                }
                
                playerEntity.fullname = player["fullname"]
                playerEntity.position = player["position"]
                playerEntity.team = player["team"]
                
                if player["inPlay"] != nil {
                    playerEntity.inPlay = true
                }
                
                if let photo = player["image"] {
                    playerEntity.image = UIImage(named: photo)
                } else {
                    playerEntity.image = UIImage(named: "defaultPhoto")
                }
                
                CoreDataManager.instance.save(context: context)
            }
        }
    }

}
