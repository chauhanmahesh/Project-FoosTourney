//
//  MatchViewCell.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 15/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import UIKit

class MatchViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
    }
    
}
