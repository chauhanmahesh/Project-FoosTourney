//
//  TournamentDetailViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 20/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import UIKit
import Foundation

class TournamentDetailViewController: UIViewController {
    
    @IBOutlet var containerA: UIView!
    @IBOutlet var containerB: UIView!
    
    var groupId: String!
    var tournamentId: String!
    
    @IBAction func showComponent(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.containerA.alpha = 1
                self.containerB.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.containerA.alpha = 0
                self.containerB.alpha = 1
            })
        }
    }
    
    override func viewDidLoad() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tournamentMatches" {
            let tournamentMatchesVC = segue.destination as! TournamentMatchesViewController
            tournamentMatchesVC.groupId = groupId
            tournamentMatchesVC.tournamentId = tournamentId
        } else if segue.identifier == "tournamentStandings" {
            let tournamentStandingsVC = segue.destination as! TournamentStandingsViewController
            tournamentStandingsVC.groupId = groupId
            tournamentStandingsVC.tournamentId = tournamentId
        }
    }

}
