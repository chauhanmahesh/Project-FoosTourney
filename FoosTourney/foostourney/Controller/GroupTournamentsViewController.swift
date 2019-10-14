//
//  GroupTournamentsViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 12/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class GroupTournamentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle!
    
    var tournaments: [DataSnapshot]! = []
    var currentSelectedGroupId: String?
    
    override func viewDidLoad() {
        configureDatabase()
        // Let's check first if user has selected any group to begin with or not. We can't show any tournaments if the group is not selected yet.
        checkGroupSelected()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
    func checkGroupSelected() {
        if let userGroupDict = UserDefaults.standard.dictionary(forKey: UserDefaultsKey.userGroupDict) {
            if let currentUserGroupSelected = userGroupDict[Auth.auth().currentUser?.uid ?? ""] {
                currentSelectedGroupId = currentUserGroupSelected as! String
                // Let's fetch the selected group tournaments.
                showGroupTournaments()
                // Let's find the selected group name.
                setupGroupName()
            } else {
                // No group is selected for this user, let's ask user to select the group now.
                self.performSegue(withIdentifier: "showTournaments", sender: self)
            }
        } else {
            // Dictionary is not yet created means this is the first time. Let's ask user to choose group here as well.
            self.performSegue(withIdentifier: "showTournaments", sender: self)
        }
    }
    
    func showGroupTournaments() {
        _refHandle = ref.child("groups/\(currentSelectedGroupId!)/tournaments").observe(.childAdded) { (tournamentSnapshot: DataSnapshot) in
            print("Tournament snapshot \(tournamentSnapshot)")
            if tournamentSnapshot.childrenCount > 0 {
                self.tournaments.append(tournamentSnapshot)
                self.tableView.reloadData()
            }
        }
    }
    
    func setupGroupName() {
        ref.child("groups/\(currentSelectedGroupId!)").observeSingleEvent(of: .value, with: { (snapshot) in
          print("GroupName \(snapshot)")
            // Get user value
          let value = snapshot.value as? NSDictionary
          let groupName = value?["name"] as? String ?? ""
          self.title = groupName
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createTournament" {
            let nav = segue.destination as! UINavigationController
            let tournamentNameVC = nav.topViewController as! TournamentNameViewController
            
            let createTournamentModel: CreateTournament = CreateTournament()
            createTournamentModel.groupId = currentSelectedGroupId
            tournamentNameVC.createTournament = createTournamentModel
        }
    }
    
}

extension GroupTournamentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tournaments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TournamentViewCell") as! TournamentViewCell
        let tournamentSnapshot: DataSnapshot! = tournaments[indexPath.row]
        let tournament = tournamentSnapshot.value as! Dictionary<String, Any>
        cell.name.text = tournament[DatabaseFields.CommonFields.name] as! String
        let status = tournament[DatabaseFields.TournamentFields.status] as! String
        if status == "In Progress" {
            cell.status.backgroundColor = UIColor.init(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        } else {
            cell.status.backgroundColor = UIColor.init(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.0)
        }
        cell.status.text = "  \(status)  "
        cell.status.layer.cornerRadius = 10
        cell.status.layer.masksToBounds = true
        return cell
    }
    
}
