//
//  TournamentDetailViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 20/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import UIKit
import Foundation

// ViewController which is responsible to display the details of a single tournament. This controller holds a segmented control which user can use to choose from two different views. "Matches" or "Standings" for the tournament.
class TournamentDetailViewController: UIViewController {
    
    @IBOutlet var containerA: UIView!
    @IBOutlet var containerB: UIView!
    
    // Holds the groupId from which this tournament belongs.
    var groupId: String!
    // Holds the tournamentId for which we are displaying the details.
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
