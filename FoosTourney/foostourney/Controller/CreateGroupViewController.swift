//
//  CreateGroupViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 11/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CreateGroupViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    @IBOutlet var groupNameTextField: UITextField!
    
    @IBAction func createButtonTapped() {
        let group = [DatabaseFields.CommonFields.name: groupNameTextField.text ?? "Untitled"]
        let newGroupReference = ref.child("groups").childByAutoId()
        newGroupReference.setValue(group)
        let member = [DatabaseFields.CommonFields.id: Auth.auth().currentUser?.uid ?? "MemberId"]
        newGroupReference.child("members").childByAutoId().setValue(member)
        // Let's dismiss.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped() {
        // Let's dismiss.
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        configureDatabase()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
}
