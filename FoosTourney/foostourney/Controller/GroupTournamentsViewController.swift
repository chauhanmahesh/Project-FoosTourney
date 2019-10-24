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

// ViewController which is responsible to display the  list of tournaments for the selected group with their current status i.e. "In Progress" or "Completed".
class GroupTournamentsViewController: UIViewController, GroupSelectionDelegateProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createTournament: UIBarButtonItem!
    
    var ref: DatabaseReference!
    // Holds the tournament snapshots for the selected group.
    var tournaments: [DataSnapshot]! = []
    // Holds the currently selected group id.
    var currentSelectedGroupId: String?
    
    override func viewDidLoad() {
        ref = Database.database().reference()
        checkGroupSelected()
    }
    
    func onGroupSelected() {
        // Delegate method from ChooseGroupViewController.
        // Will fetch again.
        checkGroupSelected()
        tournaments = [] // Let's clear current tournaments.
        tableView.reloadData()
    }
    
    // Checks which group is currently selected. And if not then it display the viewController so that user can choose the group.
    func checkGroupSelected() {
        if let userGroupDict = UserDefaults.standard.dictionary(forKey: UserDefaultsKey.userGroupDict) {
            if let currentUserGroupSelected = userGroupDict[Auth.auth().currentUser?.uid ?? ""] {
                createTournament.isEnabled = true
                currentSelectedGroupId = currentUserGroupSelected as! String
                // Let's fetch the selected group tournaments.
                observeTournamentChanges()
                // Let's find the selected group name.
                setupGroupName()
            } else {
                createTournament.isEnabled = false
                // No group is selected for this user, let's ask user to select the group now.
                self.performSegue(withIdentifier: "changeGroup", sender: self)
            }
        } else {
            createTournament.isEnabled = false
            // Dictionary is not yet created means this is the first time. Let's ask user to choose group here as well.
            self.performSegue(withIdentifier: "changeGroup", sender: self)
        }
    }
    
    // Observe changes to "/groups/tournaments"
    func observeTournamentChanges() {
        ref.child("groups/\(currentSelectedGroupId!)/tournaments").observe(.childAdded) { (tournamentSnapshot: DataSnapshot) in
            if tournamentSnapshot.childrenCount > 0 {
                self.tournaments.append(tournamentSnapshot)
                self.tableView.reloadData()
            }
        }
        ref.child("groups/\(currentSelectedGroupId!)/tournaments").observe(.childRemoved) { (tournamentSnapshot: DataSnapshot) in
            if tournamentSnapshot.childrenCount > 0 {
                self.tournaments.removeAll(where: {
                    return $0.key == tournamentSnapshot.key
                })
                self.tableView.reloadData()
            }
        }
        ref.child("groups/\(currentSelectedGroupId!)/tournaments").observe(.childChanged) { (tournamentSnapshot: DataSnapshot) in
            if tournamentSnapshot.childrenCount > 0 {
                let matchedSnapshot = self.tournaments.first(where: {
                    return $0.key == tournamentSnapshot.key
                })
                if let matchedItem = matchedSnapshot {
                    if let index = self.tournaments.firstIndex(of: matchedItem) {
                        self.tournaments[index] = tournamentSnapshot
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // Sets up the group name on the navigationBar as a title.
    func setupGroupName() {
        ref.child("groups/\(currentSelectedGroupId!)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let groupName = value?["name"] as? String ?? ""
            self.navigationItem.title = groupName
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createTournament" {
            let nav = segue.destination as! UINavigationController
            let tournamentNameVC = nav.topViewController as! EnterNameViewController
            
            let createTournamentModel: CreateTournament = CreateTournament()
            createTournamentModel.groupId = currentSelectedGroupId
            tournamentNameVC.createTournament = createTournamentModel
        } else if segue.identifier == "showTournamentDetail" {
            let tournamentDetailVC = segue.destination as! TournamentDetailViewController
            tournamentDetailVC.groupId = currentSelectedGroupId
            tournamentDetailVC.tournamentId = (tournaments[tableView.indexPathForSelectedRow?.row ?? 0] as DataSnapshot).key
        } else if segue.identifier == "changeGroup" {
            let nav = segue.destination as! UINavigationController
            let chooseGroupVC = nav.topViewController as! ChooseGroupViewController
            chooseGroupVC.delegate = self
        }
    }
    
}

extension GroupTournamentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.tournaments.count == 0) {
            if let selectedGroup = currentSelectedGroupId {
                self.tableView.setEmptyMessage("Looks like you are working really hard. No tournaments are organised yet, let's create one by tapping on '+'.")
            } else {
                self.tableView.setEmptyMessage("You haven't selected any group yet. Please select a group to begin with or create a new one.")
            }
        } else {
            self.tableView.restore()
        }
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
