//
//  My1v1ViewController.swift
//  1v1ForApex
//
//  Created by 手塚友健 on 2020/07/27.
//  Copyright © 2020 手塚友健. All rights reserved.
//

import UIKit
import Firebase

class My1v1ViewController: UIViewController {
    
    @IBOutlet var wrapper: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var partnerIdLabel: UILabel!
    @IBOutlet weak var idView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var notEntriedLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    let db = Firestore.firestore()
    var ref: DocumentReference? = nil
    
    let label = UILabel()
    
    var onBoarding: Bool = false
    
    typealias CompletionClosure = ((_ return: List) -> Void)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        container.layer.cornerRadius = 10
        commentLabel.layer.cornerRadius = 5
        commentLabel.clipsToBounds = true
        
        deleteButton.layer.cornerRadius = 5
        
        levelLabel.layer.borderWidth = 2
        levelLabel.layer.cornerRadius = 5
        levelLabel.layer.borderColor = CGColor(srgbRed: 252/255, green: 207/255, blue: 0/255, alpha: 1.0)
        
        timeView.layer.borderWidth = 2
        timeView.layer.cornerRadius = 5
        timeView.layer.borderColor = CGColor(srgbRed: 252/255, green: 207/255, blue: 0/255, alpha: 1.0)
        
        platformLabel.layer.cornerRadius = 5
        platformLabel.clipsToBounds = true
        
        idView.layer.cornerRadius = 5
        
        addButton.layer.cornerRadius = 5
        
        label.frame = CGRect(x: 0, y: 0, width: view.frame.size.width*3/5, height: view.frame.size.height/2)
        label.text = "1v1がありません"
        label.center = view.center
        label.textAlignment = .center
        label.font = label.font.withSize(25)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        deleteButton.isHidden = true
        notEntriedLabel.isHidden = true
        
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                self.onBoarding = false
            }else{
                self.onBoarding = true
            }
        }
        
        if Auth.auth().currentUser != nil {
            let uid = Auth.auth().currentUser?.uid
            db.collection("users").document(uid!).getDocument { (snapshot, error) in
                guard let data = snapshot?.data() else {
                    return
                }
                if data["my1v1"] as! String != "" {
                    self.db.collection("lists").document(data["my1v1"] as! String).getDocument { (snapshot, error) in
                        guard let listData = snapshot?.data() else {
                            return
                        }
                        if listData["ownerPlayer"] as! String == data["apexId"] as! String {
                            self.deleteButton.setTitle("投稿を削除する", for: .normal)
                        }else if listData["entriedPlayer"] as! String == data["apexId"] as! String {
                            self.deleteButton.setTitle("1v1を抜ける", for: .normal)
                        }
                    }
                }
            }
        }

        
        getData { (list)  in
                self.container.isHidden = false
                self.titleLabel.isHidden = false
            
            let idString: String = String(list.ownerPlayer.prefix(3))
                
                self.idLabel.text = idString + "********"
                self.platformLabel.text = list.platform
                self.createdAtLabel.text = list.createdAt
                self.levelLabel.text = list.playerLevel
                self.startTimeLabel.text = list.startTime
                self.endTimeLabel.text = list.endTime
                self.commentLabel.text = list.comment
                
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
                    self.showAlert(type: "id")
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
    
    func showAlert(type: String) {
        let alertController = UIAlertController(title:"IDまたはプラットフォームを設定してください" , message: "", preferredStyle: .alert)
        if type == "recruited" {
            alertController.title = "参加できる1v1は1つだけです"
        }
        let action = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getData(completionClosure: @escaping CompletionClosure) {
        
        if onBoarding {
            let uid = Auth.auth().currentUser?.uid
            let docRef = db.collection("users").document(uid!)
            docRef.getDocument { (document, error) in
                guard let data = document?.data() else {
                    return
                }
                if data["my1v1"] as? String == nil || data["my1v1"] as! String == "" {
                    self.no1v1()
                    self.wrapper.addSubview(self.label)
                }else{
                    self.db.collection("lists").document(data["my1v1"] as! String).getDocument { (snapshot, error) in
                        guard let listData = snapshot?.data() else {
                            return
                        }
                        if listData["entriedPlayer"] as! String == "" {
                            self.notEntriedLabel.isHidden = false
                            self.idView.isHidden = true
                        }else{
                            self.idView.isHidden = false
                        }
                        
                        if data["isRecruiting"] as! Bool {
                            self.partnerIdLabel.text = listData["entriedPlayer"] as? String
                        }else{
                            self.partnerIdLabel.text = listData["ownerPlayer"] as? String
                        }
                        let list = List()
                        list.ownerPlayer = listData["ownerPlayer"] as! String
                        list.platform = listData["platform"] as! String
                        list.createdAt = listData["createdAt"] as! String
                        list.playerLevel = listData["playerLevel"] as! String
                        list.startTime = listData["startTime"] as! String
                        list.endTime = listData["endTime"] as! String
                        list.comment = listData["comment"] as! String
                        
                        self.container.isHidden = false
                        self.titleLabel.isHidden = false
                        
                        self.label.removeFromSuperview()
                        
                        completionClosure(list)

                    }
                    self.deleteButton.isHidden = false
                }
            }
        }else{
            no1v1()
            wrapper.addSubview(label)
        }
    }
    
    func no1v1() {
        self.container.isHidden = true
        self.idView.isHidden = true
        self.titleLabel.isHidden = true
        self.deleteButton.isHidden = true
        
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        let docRef = db.collection("users").document(uid!)
        docRef.getDocument { (snapshot, error) in
            guard let data = snapshot?.data() else {
                return
            }
            let my1v1 = data["my1v1"] as! String
            self.db.collection("lists").document(my1v1).getDocument { (snapshot, error) in
                guard let listData = snapshot?.data() else {
                    return
                }
                if data["apexId"] as! String == listData["ownerPlayer"] as! String {
//                    投稿者が削除する場合の処理
                    self.db.collection("users").document(uid!).updateData([
                        "isRecruiting": false,
                        "isPlaying": false,
                        "my1v1": ""
                    ])
                    if listData["entriedPlayer"] as! String != "" {
                        self.db.collection("users").document(listData["entriedPlayerId"] as! String).updateData([
                            "isPlaying": false,
                            "my1v1": ""
                        ])
                    }
                    self.db.collection("lists").document(my1v1).delete()
//                    投稿者が削除する場合の処理
                    
                }else if data["apexId"] as! String == listData["entriedPlayer"] as! String{
//                    エントリーしたプレイヤーが抜ける場合の処理
                    self.db.collection("users").document(uid!).updateData([
                        "isPlaying": false,
                        "my1v1": ""
                    ])
                    self.db.collection("users").document(listData["ownerPlayerId"] as! String).updateData([
                        "isPlaying": false,
                    ])
                    self.db.collection("lists").document(listData["uuid"] as! String).updateData([
                        "isEntried": false,
                        "entriedPlayer": "",
                        "entriedPlayerId": ""
                    ])
//                    エントリーしたプレイヤーが抜ける場合の処理
                }
            }
            let UINavigationController = self.tabBarController?.viewControllers?[0]
            self.tabBarController?.selectedViewController = UINavigationController
        }
    }
    
    
    
}
