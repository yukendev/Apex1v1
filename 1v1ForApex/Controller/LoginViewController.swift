//
//  LoginViewController.swift
//  1v1ForApex
//
//  Created by 手塚友健 on 2020/07/27.
//  Copyright © 2020 手塚友健. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let db = Firestore.firestore()
    var ref: DocumentReference? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 5
        signupButton.layer.cornerRadius = 5

        
    }
    
    @IBAction func loginAction(_ sender: Any) {
        let email: String = emailField.text!
        let password: String = passwordField.text!
        if email != "" && password != "" {
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showAlert(type: "login")
                }
            }
        } else {
            self.showAlert(type: "blank")
        }
    }
    
    @IBAction func signupAction(_ sender: Any) {
        let email: String = emailField.text!
        let password: String = passwordField.text!
        if email != "" && password != "" {
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if error == nil {
                    
                    let uid = result!.user.uid
                    self.addData(uid: uid, email: email, password: password)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showAlert(type: "signup")
                }
            }
        } else {
            self.showAlert(type: "blank")
        }
    }
    
    func showAlert(type: String) {
        let alertController = UIAlertController(title:"" , message: "", preferredStyle: .alert)
        if type == "login" {
            alertController.title = "ユーザーが存在しません"
        } else if type == "signup" {
            alertController.title = "既に使用されているアドレス, または不適切なアドレスです"
        } else {
            alertController.title = "空欄を埋めてください"
        }
        let action = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addData(uid: String, email: String, password: String) {
        db.collection("users").document(uid).setData([
            "uid": uid,
            "email": email,
            "password": password,
            "apexId": "",
            "platform": "",
            "my1v1": "",
            "isRecruiting": false,
            "isPlaying": false
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully added!")
            }
        }
    }
    
    
    @IBAction func cansel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    

}
