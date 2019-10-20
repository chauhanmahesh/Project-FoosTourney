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
    
    var ref: DatabaseReference!
    
    var createTournament: CreateTournament!
    
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
        configureDatabase()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
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
        } else {
            var teamOneName = ""
            for player in teamOne.players {
                ref.child("members/\(player.playerId)").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let value = snapshot.value as? NSDictionary
                        let memberName = value?[DatabaseFields.CommonFields.name] as? String ?? ""
                        if teamOneName.isEmpty {
                            teamOneName.append(memberName)
                            if self.createTournament.tournamentType == .singles {
                                cell.teamOne.text = teamOneName
                            } else {
                                teamOneName.append("/")
                            }
                        } else {
                            teamOneName.append(memberName)
                            cell.teamOne.text = teamOneName
                        }
                    }
                })
            }
        }
        
        if let teamTwoName = teamTwo.teamName {
            cell.teamTwo.text = teamTwoName
        } else {
            var teamTwoName = ""
            for player in teamTwo.players {
                ref.child("members/\(player.playerId)").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let value = snapshot.value as? NSDictionary
                        let memberName = value?[DatabaseFields.CommonFields.name] as? String ?? ""
                        if teamTwoName.isEmpty {
                            teamTwoName.append(memberName)
                            if self.createTournament.tournamentType == .singles {
                                cell.teamTwo.text = teamTwoName
                            } else {
                                teamTwoName.append("/")
                            }
                        } else {
                            teamTwoName.append(memberName)
                            cell.teamTwo.text = teamTwoName
                        }
                    }
                })
            }
        }
        
        return cell
    }
    
}
