//
//  TeamsViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 15/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

// ViewController which is responsible to display the list of teams generated from the selected players.
class TeamsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var ref: DatabaseReference!
    // Holds the tournament information which will be used to create this tournament.
    var createTournament: CreateTournament!
    // Dictionary to hold the name of all players against their snapshot id.
    var membersNameData: [String: String] = [:]
    
    @IBAction func onPrimaryAction() {
        createTournament.matches = GenericUtility.generateMatches(allTeams: createTournament.teams)
        performSegue(withIdentifier: "generateDoublesMatches", sender: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "generateDoublesMatches" {
            let matchesVC = segue.destination as! MatchesViewController
            matchesVC.createTournament = createTournament
        }
    }
    
}

extension TeamsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.createTournament.teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamViewCell") as! TeamViewCell
                
        let playerOneId = self.createTournament.teams[indexPath.row].players[0].playerId
        cell.playerOne.text = membersNameData[playerOneId]
        
        let playerTwoId = self.createTournament.teams[indexPath.row].players[1].playerId
        cell.playerTwo.text = membersNameData[playerTwoId]
        
        // Now lets show the teamname.
        if let teamName = self.createTournament.teams[indexPath.row].teamName {
            cell.teamName.text = teamName
        }
        return cell
    }
    
}
