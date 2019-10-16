//
//  GenericUtility.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 16/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import Firebase

class GenericUtility {
    
    // Returned teams will of this form.
    // [[Player, Player], [Player, Player].....]
    class func generateTeams(allPlayerSnapshots: [DataSnapshot], selectedIndexs: [Int]) -> [[String]] {
        // Let's get the selected indexes.
        var selectedPlayers = selectedIndexs
        var teams: [[String]] = []
        var currentTeam: [String] = []
        
        repeat {
            // Let's get random element.
            let randomPlayer = selectedPlayers.randomElement()!
            
            let player = allPlayerSnapshots[randomPlayer].value as! Dictionary<String, Any>
            currentTeam.append(player[DatabaseFields.CommonFields.id] as! String)
            if currentTeam.count == 2 {
                teams.append(currentTeam)
                currentTeam = []
            }
            selectedPlayers.remove(at: selectedPlayers.firstIndex(of: randomPlayer) ?? 0)
            
        } while selectedPlayers.count > 0
        
        print("Teams: \(teams)")
        print("---------------------------------------------")
        print("Matches: \(generateMatches(allTeams: teams))")
        return teams
    }
    
    // Returned matches will look like.
    // If tournament type is doubles then matches will look like ->
    // [
    //      // Match 1
    //      [
    //          // Team 1
    //          [
    //              Player1,
    //              Player2
    //          ],
    //          // Team 2
    //          [
    //              Player1,
    //              Player2
    //          ]
    //      ]
    // ]........
    //
    // // If tournament type is singles then matches will look like ->
    // [
    //      // Match 1
    //      [
    //          // Team 1
    //          [
    //              Player
    //          ],
    //          // Team 2
    //          [
    //              Player
    //          ]
    //      ]
    // ]........
    // Also all teams (singles or doubles) will play a single match with each opponent.
    class func generateMatches(allTeams: [[String]]) -> [[[String]]] {
        var matches: [[[String]]] = []
        var teams = allTeams
        var currentTeam: [String] = []
        repeat {
            if currentTeam.count == 0 {
                // Let's assign a team here.
                currentTeam = teams.first!
            }
            // Now currentTeam will play matches will all other teams
            for otherTeam in teams.filter({$0 != currentTeam}) {
                matches.append([currentTeam, otherTeam])
            }
            currentTeam = []
            teams.remove(at: teams.firstIndex(of: currentTeam) ?? 0)
        } while teams.count > 0
        return matches
    }

}
