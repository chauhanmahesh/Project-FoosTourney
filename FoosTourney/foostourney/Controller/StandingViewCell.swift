//
//  StandingViewCell.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 20/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import UIKit

// UITableViewCell to hold the content of a single standing cell.
class StandingViewCell: UITableViewCell {
    
    @IBOutlet weak var teamOrPlayerName: UILabel!
    
    @IBOutlet weak var played: UILabel!
    
    @IBOutlet weak var won: UILabel!
    
    @IBOutlet weak var points: UILabel!
    
}
