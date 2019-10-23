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

class CreateGroupViewController: UIViewController, UITextFieldDelegate{
    
    var ref: DatabaseReference!
    
    @IBOutlet var groupNameTextField: UITextField!
    
    @IBAction func createButtonTapped() {
        let group = [DatabaseFields.CommonFields.name: groupNameTextField.text ?? "Untitled"]
        let newGroupReference = ref.child("groups").childByAutoId()
        newGroupReference.setValue(group)
        if let userAuthenticatedId = Auth.auth().currentUser?.uid {
            var member = [DatabaseFields.MemberFields.authenticatedId: userAuthenticatedId]
            // Let's find the member id from /members.
            ref.child("members").queryOrdered(byChild: "id").queryEqual(toValue: userAuthenticatedId).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let memberDict = snapshot.value as! Dictionary<String, Any>
                    if let memberKey = memberDict.keys.first {
                        member[DatabaseFields.CommonFields.id] = memberKey
                        newGroupReference.child("members").childByAutoId().setValue(member)
                        // Let's dismiss.
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func cancelTapped() {
        // Let's dismiss.
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        configureDatabase()
        groupNameTextField.delegate = self
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
}
