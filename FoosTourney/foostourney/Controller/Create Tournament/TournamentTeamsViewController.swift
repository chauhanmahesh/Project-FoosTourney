//
//  TournamentTeamsViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 15/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TournamentTeamsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference!
    
    var createTournament: CreateTournament!
    
    @IBAction func onPrimaryAction() {
        createTournament.matches = GenericUtility.generateMatches(allTeams: createTournament.teams)
        performSegue(withIdentifier: "generateDoublesMatches", sender: self)
    }
    
    override func viewDidLoad() {
        configureDatabase()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "generateDoublesMatches" {
            let matchesVC = segue.destination as! TournamentMatchesViewController
            matchesVC.createTournament = createTournament
        }
        
    }
    
}

extension TournamentTeamsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.createTournament.teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamViewCell") as! TeamViewCell
        
        let playerOneId = self.createTournament.teams[indexPath.row].players[0].playerId
        let playerTwoId = self.createTournament.teams[indexPath.row].players[1].playerId
        print("PlayerOne : \(playerOneId), PlayerTwo : \(playerTwoId)")
        
        // Now let's find out the name of the player one.
        ref.child("members/\(playerOneId)").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let value = snapshot.value as? NSDictionary
                let memberName = value?[DatabaseFields.CommonFields.name] as? String ?? ""
                cell.playerOne.text = memberName
            }
        })
        // Now let's find out the name of the player two.
        ref.child("members/\(playerTwoId)").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                let value = snapshot.value as? NSDictionary
                let memberName = value?[DatabaseFields.CommonFields.name] as? String ?? ""
                cell.playerTwo.text = memberName
            }
        })
        // Now lets show the teamname.
        if let teamName = self.createTournament.teams[indexPath.row].teamName {
            cell.teamName.text = teamName
        }
        return cell
    }
    
}
