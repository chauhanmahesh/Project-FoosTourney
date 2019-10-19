//
//  SelectTournamentPlayersViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 14/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SelectTournamentPlayersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var primaryAction: UIButton!
    
    var ref: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle!
    
    var playerIds: [DataSnapshot]! = []
    
    var createTournament: CreateTournament!
    
    @IBAction func onPrimaryAction() {
        if createTournament.tournamentType == .singles {
            // Let's first prepare teams structure. We need to get the selected players from the list.
            let teams: [Team] = tableView.indexPathsForSelectedRows!.map {
                let snapshot = playerIds[$0.row]
                
                let player = snapshot.value as! Dictionary<String, Any>
                let playerId = player[DatabaseFields.CommonFields.id] as! String
                
                return Team(players: [Player(playerId: playerId)])
            }
            createTournament.matches = GenericUtility.generateMatches(allTeams: teams)
            performSegue(withIdentifier: "generateSinglesMatches", sender: self)
        } else {
            createTournament.teams = GenericUtility.generateTeams(allPlayerSnapshots: playerIds, selectedIndexs: tableView.indexPathsForSelectedRows!.map{ return $0.row })
            performSegue(withIdentifier: "generateTeams", sender: self)
        }
    }
    
    @IBAction func selectAllPlayers() {
        let totalRows = tableView.numberOfRows(inSection: 0)
        for row in 0..<totalRows {
            tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: UITableView.ScrollPosition.none)
        }
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "generateTeams" {
            let teamsVC = segue.destination as! TournamentTeamsViewController
            teamsVC.createTournament = createTournament
        }
        
        if segue.identifier == "generateSinglesMatches" {
            let matchesVC = segue.destination as! TournamentMatchesViewController
            matchesVC.createTournament = createTournament
        }
        
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        _refHandle = ref.child("groups/\(createTournament.groupId!)/members").observe(.childAdded) { (memberSnapshot: DataSnapshot) in
            if memberSnapshot.childrenCount > 0 {
                self.playerIds.append(memberSnapshot)
                self.tableView.reloadData()
            }
        }
    }

}

extension SelectTournamentPlayersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playerIds.count
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

