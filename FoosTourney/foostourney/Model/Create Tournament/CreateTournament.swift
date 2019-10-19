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
    
    // Holds the teams.
    // If tournament type is Doubles then teams will hold something like [[Player1, Player2], [Player3, Player4]]
    // If tournament type is Singles then teams will hold something like [[Player1], [Player2], [Player3], [Player4]]
    var teams: [Team] = []
    
    var matches: [Match] = []
    
    public init() {}
    
}
