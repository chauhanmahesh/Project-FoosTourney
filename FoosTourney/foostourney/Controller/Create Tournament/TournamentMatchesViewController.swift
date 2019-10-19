//
//  TournamentMatchesViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 15/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TournamentMatchesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference!
    
    var createTournament: CreateTournament!
    
    @IBAction func startTournament() {
        var tournament: [String: Any] = [DatabaseFields.CommonFields.name: createTournament.tournamentName!]
        tournament[DatabaseFields.TournamentFields.status] = "In Progress"
        let newTournamentRef = ref.child("groups/\(createTournament.groupId!)/tournaments").childByAutoId()
        newTournamentRef.setValue(tournament)
        // Let's add matches.
        for match in createTournament.matches {
            let matchRef = newTournamentRef.child("matches").childByAutoId()
            
            for team in match.teams {
                let teamRef = matchRef.child("teams").childByAutoId()
                var teamData: [String: Any] = [DatabaseFields.CommonFields.name: team.teamName]
                teamRef.setValue(teamData)
                
                for player in team.players {
                    let playerRef = teamRef.child("players").childByAutoId()
                    var playerData = [DatabaseFields.CommonFields.id: player.playerId]
                    playerRef.setValue(playerData)
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

extension TournamentMatchesViewController: UITableViewDelegate, UITableViewDataSource {
    
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
                print("Getting player details for : \(player.playerId)")
                ref.child("members/\(player.playerId)").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let value = snapshot.value as? NSDictionary
                        let memberName = value?[DatabaseFields.CommonFields.name] as? String ?? ""
                        print("Getting player details for  memberName: \(memberName)")
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
