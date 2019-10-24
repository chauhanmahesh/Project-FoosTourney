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

// ViewController which is responsible to display the list of searched groups and also the search bar which will be used to search the groups which user is still not part of.
class GroupsViewController: UIViewController {
    
    var ref: DatabaseReference!
    // Holds all the group snapshots which is being searched.
    var groups: [DataSnapshot]! = []
    
    @IBOutlet var groupsCollectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    @IBAction func cancelTapped() {
        // Let's dismiss.
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        ref = Database.database().reference()
    }
    
}

extension GroupsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateResultsForSearchText(text: searchText)
    }
    
    func updateResultsForSearchText(text: String) {
        self.groups = []
        ref.child("groups").observe(.childAdded) { (snapshot: DataSnapshot) in
            let group = snapshot.value as! Dictionary<String, Any>
            if let groupName = group[DatabaseFields.CommonFields.name] {
                // Let's see if group name matches with searchtext.
                if (groupName as! String).lowercased().contains(text.lowercased()) {
                    let query = snapshot.childSnapshot(forPath: "/members").ref.queryOrdered(byChild: "authenticatedId").queryEqual(toValue: Auth.auth().currentUser?.uid)
                    query.observe(.value, with: { (memberSnapshot) in
                        if memberSnapshot.childrenCount > 0 {
                            // Use is already part of this group. No need to show that.
                        } else {
                            // Let's show this as user is not part of this group yet.
                            self.groups.append(snapshot)
                            self.groupsCollectionView.reloadData()
                        }
                    })
                } else {
                    self.groupsCollectionView.reloadData()
                }
            }
        }
    }
    
}

extension GroupsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (groups.count == 0) {
            if searchBar.text?.isEmpty ?? true {
                self.groupsCollectionView.setEmptyMessage("Enter search term to start searching groups.")
            } else {
                self.groupsCollectionView.setEmptyMessage("😳 Coudn't find any groups matching your search criteria.")
            }
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
        cell.groupIdToJoin = groupSnapshot.key
        cell.delegate = self
        return cell
    }
    
}

extension GroupsViewController: UICollectionViewDelegateFlowLayout {
    
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

extension GroupsViewController: GroupJoinedDelegateProtocol {

    // Delegate method which will be called when user will join a group.
    func onGroupJoined() {
        updateResultsForSearchText(text: searchBar.text ?? "")
    }

}
