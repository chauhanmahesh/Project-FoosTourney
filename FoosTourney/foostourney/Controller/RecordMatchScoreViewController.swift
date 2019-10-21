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

class RecordMatchScoreViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    let recordScorePickerData = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    var tournamentId: String!
    var matchSnapshot: DataSnapshot!
    var teamASnapshotId: String!
    var teamBSnapshotId: String!
    var ref: DatabaseReference!
    
    @IBOutlet weak var teamAName: UILabel!
    @IBOutlet weak var teamBName: UILabel!
    
    @IBOutlet weak var teamAScorePicker: UIPickerView!
    @IBOutlet weak var teamBScorePicker: UIPickerView!
    
    @IBAction func cancelTapped() {
        // Let's dismiss.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped() {
        // Let's save score.
        // let's save the score for team A first.
        let matchTeamARef = matchSnapshot.ref.child("teams/\(teamASnapshotId!)")
        matchTeamARef.observeSingleEvent(of: .value, with: { (snapshot) in
            var teamDict = snapshot.value as! Dictionary<String, Any>
            teamDict[DatabaseFields.MatchFields.score] = self.recordScorePickerData[self.teamAScorePicker.selectedRow(inComponent: 0)]
            matchTeamARef.setValue(teamDict)
        })
        
        // let's save the score for team B first.
        let matchTeamBRef = matchSnapshot.ref.child("teams/\(teamBSnapshotId!)")
        matchTeamBRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var teamDict = snapshot.value as! Dictionary<String, Any>
            teamDict[DatabaseFields.MatchFields.score] = self.recordScorePickerData[self.teamBScorePicker.selectedRow(inComponent: 0)]
            matchTeamBRef.setValue(teamDict)
        })
        // Let's dismiss.
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        configureDatabase()
        // Update team names.
        udpateTeamNames()
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
        } else {
            var teamOneName = ""
            // Let's get the players.
            let players = teamOne[DatabaseFields.TournamentFields.players] as! Dictionary<String, Any>
            let playerKeys = players.keys.map {
                $0
            }
            for playerKey in playerKeys {
                let playerId = (players[playerKey] as! Dictionary<String, Any>)[DatabaseFields.CommonFields.id]
                ref.child("members/\(playerId!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let value = snapshot.value as? NSDictionary
                        let memberName = value?[DatabaseFields.CommonFields.name] as? String ?? ""
                        if teamOneName.isEmpty {
                            teamOneName.append(memberName)
                            if playerKeys.count == 1 {
                                // Singles tournament.
                                self.teamAName.text = teamOneName
                            } else {
                                teamOneName.append("/")
                            }
                        } else {
                            teamOneName.append(memberName)
                            self.teamAName.text = teamOneName
                        }
                    }
                })
            }
        }
        
        if let teamName = teamTwo[DatabaseFields.CommonFields.name] as? String {
            teamBName.text = teamName
        } else {
            var teamTwoName = ""
            // Let's get the players.
            let players = teamTwo[DatabaseFields.TournamentFields.players] as! Dictionary<String, Any>
            let playerKeys = players.keys.map {
                $0
            }
            for playerKey in playerKeys {
                let playerId = (players[playerKey] as! Dictionary<String, Any>)[DatabaseFields.CommonFields.id]
                ref.child("members/\(playerId!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        let value = snapshot.value as? NSDictionary
                        let memberName = value?[DatabaseFields.CommonFields.name] as? String ?? ""
                        if teamTwoName.isEmpty {
                            teamTwoName.append(memberName)
                            if playerKeys.count == 1 {
                                // Singles tournament.
                                self.teamBName.text = teamTwoName
                            } else {
                                teamTwoName.append("/")
                            }
                        } else {
                            teamTwoName.append(memberName)
                            self.teamBName.text = teamTwoName
                        }
                    }
                })
            }
        }
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
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
