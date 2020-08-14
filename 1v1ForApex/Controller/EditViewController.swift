//
//  EditViewController.swift
//  1v1ForApex
//
//  Created by 手塚友健 on 2020/07/29.
//  Copyright © 2020 手塚友健. All rights reserved.
//

import UIKit
import Firebase

class EditViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var platformView: UIView!
    @IBOutlet weak var ps4Button: UIButton!
    @IBOutlet weak var pcButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var idField: UITextField!
    
    var pressedButton: String = ""
    
    let db = Firestore.firestore()
    
    typealias CompletionClosure = ((_ result:String) -> Void)
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ps4Button.layer.cornerRadius = 5
        pcButton.layer.cornerRadius = 5
        editButton.layer.cornerRadius = 5
        editView.layer.cornerRadius = 10
        
        idField.delegate = self

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData(key: "platform", completionClosure: { (result: String) in
            self.pressedButton = result
            if self.pressedButton == "PS4"{
                self.ps4Button.layer.backgroundColor = CGColor(srgbRed: 252/255, green: 207/255, blue: 0/255, alpha: 1.0)
            } else {
                self.pcButton.layer.backgroundColor = CGColor(srgbRed: 252/255, green: 207/255, blue: 0/255, alpha: 1.0)
            }
        })

        

        
        getData(key: "apexId", completionClosure: { (result: String) in
            self.idField.text = result
        })
    }
    

    @IBAction func ps4ButtonAction(_ sender: Any) {
        
        pressedButton = "PS4"
        
        ps4Button.layer.backgroundColor = CGColor(srgbRed: 252/255, green: 207/255, blue: 0/255, alpha: 1.0)
        
        pcButton.layer.backgroundColor = CGColor(srgbRed: 252/255, green: 207/255, blue: 0/255, alpha: 0)
        
    }
    
    
    @IBAction func pcButtonAction(_ sender: Any) {
        
        pressedButton = "PC"
        
        ps4Button.layer.backgroundColor = CGColor(srgbRed: 252/255, green: 207/255, blue: 0/255, alpha: 0)
        
        pcButton.layer.backgroundColor = CGColor(srgbRed: 252/255, green: 207/255, blue: 0/255, alpha: 1.0)
    }
    
    @IBAction func canselAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        idField.resignFirstResponder()
    }
    
    
    @IBAction func editAction(_ sender: Any) {
        var platform: String
        if pressedButton == "PS4" {
            platform = "PS4"
        }else{
            platform = "PC"
        }
        if idField.text == "" || idField.text == nil {
            showAlert()
        }else{
            let uid = Auth.auth().currentUser?.uid
            updateData(uid: uid!, apexId: idField.text!, platform: platform)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func updateData(uid: String, apexId: String, platform: String) {
        db.collection("users").document(uid).updateData([
            "apexId": apexId,
            "platform": platform,
            "isRecruiting": false
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully added!")
            }
        }
    }
    
    func showAlert() {
           let alertController = UIAlertController(title:"すべて入力してください" , message: "", preferredStyle: .alert)
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
