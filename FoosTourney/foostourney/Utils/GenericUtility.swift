//
//  GenericUtility.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 16/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import Firebase
import Fakery

// Utility class to hold any function which can be used statically from anywhere within the app.
class GenericUtility {
    
    // Generates the team (Randomly) based on the players passed.
    // - Parameters:
    //      - allPlayerSnapshots: All players snapshot within that group.
    //      - selectedIndexs: Array of index for the selected players from the list.
    // - Returns: Array of randomly generated [Team]
    //
    // Returned teams will of this form.
    // [[Player, Player], [Player, Player].....]
    class func generateTeams(allPlayerSnapshots: [DataSnapshot], selectedIndexs: [Int]) -> [Team] {
        // Let's get the selected indexes.
        var selectedPlayers = selectedIndexs
        var teams: [Team] = []
        var currentTeam: Team = Team(players: [])
        
        repeat {
            // Let's get random element.
            let randomPlayer = selectedPlayers.randomElement()!
            
            let player = allPlayerSnapshots[randomPlayer].value as! Dictionary<String, Any>
            currentTeam.players.append(Player(playerId: player[DatabaseFields.CommonFields.id] as! String))
            if currentTeam.players.count == 2 {
                // Let's generate a team name as well.
                currentTeam.teamName = randomTeamName(existingTeamNames: teams.map { $0.teamName ?? "" })
                teams.append(currentTeam)
                currentTeam.players = []
            }
            selectedPlayers.remove(at: selectedPlayers.firstIndex(of: randomPlayer) ?? 0)
            
        } while selectedPlayers.count > 0
        
        return teams
    }
    
    // Generates the matches (Randomly) based on the teams passed.
    // - Parameters:
    //      - allTeams: Array of teams which will be in the matches.
    // - Returns: Array of randomly generated [Match]
    //
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
    class func generateMatches(allTeams: [Team]) -> [Match] {
        var matches: [Match] = []
        var teams = allTeams
        var currentTeam: Team? = nil
        repeat {
            if currentTeam == nil {
                // Let's assign a team here.
                currentTeam = teams.first!
            }
            // Now currentTeam will play matches will all other teams
            for otherTeam in teams.filter({$0 != currentTeam}) {
                matches.append(Match(teams: [currentTeam!, otherTeam]))
            }
            teams.remove(at: teams.firstIndex(of: currentTeam!) ?? 0)
            currentTeam = nil
        } while teams.count > 0
        
        return matches
    }
    
    // Gives a random teamName (Using Fakery to generate random name).
    // - Parameters:
    //      - existingTeamNames: List of team names already generated.
    // - Returns: Team name generated which doesn't exist in 'existingTeamNames'
    class func randomTeamName(existingTeamNames: [String]) -> String {
        let faker = Faker(locale: "en-AU")
        var teamName: String
        repeat {
            teamName = faker.vehicle.make()
            // If team name is generated empty then this might go into infinite loop.
            if teamName.isEmpty {
                teamName = "Random"
            }
        } while existingTeamNames.contains(teamName)
        return teamName
    }

}
