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
    @IBOutlet var userName: UILabel!
    
    override func viewDidLoad() {
        downloadProfileImaheAsync()
        userName.text = Auth.auth().currentUser?.displayName ?? "No Name"
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
    
}
