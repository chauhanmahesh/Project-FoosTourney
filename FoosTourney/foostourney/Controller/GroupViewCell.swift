//
//  GroupViewCell.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 10/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import UIKit
import Firebase

// DelegateProtocol which will be called whenever a group will be joined.
protocol GroupJoinedDelegateProtocol {
    func onGroupJoined()
}

// UICollectionViewCell to hold the content of a single group cell.
class GroupViewCell: UICollectionViewCell {
    
    @IBOutlet weak var groupBackground: UIImageView!
    
    @IBOutlet weak var groupName: UILabel!
    
    var groupIdToJoin: String?
    
    var delegate: GroupJoinedDelegateProtocol? = nil
    
    @IBAction func joinGroup() {
        if let userAuthenticatedId = Auth.auth().currentUser?.uid {
            if let groupId = groupIdToJoin {
                let databaseRef = Database.database().reference()
                
                databaseRef.child("members").queryOrdered(byChild: "id").queryEqual(toValue: userAuthenticatedId).observeSingleEvent(of: .value, with: { (snapshot) in
                    let memberDict = snapshot.value as! Dictionary<String, Any>
                    var member = [DatabaseFields.MemberFields.authenticatedId: userAuthenticatedId]
                    member[DatabaseFields.CommonFields.id] = memberDict.keys.first!
                    databaseRef.child("groups/\(groupId)/members").childByAutoId().setValue(member)
                    self.delegate?.onGroupJoined()
                })
            }
        }
    }
    
}

