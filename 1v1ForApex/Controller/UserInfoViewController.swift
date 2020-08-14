//
//  UserInfoViewController.swift
//  1v1ForApex
//
//  Created by 手塚友健 on 2020/07/27.
//  Copyright © 2020 手塚友健. All rights reserved.
//

import UIKit
import Firebase

class UserInfoViewController: UIViewController {
    
    
    @IBOutlet weak var UserInfoView: UIView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var idView: UIView!
    @IBOutlet weak var platformView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    let db = Firestore.firestore()
    var ref: DocumentReference? = nil
    
    var onBoarding: Bool = false
    
    typealias CompletionClosure = ((_ result:String) -> Void)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        editButton.layer.cornerRadius = 5
        logoutButton.layer.cornerRadius = 5
        
        idView.layer.cornerRadius = 5
        platformView.layer.cornerRadius = 5
        
        UserInfoView.layer.cornerRadius = 10
        
        addButton.layer.cornerRadius = 5

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                self.onBoarding = false
            }else{
                self.onBoarding = true
            }
        }
        
        if onBoarding {
            getData(key: "apexId", completionClosure: { (result: String) in
                self.idLabel.text = result
            })
            getData(key: "platform", completionClosure: { (result: String) in
                self.platformLabel.text = result
            })
        }else{
            idLabel.text = ""
            platformLabel.text = ""
        }
    }
    

    @IBAction func addAction(_ sender: Any) {
        if onBoarding {
            let uid = Auth.auth().currentUser?.uid
            let docRef = db.collection("users").document(uid!)
            docRef.getDocument { (document, error) in
                if let error = error {
                    print(error)
                }
                guard let data = document?.data() else {
                    return
                }
                if data["apexId"] as! String == "" || data["platform"] as! String == "" {
                    self.showAlert(type: "add")
                    print("hi")
                }else{
                    if data["isRecruiting"] as! Bool || data["isPlaying"] as! Bool {
                        self.showAlert(type: "recruited")
                    }else{
                        self.performSegue(withIdentifier: "add", sender: nil)
                    }
                }
            }
        }else{
            performSegue(withIdentifier: "login", sender: nil)
        }
    }
    
    @IBAction func editAction(_ sender: Any) {
        if onBoarding {
            performSegue(withIdentifier: "edit", sender: nil)
        }else{
            showAlert(type: "edit")
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
        let UINavigationController = tabBarController?.viewControllers?[0]
        tabBarController?.selectedViewController = UINavigationController
    }
    
    
    @IBAction func helpAction(_ sender: Any) {
        performSegue(withIdentifier: "help", sender: nil)
    }
    
    func showAlert(type: String) {
        let alertController = UIAlertController(title:"IDまたはプラットフォームを設定してください" , message: "", preferredStyle: .alert)
        if type == "edit" {
            alertController.title = "ログインしてください"
        } else if type == "recruited" {
            alertController.title = "参加できる1v1は1つだけです"
        }
        let action = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getData(key: String, completionClosure: @escaping CompletionClosure) {
        var value: String = "initial"
        let uid = Auth.auth().currentUser?.uid
        let docRef = db.collection("users").document(uid!)
        docRef.getDocument { (document, error) in
            if let error = error {
                print(error)
            }
            guard let data = document?.data() else {
                return
            }
            value = data["\(key)"] as! String
            completionClosure(value)
        }
    }
    
    
}
