//
//  Constants.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 10/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation

struct DatabaseFields {

    struct CommonFields {
        static let id = "id"
        static let name = "name"
    }
    
    struct MemberFields {
        static let email = "email"
        static let authenticatedId = "authenticatedId"
        static let totalMatchesPlayed = "totalMatchesPlayed"
        static let totalMatchesWon = "totalMatchesWon"
        static let totalWinPerct = "totalWinPerct"
    }
    
    struct TournamentFields {
        static let status = "status"
        static let teams = "teams"
        static let players = "players"
    }
    
    struct MatchFields {
        static let score = "score"
    }
    
    struct TeamFields {
        static let matchesPlayed = "matchesPlayed"
        static let matchesWon = "matchesWon"
        static let points = "points"
    }
}
