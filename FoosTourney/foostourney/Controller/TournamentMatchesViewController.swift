//
//  TournamentMatchesViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 20/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TournamentMatchesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference!
    var groupId: String!
    var tournamentId: String!
    
    var matches: [DataSnapshot]! = []
    var selectedMatchSnapshot: DataSnapshot!
    
    override func viewDidLoad() {
        configureDatabase()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        observeChanges()
    }
    
    func observeChanges() {
        ref.child("groups/\(groupId!)/tournaments/\(tournamentId!)/matches").observe(.childAdded) { (matchSnapshot: DataSnapshot) in
            if matchSnapshot.childrenCount > 0 {
                self.matches.append(matchSnapshot)
                self.tableView.reloadData()
            }
        }
        ref.child("groups/\(groupId!)/tournaments/\(tournamentId!)/matches").observe(.childRemoved) { (matchSnapshot: DataSnapshot) in
            if matchSnapshot.childrenCount > 0 {
                self.matches.removeAll(where: {
                    return $0.key == matchSnapshot.key
                })
                self.tableView.reloadData()
            }
        }
        ref.child("groups/\(groupId!)/tournaments/\(tournamentId!)/matches").observe(.childChanged) { (matchSnapshot: DataSnapshot) in
            if matchSnapshot.childrenCount > 0 {
                let matchedSnapshot = self.matches.first(where: {
                    return $0.key == matchSnapshot.key
                })
                if let matchedItem = matchedSnapshot {
                    if let index = self.matches.firstIndex(of: matchedItem) {
                        self.matches[index] = matchSnapshot
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recordScore" {
            let nav = segue.destination as! UINavigationController
            let recordMatchScoreVC = nav.topViewController as! RecordMatchScoreViewController
            recordMatchScoreVC.tournamentId = tournamentId
            recordMatchScoreVC.matchSnapshot = selectedMatchSnapshot
        }
    }
    
}

extension TournamentMatchesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matches.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.selectionStyle != UITableViewCell.SelectionStyle.none {
            selectedMatchSnapshot = self.matches[indexPath.row]
            performSegue(withIdentifier: "recordScore", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TournamentMatchViewCell") as! TournamentMatchViewCell
        
        let matchSnapshot: DataSnapshot! = matches[indexPath.row]
        let match = matchSnapshot.value as! Dictionary<String, Any>
        
        let teams = match[DatabaseFields.TournamentFields.teams] as! Dictionary<String, Any>
        let teamKeys = teams.keys.map {
            $0
        }
        let teamOne = teams[teamKeys[0]] as! Dictionary<String, Any>
        let teamTwo = teams[teamKeys[1]] as! Dictionary<String, Any>
        
        if let teamName = teamOne[DatabaseFields.CommonFields.name] as? String {
            cell.teamOne.text = teamName
        } else {
            var teamOneName = ""
            // Let's get the players.
            let players = teamOne[DatabaseFields.TournamentFields.players] as! Dictionary<String, Any>
            let playerKeys = players.keys.map {
                $0
            }
            for playerKey in playerKeys {
                let playerId = (players[playerKey] as! Dictionary<String, Any>)[DatabaseFields.CommonFields.id]
                ref.child("members/\(playerId!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let value = snapshot.value as? NSDictionary
                        let memberName = value?[DatabaseFields.CommonFields.name] as? String ?? ""
                        if teamOneName.isEmpty {
                            teamOneName.append(memberName)
                            if playerKeys.count == 1 {
                                // Singles tournament.
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
        let teamAScore = teamOne[DatabaseFields.MatchFields.score] as? Int
        if let teamScore = teamAScore {
            cell.teamOneScore.text = "\(teamScore)"
        } else {
            cell.teamOneScore.text = ""
        }
        
        if let teamName = teamTwo[DatabaseFields.CommonFields.name] as? String {
            cell.teamTwo.text = teamName
        } else {
            var teamTwoName = ""
            // Let's get the players.
            let players = teamTwo[DatabaseFields.TournamentFields.players] as! Dictionary<String, Any>
            let playerKeys = players.keys.map {
                $0
            }
            for playerKey in playerKeys {
                let playerId = (players[playerKey] as! Dictionary<String, Any>)[DatabaseFields.CommonFields.id]
                ref.child("members/\(playerId!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let value = snapshot.value as? NSDictionary
                        let memberName = value?[DatabaseFields.CommonFields.name] as? String ?? ""
                        if teamTwoName.isEmpty {
                            teamTwoName.append(memberName)
                            if playerKeys.count == 1 {
                                // Singles tournament.
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
        let teamBScore = teamTwo[DatabaseFields.MatchFields.score] as? Int
        if let teamScore = teamBScore {
            cell.teamTwoScore.text = "\(teamScore)"
        } else {
            cell.teamTwoScore.text = ""
        }
        
        // Also if the score is being recorded then let's make it unselectable.
        if teamAScore ?? 0 > 0 || teamBScore ?? 0 > 0 {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        }
        return cell
    }
    
}
