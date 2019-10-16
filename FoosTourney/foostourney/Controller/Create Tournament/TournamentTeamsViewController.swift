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
    
    override func viewDidLoad() {
        configureDatabase()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
    }

}

extension TournamentTeamsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.createTournament.teams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamViewCell") as! TeamViewCell
        
        let playerOneId = self.createTournament.teams[indexPath.row][0]
        let playerTwoId = self.createTournament.teams[indexPath.row][1]
        print("PlayerOne : \(playerOneId), PlayerTwo : \(playerTwoId)")
        
        // Now let's find out the name of the player one.
        ref.child("members/\(playerOneId)").observeSingleEvent(of: .value, with: { (snapshot) in
            print("PlayerOne snapshot : \(snapshot)")
            if snapshot.exists() {
                let value = snapshot.value as? NSDictionary
                let memberName = value?[DatabaseFields.CommonFields.name] as? String ?? ""
                cell.playerOne.text = memberName
            }
        })
        // Now let's find out the name of the player two.
        ref.child("members/\(playerTwoId)").observeSingleEvent(of: .value, with: { (snapshot) in
            print("PlayerTwo snapshot : \(snapshot)")
            if snapshot.exists() {
                let value = snapshot.value as? NSDictionary
                let memberName = value?[DatabaseFields.CommonFields.name] as? String ?? ""
                cell.playerTwo.text = memberName
            }
        })
        return cell
    }
    
}
