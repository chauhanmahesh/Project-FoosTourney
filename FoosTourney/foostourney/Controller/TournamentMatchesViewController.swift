//
//  TournamentMatchesViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 20/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TournamentMatchesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var ref: DatabaseReference!
    var groupId: String!
    var tournamentId: String!
    
    var matches: [DataSnapshot]! = []
    var selectedMatchSnapshot: DataSnapshot!
    
    var membersNameData: [String: String] = [:]
    
    // Keeping this to track whether we updated the tournament status or not. We don't want to update it all the time.
    var tournamentStatusUpdated = false
    
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
        ref.child("groups/\(groupId!)/tournaments/\(tournamentId!)/matches").observe(.childAdded) { (matchSnapshot: DataSnapshot) in
            if matchSnapshot.childrenCount > 0 {
                self.matches.append(matchSnapshot)
                self.tableView.reloadData()
            }
        }
        ref.child("groups/\(groupId!)/tournaments/\(tournamentId!)/matches").observe(.childRemoved) { (matchSnapshot: DataSnapshot) in
            if matchSnapshot.childrenCount > 0 {
                self.matches.removeAll(where: {
                    return $0.key == matchSnapshot.key
                })
                self.tableView.reloadData()
            }
        }
        ref.child("groups/\(groupId!)/tournaments/\(tournamentId!)/matches").observe(.childChanged) { (matchSnapshot: DataSnapshot) in
            if matchSnapshot.childrenCount > 0 {
                let matchedSnapshot = self.matches.first(where: {
                    return $0.key == matchSnapshot.key
                })
                if let matchedItem = matchedSnapshot {
                    if let index = self.matches.firstIndex(of: matchedItem) {
                        self.matches[index] = matchSnapshot
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recordScore" {
            let nav = segue.destination as! UINavigationController
            let recordMatchScoreVC = nav.topViewController as! RecordMatchScoreViewController
            recordMatchScoreVC.tournamentId = tournamentId
            recordMatchScoreVC.matchSnapshot = selectedMatchSnapshot
        }
    }
    
    // Checks and returns boolean to indicate whether all matches of this tournament are scored or not.
    func isAllMatchesScored() -> Bool {
        let scoredMatches = matches.filter({
            let match = $0.value as! Dictionary<String, Any>
            let teams = match[DatabaseFields.TournamentFields.teams] as! Dictionary<String, Any>
            let teamKeys = teams.keys.map {
                $0
            }
            let teamOneDict = teams[teamKeys[0]] as! Dictionary<String, Any>
            let teamTwoDict = teams[teamKeys[1]] as! Dictionary<String, Any>
            let teamAScore = teamOneDict[DatabaseFields.MatchFields.score] as? Int ?? 0
            let teamBScore = teamTwoDict[DatabaseFields.MatchFields.score] as? Int ?? 0
            return teamAScore > 0 || teamBScore > 0
        })
        return scoredMatches.count == matches.count
    }
    
}

extension TournamentMatchesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matches.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.selectionStyle != UITableViewCell.SelectionStyle.none {
            selectedMatchSnapshot = self.matches[indexPath.row]
            performSegue(withIdentifier: "recordScore", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TournamentMatchViewCell") as! TournamentMatchViewCell
        
        let matchSnapshot: DataSnapshot! = matches[indexPath.row]
        let match = matchSnapshot.value as! Dictionary<String, Any>
        
        let teams = match[DatabaseFields.TournamentFields.teams] as! Dictionary<String, Any>
        let teamKeys = teams.keys.map {
            $0
        }
        
        // Let's set the team/player names.
        
        // Let's first check if its a singles / doubles team. This is important as if the team is of singles we just need to show the player name (and the information of each player need to be set). However if its doubles, we just have to display the team name (and don't have to look for player name in another data structure.
        let teamOneDict = teams[teamKeys[0]] as! Dictionary<String, Any>
        let teamTwoDict = teams[teamKeys[1]] as! Dictionary<String, Any>
        
        let teamAScore = teamOneDict[DatabaseFields.MatchFields.score] as? Int
        let teamBScore = teamTwoDict[DatabaseFields.MatchFields.score] as? Int
        
        if let teamName = teamOneDict[DatabaseFields.CommonFields.name] as? String {
            // Means its doubles game. So let's just use the teamName.
            cell.teamOne.text = "\(teamName) \((teamAScore ?? 0 > teamBScore ?? 0) ? "🏆" : "")"
            // Also we know the teamTwo will be of doubles as well so let's not check anything and saftely set the teamname.
            cell.teamTwo.text = "\(teamTwoDict[DatabaseFields.CommonFields.name] as! String) \((teamBScore ?? 0 > teamAScore ?? 0) ? "🏆" : "")"
        } else {
            // Ok so this is a case when its actually singles match so we need to get the player teams from /members.
            // Let's first get the teamOne data and then we will get teamTwo data.
            // Let's get the players.
            let teamOnePlayers = teamOneDict[DatabaseFields.TournamentFields.players] as! Dictionary<String, Any>
            let teamOnePlayerKeys = teamOnePlayers.keys.map {
                $0
            }
            // We can saftely assume that as its singles matches the player will be only one within a team.
            let teamOnePlayerId = (teamOnePlayers[teamOnePlayerKeys[0]] as! Dictionary<String, Any>)[DatabaseFields.CommonFields.id]
            cell.teamOne.text = "\(membersNameData[teamOnePlayerId as! String] ?? "") \((teamAScore ?? 0 > teamBScore ?? 0) ? "🏆" : "")"
            
            let teamTwoPlayers = teamTwoDict[DatabaseFields.TournamentFields.players] as! Dictionary<String, Any>
            let teamTwoPlayerKeys = teamTwoPlayers.keys.map {
                $0
            }
            let teamTwoPlayerId = (teamTwoPlayers[teamTwoPlayerKeys[0]] as! Dictionary<String, Any>)[DatabaseFields.CommonFields.id]
            cell.teamTwo.text = "\(membersNameData[teamTwoPlayerId as! String] ?? "") \((teamBScore ?? 0 > teamAScore ?? 0) ? "🏆" : "")"
        }
        
        // Let's set score.
        
        if let teamScore = teamAScore {
            cell.teamOneScore.text = "\(teamScore)"
        } else {
            cell.teamOneScore.text = ""
        }
        
        if let teamScore = teamBScore {
            cell.teamTwoScore.text = "\(teamScore)"
        } else {
            cell.teamTwoScore.text = ""
        }
        
        // Also if score is already recorded lets disable the row selection.
        if (teamAScore ?? 0) > 0 || (teamBScore ?? 0) > 0 {
            cell.selectionStyle = .none
        } else {
            cell.selectionStyle = .default
        }
        
        // Let's udpate tournament status if its not yet udpated. We need to make the tournament completed if all the matches are scored now.
        if !tournamentStatusUpdated && isAllMatchesScored() {
            tournamentStatusUpdated = true
            let tournamentRef = ref.child("groups/\(groupId!)/tournaments/\(tournamentId!)")
            tournamentRef.observeSingleEvent(of: .value, with: { (snapshot) in
                var tournamentDict = snapshot.value as! Dictionary<String, Any>
                tournamentDict[DatabaseFields.TournamentFields.status] = "Completed"
                tournamentRef.setValue(tournamentDict)
            })
        }
        return cell
    }
    
}
