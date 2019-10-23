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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var ref: DatabaseReference!
    fileprivate var _childAddedRefHandle: DatabaseHandle!
    var groupId: String!
    var tournamentId: String!
    var membersNameData: [String: String] = [:]
    
    var teams: [DataSnapshot]! = []
    
    override func viewDidLoad() {
        activityIndicator.startAnimating()
        ref = Database.database().reference()
        // Let's fetch member details (such as name) before populating any data. Because we don't want to fetch memberName asynchrously for each row. This could
        // mess up the tableview data.
        fetchMembersData(ref: ref, completion: { membersData in
            self.membersNameData = membersData
            self.activityIndicator.stopAnimating()
            // Data fetch complete. So now let's observe match changes.
            self.observeChanges()
        })
    }
    
    func observeChanges() {
        ref.child("groups/\(groupId!)/tournaments/\(tournamentId!)/teams").queryOrdered(byChild: "points").observe(.childAdded) { (teamSnapshot: DataSnapshot) in
            if teamSnapshot.childrenCount > 0 {
                self.teams.append(teamSnapshot)
                self.teams.reverse()
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
        return section == 0 ? 1 : self.teams.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StandingViewCell") as! StandingViewCell
        
        if indexPath.section == 0 {
            // Let's set headers.
            cell.played.text = "Played"
            cell.won.text = "Won"
            cell.points.text = "Points"
        } else {
            let teamSnapshot: DataSnapshot! = self.teams[indexPath.row]
            let teamDict = teamSnapshot.value as! Dictionary<String, Any>
            
            let teamOrPlayerPoints = teamDict[DatabaseFields.TeamFields.points] as? Int ?? 0
            var showLeaderTrophy = true
            if indexPath.row == 0 && teamOrPlayerPoints == 0 {
                // This means no matches is scored yet in this tournament. Hence we can't say who is leader. In this case we won't show any trophy.
                showLeaderTrophy = false
            } else {
                showLeaderTrophy = true
            }
            
            if let teamName = teamDict[DatabaseFields.CommonFields.name] as? String {
                cell.teamOrPlayerName.text = "\(teamName) \(indexPath.row == 0 && showLeaderTrophy ? "🏆" : "")"
            } else {
                let players = teamDict[DatabaseFields.TournamentFields.players] as! Dictionary<String, Any>
                let playerKeys = players.keys.map {
                    $0
                }
                let playerId = (players[playerKeys[0]] as! Dictionary<String, Any>)[DatabaseFields.CommonFields.id] as! String
                cell.teamOrPlayerName.text = "\(membersNameData[playerId] ?? "") \(indexPath.row == 0 && showLeaderTrophy ? "🏆" : "")"
            }
            
            // Let's udpate the stats.
            cell.played.text = "\(teamDict[DatabaseFields.TeamFields.matchesPlayed] as? Int ?? 0)"
            cell.won.text = "\(teamDict[DatabaseFields.TeamFields.matchesWon] as? Int ?? 0)"
            cell.points.text = "\(teamOrPlayerPoints)"
        }
        return cell
    }
    
}
