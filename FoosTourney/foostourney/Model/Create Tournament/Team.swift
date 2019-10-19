//
//  Team.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 19/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation

struct Team : Equatable {
    
    static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs.players == rhs.players && lhs.teamName == rhs.teamName
    }
    
    var teamName: String?
    
    var players: [Player]
    
}
