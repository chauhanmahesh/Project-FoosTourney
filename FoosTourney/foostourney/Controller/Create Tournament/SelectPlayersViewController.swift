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

class SelectPlayersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var primaryAction: UIButton!
    
    var ref: DatabaseReference!
    
    var playerIds: [DataSnapshot]! = []
    
    var createTournament: CreateTournament!
    
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
        primaryAction.isEnabled = totalRows >= 2
    }
    
    override func viewDidLoad() {
        configureDatabase()
        updateAction()
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
        primaryAction.isEnabled = (tableView.indexPathsForSelectedRows?.count ?? 0) >= 2
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        primaryAction.isEnabled = (tableView.indexPathsForSelectedRows?.count ?? 0) >= 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerViewCell") as! PlayerViewCell
        let playerIdSnapshot: DataSnapshot! = playerIds[indexPath.row]
        let player = playerIdSnapshot.value as! Dictionary<String, Any>
        
        let playerId = player[DatabaseFields.CommonFields.id] as! String
        
        // Now let's find out the name of the player.
        ref.child("members/\(playerId)").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let value = snapshot.value as? NSDictionary
                let memberName = value?[DatabaseFields.CommonFields.name] as? String ?? ""
                cell.name.text = memberName
            }
        })
        
        return cell
    }
    
}

