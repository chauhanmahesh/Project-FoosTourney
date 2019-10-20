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

class EnterNameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tournamentNameTextField: UITextField!
    @IBOutlet var tournamentTypeSwitch: UISwitch!
    @IBOutlet var primaryAction: UIButton!
    
    var createTournament: CreateTournament!
    
    @IBAction func cancelTapped() {
        // Let's dismiss.
        dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        primaryAction.isEnabled = !(updatedString?.isEmpty ?? true)
        return true
    }
    
    override func viewDidLoad() {
        // Field is disabled to start with.
        primaryAction.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectPlayers" {
            let selectPlayersVC = segue.destination as! SelectPlayersViewController
            
            createTournament.tournamentName = tournamentNameTextField.text ?? "Untitled"
            createTournament.tournamentType = tournamentTypeSwitch.isOn ? .doubles : .singles
            selectPlayersVC.createTournament = createTournament
        }
    }

}

