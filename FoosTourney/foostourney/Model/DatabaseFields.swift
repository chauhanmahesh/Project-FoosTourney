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
    }
    
    struct TournamentFields {
        static let status = "status"
        static let teams = "teams"
        static let players = "players"
    }
}
