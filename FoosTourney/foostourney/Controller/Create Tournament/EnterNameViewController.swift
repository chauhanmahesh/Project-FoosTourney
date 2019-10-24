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

// ViewController which is responsible to display the views required to enter the tournament name.
class EnterNameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var tournamentNameTextField: UITextField!
    @IBOutlet var tournamentTypeSwitch: UISwitch!
    @IBOutlet var primaryAction: UIButton!
    
    // Holds the information about the tournament which is being created. We will pass this in the next steps.
    var createTournament: CreateTournament!
    
    @IBAction func cancelTapped() {
        // Let's dismiss.
        dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        // disable or enable the primaryAction when the name is being typed.
        primaryAction.isEnabled = !(updatedString?.isEmpty ?? true)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // keyboard will hide when user presses return on keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        // Field is disabled to start with.
        primaryAction.isEnabled = false
        tournamentNameTextField.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectPlayers" {
            // Let's pass the 'createTournament' struct to next step with the entered tournament name.
            let selectPlayersVC = segue.destination as! SelectPlayersViewController
            
            createTournament.tournamentName = tournamentNameTextField.text ?? "Untitled"
            createTournament.tournamentType = tournamentTypeSwitch.isOn ? .doubles : .singles
            selectPlayersVC.createTournament = createTournament
        }
    }

}

