//
//  TournamentStandingsViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 20/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TournamentStandingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference!
    fileprivate var _childAddedRefHandle: DatabaseHandle!
    var groupId: String!
    var tournamentId: String!
    
    var teams: [DataSnapshot]! = []
    
    override func viewDidLoad() {
        configureDatabase()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        observeChanges()
    }
    
    func observeChanges() {
        ref.child("groups/\(groupId!)/tournaments/\(tournamentId!)/teams").observe(.childAdded) { (teamSnapshot: DataSnapshot) in
            if teamSnapshot.childrenCount > 0 {
                self.teams.append(teamSnapshot)
                self.tableView.reloadData()
            }
        }
        ref.child("groups/\(groupId!)/tournaments/\(tournamentId!)/teams").observe(.childRemoved) { (teamSnapshot: DataSnapshot) in
            if teamSnapshot.childrenCount > 0 {
                self.teams.removeAll(where: {
                    return $0.key == teamSnapshot.key
                })
                self.tableView.reloadData()
            }
        }
        ref.child("groups/\(groupId!)/tournaments/\(tournamentId!)/teams").observe(.childRemoved) { (teamSnapshot: DataSnapshot) in
            if teamSnapshot.childrenCount > 0 {
                let matchedSnapshot = self.teams.first(where: {
                    return $0.key == teamSnapshot.key
                })
                if let matchedItem = matchedSnapshot {
                    if let index = self.teams.firstIndex(of: matchedItem) {
                        self.teams[index] = teamSnapshot
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
}

extension TournamentStandingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StandingViewCell") as! StandingViewCell
        
        let teamSnapshot: DataSnapshot! = self.teams[indexPath.row]
        let teamDict = teamSnapshot.value as! Dictionary<String, Any>
        
        let players = teamDict[DatabaseFields.TournamentFields.players] as! Dictionary<String, Any>
        if players.count == 2 {
            // Means this is doubles tournament.
            cell.teamOrPlayerName.text = teamDict[DatabaseFields.CommonFields.name] as! String
        } else {
            // Let's prepare team name from player data.
            let players = teamDict[DatabaseFields.TournamentFields.players] as! Dictionary<String, Any>
            var teamName = ""
            let playerKeys = players.keys.map {
                $0
            }
            for playerKey in playerKeys {
                let playerId = (players[playerKey] as! Dictionary<String, Any>)[DatabaseFields.CommonFields.id]
                ref.child("members/\(playerId!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let value = snapshot.value as? NSDictionary
                        let memberName = value?[DatabaseFields.CommonFields.name] as? String ?? ""
                        if teamName.isEmpty {
                            teamName.append(memberName)
                            if playerKeys.count == 1 {
                                // Singles tournament.
                                cell.teamOrPlayerName.text = teamName
                            } else {
                                teamName.append("/")
                            }
                        } else {
                            teamName.append(memberName)
                            cell.teamOrPlayerName.text = teamName
                        }
                    }
                })
            }
        }
        return cell
    }
    
}
