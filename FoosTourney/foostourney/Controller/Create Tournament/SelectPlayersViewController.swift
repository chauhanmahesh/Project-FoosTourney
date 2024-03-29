//
//  SelectPlayersViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 14/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

// ViewController which is responsible to display the list of players available in this group so that user can select which players should be part of this tournament.
class SelectPlayersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var primaryAction: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var topLabel: UILabel!
    
    var ref: DatabaseReference!
    
    // Holds all the player snapshots.
    var playerIds: [DataSnapshot]! = []
    
    // Holds the tournament information which will be used to create this tournament.
    var createTournament: CreateTournament!
    // Dictionary to hold the name of all players against their snapshot id.
    var membersNameData: [String: String] = [:]
    
    @IBAction func onPrimaryAction() {
        if createTournament.tournamentType == .singles {
            // Let's first prepare teams structure. We need to get the selected players from the list.
            let teams: [Team] = tableView.indexPathsForSelectedRows!.map {
                let snapshot = playerIds[$0.row]
                
                let player = snapshot.value as! Dictionary<String, Any>
                let playerId = player[DatabaseFields.CommonFields.id] as! String
                
                let playerModel = Player(playerId: playerId)
                createTournament.players.append(playerModel)
                
                let teamModel = Team(players: [playerModel])
                createTournament.teams.append(teamModel)
                return teamModel
            }
            createTournament.matches = GenericUtility.generateMatches(allTeams: teams)
            performSegue(withIdentifier: "generateSinglesMatches", sender: self)
        } else {
            // We also need to write players in createTournament.
            createTournament.players = tableView.indexPathsForSelectedRows!.map {
                let player = playerIds[$0.row].value as! Dictionary<String, Any>
                let playerId = player[DatabaseFields.CommonFields.id] as! String
                let playerModel = Player(playerId: playerId)
                return playerModel
            }
            createTournament.teams = GenericUtility.generateTeams(allPlayerSnapshots: playerIds, selectedIndexs: tableView.indexPathsForSelectedRows!.map{ return $0.row })
            performSegue(withIdentifier: "generateTeams", sender: self)
        }
    }
    
    @IBAction func selectAllPlayers() {
        let totalRows = tableView.numberOfRows(inSection: 0)
        for row in 0..<totalRows {
            tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: UITableView.ScrollPosition.none)
        }
        // If total items selected are at least two then only the tournament can be created.
        primaryAction.isEnabled = createTournament.tournamentType == .singles ? totalRows >= 2 : (totalRows >= 4 && totalRows % 2 == 0)
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
            self.observeChanges()
        })
        
        updateAction()
        updateLabel()
    }
    
    func updateLabel() {
        // If tournament is singles tournament then we need minimum 2 players to start tournament. If its doubles then we need min 4 players and also players should be of even number.
        if createTournament.tournamentType == .singles {
            topLabel.text = "Select 2 players minimum."
        } else {
            topLabel.text = "Select even number of players and minimum 4"
        }
    }
    
    func updateAction() {
        // If this tournament is single player tournament then we will directly generate matches otherwise will generate teams first and then matches.
        if createTournament.tournamentType == .singles {
            primaryAction.setTitle("Generate Matches", for: .normal)
        } else {
            primaryAction.setTitle("Generate Teams", for: .normal)
        }
        // Let's disable the button to start with. The button will be enabled once user will start selecting the players and after validating if the selected players are enough or not.
        primaryAction.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "generateTeams" {
            let teamsVC = segue.destination as! TeamsViewController
            teamsVC.createTournament = createTournament
        }
        
        if segue.identifier == "generateSinglesMatches" {
            let matchesVC = segue.destination as! MatchesViewController
            matchesVC.createTournament = createTournament
        }
        
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        observeChanges()
    }
    
    // Observing changes on '/members'
    func observeChanges() {
        ref.child("groups/\(createTournament.groupId!)/members").observe(.childAdded) { (memberSnapshot: DataSnapshot) in
            if memberSnapshot.childrenCount > 0 {
                self.playerIds.append(memberSnapshot)
                self.tableView.reloadData()
            }
        }
        ref.child("groups/\(createTournament.groupId!)/members").observe(.childRemoved) { (memberSnapshot: DataSnapshot) in
            if memberSnapshot.childrenCount > 0 {
                self.playerIds.removeAll(where: {
                    return $0.key == memberSnapshot.key
                })
                self.tableView.reloadData()
            }
        }
        ref.child("groups/\(createTournament.groupId!)/members").observe(.childChanged) { (memberSnapshot: DataSnapshot) in
            if memberSnapshot.childrenCount > 0 {
                let matchedSnapshot = self.playerIds.first(where: {
                    return $0.key == memberSnapshot.key
                })
                if let matchedItem = matchedSnapshot {
                    if let index = self.playerIds.firstIndex(of: matchedItem) {
                        self.playerIds[index] = memberSnapshot
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

}

extension SelectPlayersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playerIds.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        primaryAction.isEnabled = createTournament.tournamentType == .singles ? (tableView.indexPathsForSelectedRows?.count ?? 0) >= 2 : ((tableView.indexPathsForSelectedRows?.count ?? 0) >= 4 && (tableView.indexPathsForSelectedRows?.count ?? 0) % 2 == 0)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        primaryAction.isEnabled = createTournament.tournamentType == .singles ? (tableView.indexPathsForSelectedRows?.count ?? 0) >= 2 : ((tableView.indexPathsForSelectedRows?.count ?? 0) >= 4 && (tableView.indexPathsForSelectedRows?.count ?? 0) % 2 == 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerViewCell") as! PlayerViewCell
        let playerIdSnapshot: DataSnapshot! = playerIds[indexPath.row]
        let player = playerIdSnapshot.value as! Dictionary<String, Any>
        
        let playerId = player[DatabaseFields.CommonFields.id] as! String
        
        cell.name.text = membersNameData[playerId]
        
        return cell
    }
    
}

