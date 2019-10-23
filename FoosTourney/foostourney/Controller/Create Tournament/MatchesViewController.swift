//
//  MatchesViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 15/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MatchesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var ref: DatabaseReference!
    
    var createTournament: CreateTournament!
    var membersNameData: [String: String] = [:]
    
    @IBAction func startTournament() {
        var tournament: [String: Any] = [DatabaseFields.CommonFields.name: createTournament.tournamentName!]
        tournament[DatabaseFields.TournamentFields.status] = "In Progress"
        let newTournamentRef = ref.child("groups/\(createTournament.groupId!)/tournaments").childByAutoId()
        newTournamentRef.setValue(tournament)
        
        // Let's first write all the players under tournament so that we can reuse the id when we will write those players under teams.
        var playersDict: Dictionary<String, Player> = [:]

        for player in createTournament.players {
            let playerRef = newTournamentRef.child("players").childByAutoId()
            if let key = playerRef.key {
                playersDict[key] = player
                var playerData = [DatabaseFields.CommonFields.id: player.playerId]
                playerRef.setValue(playerData)
            }
        }
        
        // Let's write all the teams now.
        var teamsDict: Dictionary<String, Team> = [:]
        
        for team in createTournament.teams {
            let teamRef = newTournamentRef.child("teams").childByAutoId()
            if let key = teamRef.key {
                teamsDict[key] = team
                var teamData: [String: Any] = [DatabaseFields.CommonFields.name: team.teamName]
                teamRef.setValue(teamData)
                
                for player in team.players {
                    // Let's get the playerRefid from /tournaments/players/
                    let playerRefKey = playersDict.first(where: {
                        $0.value == player
                        })?.key
                    if let playerKey = playerRefKey {
                        let playerRef = teamRef.child("players").child(playerKey)
                        var playerData = [DatabaseFields.CommonFields.id: player.playerId]
                        playerRef.setValue(playerData)
                    }
                }
            }
        }
        
        
        // Let's write all the matches now.
        
        for match in createTournament.matches {
            let matchRef = newTournamentRef.child("matches").childByAutoId()
            
            for team in match.teams {
                // Let' get the teamRefId from /tournaments/teams
                let teamRefKey = teamsDict.first(where: {
                    $0.value == team
                    })?.key
                if let teamKey = teamRefKey {
                    let teamRef = matchRef.child("teams").child(teamKey)
                    var teamData: [String: Any] = [DatabaseFields.CommonFields.name: team.teamName]
                    teamRef.setValue(teamData)
                    
                    for player in team.players {
                        
                        // Let's get the playerRefid from /tournaments/players/
                        let playerRefKey = playersDict.first(where: {
                            $0.value == player
                            })?.key
                        if let playerKey = playerRefKey {
                            let playerRef = teamRef.child("players").child(playerKey)
                            var playerData = [DatabaseFields.CommonFields.id: player.playerId]
                            playerRef.setValue(playerData)
                        }
                    }
                }
            }
        }
        
        // Let's dismiss.
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.activityIndicator.startAnimating()
        ref = Database.database().reference()
        // Let's fetch member details (such as name) before populating any data. Because we don't want to fetch memberName asynchrously for each row. This could
        // mess up the tableview data.
        fetchMembersData(ref: ref, completion: { membersData in
            self.membersNameData = membersData
            self.activityIndicator.stopAnimating()
            // Data fetch complete. So now let's observe match changes.
            self.tableView.reloadData()
        })
    }
    
}

extension MatchesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.createTournament.matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchViewCell") as! MatchViewCell
        
        let teamOne = self.createTournament.matches[indexPath.row].teams[0]
        let teamTwo = self.createTournament.matches[indexPath.row].teams[1]
        
        // If we already have team names generated then let's use this (which is for doubles) other let's get the player names (for singles).
        
        if let teamOneName = teamOne.teamName {
            cell.teamOne.text = teamOneName
            cell.teamTwo.text = teamTwo.teamName!
        } else {
            // Ok so this is a case when its actually singles match so we need to get the player teams from /members.
            // Let's first get the teamOne data and then we will get teamTwo data.
            // Let's get the players.
            // We can saftely assume that as its singles matches the player will be only one within a team.
            cell.teamOne.text = membersNameData[teamOne.players[0].playerId]
            cell.teamTwo.text = membersNameData[teamTwo.players[0].playerId]
        }
        
        return cell
    }
    
}
