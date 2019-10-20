//
//  ChooseGroupViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 12/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

protocol GroupSelectionDelegateProtocol {
    func onGroupSelected()
}

class ChooseGroupViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    var groups: [DataSnapshot]! = []
    
    var delegate: GroupSelectionDelegateProtocol? = nil
    
    @IBOutlet var groupsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        configureDatabase()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        // Let's listen for new groups from the firebase database
        observeChanges()
    }
    
    func observeChanges() {
        ref.child("groups").observe(.childAdded) { (snapshot: DataSnapshot) in
            let query = snapshot.childSnapshot(forPath: "/members").ref.queryOrdered(byChild: "authenticatedId").queryEqual(toValue: Auth.auth().currentUser?.uid)
            query.observe(.value, with: { (memberSnapshot) in
                if memberSnapshot.childrenCount > 0 {
                    self.groups.append(snapshot)
                    self.groupsCollectionView.reloadData()
                }
            })
        }
        
        ref.child("groups").observe(.childRemoved) { (snapshot: DataSnapshot) in
            let query = snapshot.childSnapshot(forPath: "/members").ref.queryOrdered(byChild: "authenticatedId").queryEqual(toValue: Auth.auth().currentUser?.uid)
            query.observe(.value, with: { (memberSnapshot) in
                if memberSnapshot.childrenCount > 0 {
                    self.groups.removeAll(where: {
                        return $0.key == memberSnapshot.key
                    })
                    self.groupsCollectionView.reloadData()
                }
            })
        }
        
        ref.child("groups").observe(.childChanged) { (snapshot: DataSnapshot) in
            let query = snapshot.childSnapshot(forPath: "/members").ref.queryOrdered(byChild: "authenticatedId").queryEqual(toValue: Auth.auth().currentUser?.uid)
            query.observe(.value, with: { (memberSnapshot) in
                if memberSnapshot.childrenCount > 0 {
                    let matchedSnapshot = self.groups.first(where: {
                        return $0.key == memberSnapshot.key
                    })
                    if let matchedItem = matchedSnapshot {
                        if let index = self.groups.firstIndex(of: matchedItem) {
                            self.groups[index] = memberSnapshot
                            self.groupsCollectionView.reloadData()
                        }
                    }
                }
            })
        }
    }
    
}

extension ChooseGroupViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (groups.count == 0) {
            self.groupsCollectionView.setEmptyMessage("Ohhhhh nooo 😞. Looks like you haven't joined any group yet. You can always create a new group or search for the existing ones.")
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Let's save the selected group for this user.
        let selectedGroup = groups[indexPath.row]
        var userGroupDict: Dictionary<String, String> = [:]
        userGroupDict[Auth.auth().currentUser?.uid ?? ""] = selectedGroup.key
        UserDefaults.standard.set(userGroupDict, forKey: UserDefaultsKey.userGroupDict)
        
        // Let's call the delegate method.
        if let delegate = self.delegate {
            print("Calling delegate API")
            delegate.onGroupSelected()
        }
        dismiss(animated: true, completion: nil)
    }
    
}

extension ChooseGroupViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = (collectionView.bounds.width - 10) / 3.0
        let yourHeight = yourWidth
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
