//
//  Player.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 19/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation

struct Player : Equatable {
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.playerId == rhs.playerId
    }
    
    var playerId: String
}
