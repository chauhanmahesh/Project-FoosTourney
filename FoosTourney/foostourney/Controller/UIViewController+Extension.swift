//
//  ViewController+Extension.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 23/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import Firebase

extension UIViewController {
    
    // This API which is being used by many ViewController fetches the membernames from "/members" and pass it back as a dictionary with their snapshot id.
    // This is very useful as this can be done upfront in any viewController which needs to fetch member names and need to display in the listview.
    func fetchMembersData(ref: DatabaseReference, completion: @escaping ([String : String]) -> ()) {
        var memberNames: [String: String] = [:]
        ref.child("members").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshotDict = snapshot.value as? Dictionary<String, Any> {
                let count = snapshotDict.keys.count
                for key in snapshotDict.keys {
                    let memberDict = snapshotDict[key] as! Dictionary<String, Any>
                    memberNames[key] = memberDict[DatabaseFields.CommonFields.name] as! String
                    if (memberNames.count == count) {
                        // Means we fetched all member details. Let's call the completion handler so that we can load the data now.
                        completion(memberNames)
                    }
                }
            }
        })
    }
    
}
