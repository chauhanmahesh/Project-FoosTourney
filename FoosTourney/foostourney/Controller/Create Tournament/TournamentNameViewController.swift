//
//  TournamentNameViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 14/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class TournamentNameViewController: UIViewController {
    
    @IBOutlet var tournamentNameTextField: UITextField!
    @IBOutlet var tournamentTypeSwitch: UISwitch!
    
    var createTournament: CreateTournament!
    
    @IBAction func cancelTapped() {
        // Let's dismiss.
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectPlayers" {
            let selectPlayersVC = segue.destination as! SelectTournamentPlayersViewController
            
            createTournament.tournamentName = tournamentNameTextField.text ?? "Untitled"
            createTournament.tournamentType = tournamentTypeSwitch.isOn ? .doubles : .singles
            selectPlayersVC.createTournament = createTournament
        }
    }

}

