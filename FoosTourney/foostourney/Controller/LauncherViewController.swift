//
//  LauncherViewController.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 20/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseAuth

class LauncherViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        configureDatabase()
        configureAuth()
    }
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
    func configureAuth() {
        let provider: [FUIAuthProvider] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = provider
        
        _authHandle = Auth.auth().addStateDidChangeListener{ (auth: Auth, user: User?) in
            if let activeUser = user {
                // Let's stor this user in db if not already stored.
                self.checkUser(user: activeUser)
            } else {
                self.loginSession()
            }
        }
    }
    
    func checkUser(user: User) {
        ref.child("members").queryOrdered(byChild: "id").queryEqual(toValue: user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                // User don't exist. Let's save this user.
                self.saveUser(user)
            }
            self.showDashboard()
        })
    }
    
    func showDashboard() {
        activityIndicator.stopAnimating()
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "dashboardViewController")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = newViewController
    }
    
    func saveUser(_ user: User) {
        var member = [DatabaseFields.CommonFields.id: user.uid]
        member[DatabaseFields.CommonFields.name] = user.displayName ?? ""
        member[DatabaseFields.MemberFields.email] = user.email ?? ""
        
        ref.child("members").childByAutoId().setValue(member)
    }
    
    func loginSession() {
        let authViewController = FUIAuth.defaultAuthUI()!.authViewController()
        present(authViewController, animated: true, completion: nil)
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
}
