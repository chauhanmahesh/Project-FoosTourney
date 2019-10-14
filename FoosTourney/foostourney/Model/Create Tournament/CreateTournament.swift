//
//  CreateTournament.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 14/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation

class CreateTournament {
    
    var groupId: String?
    
    var tournamentName: String?
    var tournamentType: TournamentType = .doubles
    // Holds the player id's
    var players: [String] = []
    
    public init() {}
    
}
