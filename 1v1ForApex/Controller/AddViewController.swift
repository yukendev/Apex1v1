//
//  AddViewController.swift
//  1v1ForApex
//
//  Created by 手塚友健 on 2020/07/28.
//  Copyright © 2020 手塚友健. All rights reserved.
//

import UIKit
import Firebase

class AddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    @IBOutlet weak var levelTextField: UITextField!
    var pickerView: UIPickerView = UIPickerView()
    
    @IBOutlet weak var commentField: UITextView!
    
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var endTimeField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var addView: UIView!
    var timePicker: UIDatePicker = UIDatePicker()
    
    let db = Firestore.firestore()
   
    let levelList = ["初心者同士で", "上級者求む", "誰でもOK"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        commentField.layer.cornerRadius = 5
        
        label1.layer.cornerRadius = 5
        label1.clipsToBounds = true
        label2.layer.cornerRadius = 5
        label2.clipsToBounds = true
        label3.layer.cornerRadius = 5
        label3.clipsToBounds = true
        
        levelTextField.inputView = pickerView
        levelTextField.inputAccessoryView = toolBar(type: "level")
        
        timePicker.datePickerMode = .time
        timePicker.timeZone = NSTimeZone.local
        timePicker.locale = Locale(identifier: "ja_JP")
        
        startTimeField.inputView = timePicker
        startTimeField.inputAccessoryView = toolBar(type: "start")
        endTimeField.inputView = timePicker
        endTimeField.inputAccessoryView = toolBar(type: "end")
        
        
        
        addView.layer.cornerRadius = 10
        postButton.layer.cornerRadius = 5
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc func LevelDone() {
        levelTextField.endEditing(true)
        levelTextField.text = "\(levelList[pickerView.selectedRow(inComponent: 0)])"
    }
    
    @objc func StartDone() {
        startTimeField.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        startTimeField.text = "\(formatter.string(from: timePicker.date))"

    }
    
    @objc func EndDone() {
        endTimeField.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        endTimeField.text = "\(formatter.string(from: timePicker.date))"
    }
    
    
    func toolBar(type: String) -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
        button.setTitle("追加", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        if type == "level" {
            button.addTarget(self, action: #selector(LevelDone), for: .touchUpInside)
        }else if type == "start" {
            button.addTarget(self, action: #selector(StartDone), for: .touchUpInside)
        }else if type == "end" {
            button.addTarget(self, action: #selector(EndDone), for: .touchUpInside)
        }
        let levelDone = UIBarButtonItem()
        levelDone.customView = button
        let startDone = UIBarButtonItem()
        startDone.customView = button
        let endDone = UIBarButtonItem()
        endDone.customView = button
        
        if type == "level" {
            toolBar.setItems([spaceItem, levelDone], animated: true)
        }else if type == "start" {
            toolBar.setItems([spaceItem, startDone], animated: true)
        }else if type == "end" {
            toolBar.setItems([spaceItem, endDone], animated: true)
        }
        
        return toolBar
        
    }
    
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return levelList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return levelList[row]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    @IBAction func canselAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func postAction(_ sender: Any) {
        let uuid = NSUUID().uuidString
        let dt: Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HH:mm", options: 0, locale: Locale(identifier: "ja_JP"))

        if levelTextField.text == "" || startTimeField.text == "" || endTimeField.text == "" {
            showAlert()
        }else{
            let uid = Auth.auth().currentUser?.uid
            let docRef = db.collection("users").document(uid!)
            docRef.getDocument { (document, error) in
                guard let data = document?.data() else {
                    return
                }
                self.db.collection("lists").document(uuid).setData([
                    "uuid": uuid,
                    "ownerPlayer": data["apexId"] as! String,
                    "ownerPlayerId": uid!,
                    "entriedPlayer": "",
                    "entriedPlayerId": "",
                    "platform": data["platform"] as! String,
                    "playerLevel": self.levelTextField.text!,
                    "startTime": self.startTimeField.text!,
                    "endTime": self.endTimeField.text!,
                    "createdAt": String(dateFormatter.string(from: dt)),
                    "comment": self.commentField.text!,
                    "isEntried": false
                ])
                self.db.collection("users").document(uid!).updateData([
                    "isRecruiting": true,
                    "my1v1": uuid
                ])
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func showAlert() {
        let alertController = UIAlertController(title:"すべて入力してください" , message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

    
 

}
