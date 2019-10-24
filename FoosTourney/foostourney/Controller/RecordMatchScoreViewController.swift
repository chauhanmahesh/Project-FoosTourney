//
//  RecordMatchScoreViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 21/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseAuth

// ViewController which is responsible to let user record the score for a particular match.
class RecordMatchScoreViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let recordScorePickerData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    // Holds the tournamentId where this match belongs to.
    var tournamentId: String!
    // Holds the match snapshot for which the score is being recorded.
    var matchSnapshot: DataSnapshot!
    // Holds the teamA snapshotId
    var teamASnapshotId: String!
    // Holds the teamB snapshotId
    var teamBSnapshotId: String!
    var ref: DatabaseReference!
    
    @IBOutlet weak var teamAName: UILabel!
    @IBOutlet weak var teamBName: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var teamAScorePicker: UIPickerView!
    @IBOutlet weak var teamBScorePicker: UIPickerView!
    // Dictionary to hold the name of all players against their snapshot id.
    var membersNameData: [String: String] = [:]
    
    @IBAction func cancelTapped() {
        // Let's dismiss.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped() {
        // Let's save score.
        // let's save the score for team A first.
        let teamAScore = self.recordScorePickerData[self.teamAScorePicker.selectedRow(inComponent: 0)]
        let teamBScore = self.recordScorePickerData[self.teamBScorePicker.selectedRow(inComponent: 0)]
        // let's record match scores.
        recordMatchScore(teamAScore, teamBScore)
        
        if let userGroupDict = UserDefaults.standard.dictionary(forKey: UserDefaultsKey.userGroupDict) {
            if let currentUserGroupSelected = userGroupDict[Auth.auth().currentUser?.uid ?? ""] as? String {
                // Let's update the team individual stats.
                recordTeamStats(currentUserGroupSelected, teamAScore, teamBScore)
                // Let's update played individual record.
                recordPlayerStats(currentUserGroupSelected, teamAScore, teamBScore)
                // Let's dismiss.
                dismiss(animated: true, completion: nil)
            }
        } else {
            // Let's dismiss.
            dismiss(animated: true, completion: nil)
        }
    }
    
    // Record the match score.
    func recordMatchScore(_ teamAScore: Int, _ teamBScore: Int) {
        let matchTeamARef = matchSnapshot.ref.child("teams/\(teamASnapshotId!)")
        matchTeamARef.observeSingleEvent(of: .value, with: { (snapshot) in
            var teamDict = snapshot.value as! Dictionary<String, Any>
            teamDict[DatabaseFields.MatchFields.score] = teamAScore
            matchTeamARef.setValue(teamDict)
        })
        
        // let's save the score for team B first.
        let matchTeamBRef = matchSnapshot.ref.child("teams/\(teamBSnapshotId!)")
        matchTeamBRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var teamDict = snapshot.value as! Dictionary<String, Any>
            teamDict[DatabaseFields.MatchFields.score] = teamBScore
            matchTeamBRef.setValue(teamDict)
        })
    }
    
    // This record the team stats under /teams
    func recordTeamStats(_ groupId: String, _ teamAScore: Int, _ teamBScore: Int) {
        let didTeamAWon = teamAScore > teamBScore
        // Also let's update the team standings.
        let teamARef = ref.child("groups/\(groupId)/tournaments/\(tournamentId!)/teams/\(teamASnapshotId!)")
        teamARef.observeSingleEvent(of: .value, with: { (snapshot) in
            var teamDict = snapshot.value as! Dictionary<String, Any>
            // let's get the current matches played data.
            
            teamDict[DatabaseFields.TeamFields.matchesPlayed] = ((teamDict[DatabaseFields.TeamFields.matchesPlayed] as? Int) ?? 0) + 1
            teamDict[DatabaseFields.TeamFields.matchesWon] = ((teamDict[DatabaseFields.TeamFields.matchesWon] as? Int) ?? 0) + (didTeamAWon ? 1 : 0)
            teamDict[DatabaseFields.TeamFields.points] = ((teamDict[DatabaseFields.TeamFields.points] as? Int) ?? 0) + (didTeamAWon ? (2 + teamAScore - teamBScore) : 0)
            teamARef.setValue(teamDict)
        })
        
        let teamBRef = ref.child("groups/\(groupId)/tournaments/\(tournamentId!)/teams/\(teamBSnapshotId!)")
        teamBRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var teamDict = snapshot.value as! Dictionary<String, Any>
            // let's get the current matches played data.
            
            teamDict[DatabaseFields.TeamFields.matchesPlayed] = ((teamDict[DatabaseFields.TeamFields.matchesPlayed] as? Int) ?? 0) + 1
            teamDict[DatabaseFields.TeamFields.matchesWon] = ((teamDict[DatabaseFields.TeamFields.matchesWon] as? Int) ?? 0) + (!didTeamAWon ? 1 : 0)
            teamDict[DatabaseFields.TeamFields.points] = ((teamDict[DatabaseFields.TeamFields.points] as? Int) ?? 0) + (!didTeamAWon ? (2 + teamBScore - teamAScore) : 0)
            teamBRef.setValue(teamDict)
        })
    }
    
    // Record Player Stats under /players
    func recordPlayerStats(_ groupId: String, _ teamAScore: Int, _ teamBScore: Int) {
        let didTeamAWon = teamAScore > teamBScore
        
        let matchTeamARef = matchSnapshot.ref.child("teams/\(teamASnapshotId!)").observeSingleEvent(of: .value, with: { (snapshot) in
            var teamDict = snapshot.value as! Dictionary<String, Any>
            if let players = teamDict[DatabaseFields.TournamentFields.players] as? Dictionary<String, Any> {
                for player in players.keys {
                    let playerId = (players[player] as! Dictionary<String, String>)[DatabaseFields.CommonFields.id]
                    self.updatePlayerStats(ofPlayerId: playerId!, didWon: didTeamAWon)
                }
            }
        })
        
        let matchTeamBRef = matchSnapshot.ref.child("teams/\(teamBSnapshotId!)").observeSingleEvent(of: .value, with: { (snapshot) in
            var teamDict = snapshot.value as! Dictionary<String, Any>
            if let players = teamDict[DatabaseFields.TournamentFields.players] as? Dictionary<String, Any> {
                for player in players.keys {
                    let playerId = (players[player] as! Dictionary<String, String>)[DatabaseFields.CommonFields.id]
                    self.updatePlayerStats(ofPlayerId: playerId!, didWon: !didTeamAWon)
                }
            }
        })
        
    }
    
    // Updates the playerStats for the passed playerId.
    func updatePlayerStats(ofPlayerId: String, didWon: Bool) {
        let memberRef = ref.child("members/\(ofPlayerId)")
        memberRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var memberDict = snapshot.value as! Dictionary<String, Any>
            
            let matchesPlayed = ((memberDict[DatabaseFields.MemberFields.totalMatchesPlayed] as? Int) ?? 0) + 1
            let matchesWon = ((memberDict[DatabaseFields.MemberFields.totalMatchesWon] as? Int) ?? 0) + (didWon ? 1 : 0)
            memberDict[DatabaseFields.MemberFields.totalMatchesPlayed] =  matchesPlayed
            memberDict[DatabaseFields.MemberFields.totalMatchesWon] =  matchesWon
            memberDict[DatabaseFields.MemberFields.totalWinPerct] = Int(round(( Float(matchesWon) / Float(matchesPlayed) ) * 100))
            memberRef.setValue(memberDict)
        })
    }
    
    override func viewDidLoad() {
        activityIndicator.startAnimating()
        ref = Database.database().reference()
        // Let's fetch member details (such as name) before populating any data. Because we don't want to fetch memberName asynchrously for each row. This could
        // mess up the tableview data.
        fetchMembersData(ref: ref, completion: { membersData in
            self.membersNameData = membersData
            self.activityIndicator.stopAnimating()
            // Update team names.
            self.udpateTeamNames()
        })
    }
    
    func udpateTeamNames() {
        let match = matchSnapshot.value as! Dictionary<String, Any>
        
        let teams = match[DatabaseFields.TournamentFields.teams] as! Dictionary<String, Any>
        let teamKeys = teams.keys.map {
            $0
        }
        let teamOne = teams[teamKeys[0]] as! Dictionary<String, Any>
        teamASnapshotId = teamKeys[0]
        let teamTwo = teams[teamKeys[1]] as! Dictionary<String, Any>
        teamBSnapshotId = teamKeys[1]
        
        if let teamName = teamOne[DatabaseFields.CommonFields.name] as? String {
            teamAName.text = teamName
            // We can saftely set second team name without checking for null.
            teamBName.text = teamTwo[DatabaseFields.CommonFields.name] as! String
        } else {
            let teamOnePlayers = teamOne[DatabaseFields.TournamentFields.players] as! Dictionary<String, Any>
            let teamOnePlayerKeys = teamOnePlayers.keys.map {
                $0
            }
            // We can saftely assume that as its singles matches the player will be only one within a team.
            let teamOnePlayerId = (teamOnePlayers[teamOnePlayerKeys[0]] as! Dictionary<String, Any>)[DatabaseFields.CommonFields.id]
            self.teamAName.text = membersNameData[teamOnePlayerId as! String] ?? ""
            
            let teamTwoPlayers = teamTwo[DatabaseFields.TournamentFields.players] as! Dictionary<String, Any>
            let teamTwoPlayerKeys = teamTwoPlayers.keys.map {
                $0
            }
            let teamTwoPlayerId = (teamTwoPlayers[teamTwoPlayerKeys[0]] as! Dictionary<String, Any>)[DatabaseFields.CommonFields.id]
            self.teamBName.text = membersNameData[teamTwoPlayerId as! String] ?? ""
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recordScorePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(recordScorePickerData[row] ?? 0)"
    }
    
}
