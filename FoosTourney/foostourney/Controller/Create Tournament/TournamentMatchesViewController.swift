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
    @IBOutlet weak var primaryAction: UIButton!
    
    var ref: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle!
    
    var playerIds: [DataSnapshot]! = []
    
    var createTournament: CreateTournament!
    
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
    
    func configureDatabase() {
        ref = Database.database().reference()
        print("SelectTournamentPlayersViewController groupId : \(createTournament.groupId)")
        _refHandle = ref.child("groups/\(createTournament.groupId!)/members").observe(.childAdded) { (memberSnapshot: DataSnapshot) in
            print("Member memberSnapshot.childrenCount \(memberSnapshot.childrenCount)")
            if memberSnapshot.childrenCount > 0 {
                self.playerIds.append(memberSnapshot)
                self.tableView.reloadData()
            }
        }
    }

}

extension TournamentMatchesViewController: UITableViewDelegate, UITableViewDataSource {
    
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
