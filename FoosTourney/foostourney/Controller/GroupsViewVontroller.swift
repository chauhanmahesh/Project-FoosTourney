//
//  GroupsViewVontroller.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 10/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class GroupsViewController: UIViewController {
    
    var ref: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle!
    
    var groups: [DataSnapshot]! = []
    
    @IBOutlet var groupsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        configureDatabase()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        // Let's listen for new groups from the firebase database
        _refHandle = ref.child("groups").observe(.childAdded) { (snapshot: DataSnapshot) in
            let query = snapshot.childSnapshot(forPath: "/members").ref.queryOrdered(byChild: "id").queryEqual(toValue: Auth.auth().currentUser?.uid)
            query.observe(.value, with: { (memberSnapshot) in
                if memberSnapshot.childrenCount > 0 {
                    self.groups.append(snapshot)
                    self.groupsCollectionView.reloadData()
                }
            })
        }
    }
    
    deinit {
        ref.child("groups").removeObserver(withHandle: _refHandle)
    }
    
}

extension GroupsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (groups.count == 0) {
            self.groupsCollectionView.setEmptyMessage("Too bad 😞, you are not part of any group yet. Search or create your own new group and add friends.")
        } else {
            self.groupsCollectionView.restore()
        }
        return groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupViewCell", for: indexPath) as! GroupViewCell
        
        let groupSnapshot: DataSnapshot! = groups[indexPath.row]
        let group = groupSnapshot.value as! Dictionary<String, Any>
        
        let groupName = group[DatabaseFields.CommonFields.name] ?? "Untitled"
        cell.groupBackground.backgroundColor = .random
        cell.groupName.text = groupName as! String
        return cell
    }
    
}

extension GroupsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = (collectionView.bounds.width - 10) / 3.0
        let yourHeight = yourWidth
        print("Cell \(yourWidth)-\(yourHeight)")
        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
}
