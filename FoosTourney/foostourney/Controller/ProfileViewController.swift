//
//  ProfileViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 21/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var totalMatches: UILabel!
    @IBOutlet weak var totalMatchesWon: UILabel!
    @IBOutlet weak var winPerct: UILabel!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        configureDatabase()
        downloadProfileImaheAsync()
        userName.text = Auth.auth().currentUser?.displayName ?? "No Name"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Let's set stats.
        updateStats()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
    func downloadProfileImaheAsync() {
        DispatchQueue.global(qos: .userInitiated).async { () -> Void in
            if let url = Auth.auth().currentUser?.photoURL, let imgData = try? Data(contentsOf: url), let img = UIImage(data: imgData) {
                DispatchQueue.main.async() {
                    self.profileImage.layer.borderWidth = 1
                    self.profileImage.layer.masksToBounds = false
                    self.profileImage.layer.borderColor = UIColor.black.cgColor
                    self.profileImage.layer.cornerRadius = 100 / 2
                    self.profileImage.clipsToBounds = true
                    self.profileImage.image = img
                }
            }
        }
    }
    
    func updateStats() {
        if let authenticatedUserid = Auth.auth().currentUser?.uid {
            ref.child("members").queryOrdered(byChild: "id").queryEqual(toValue: authenticatedUserid).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    // Let's get value.
                    let memberRefDict = snapshot.value as! Dictionary<String, Any>
                    let memberDict = memberRefDict[memberRefDict.keys.first!] as! Dictionary<String, Any>
                    self.totalMatches.text = "\(memberDict[DatabaseFields.MemberFields.totalMatchesPlayed] as? Int ?? 0)"
                    self.totalMatchesWon.text = "\(memberDict[DatabaseFields.MemberFields.totalMatchesWon] as? Int ?? 0)"
                    self.winPerct.text = "\(memberDict[DatabaseFields.MemberFields.totalWinPerct] as? Int ?? 0)"
                }
            })
        }
    }
    
}
