//
//  HomeViewController.swift
//  1v1ForApex
//
//  Created by 手塚友健 on 2020/07/27.
//  Copyright © 2020 手塚友健. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, alertDelegate  {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var listArray = [List]()
    @IBOutlet weak var addButton: UIButton!
    
    let db = Firestore.firestore()
    var ref: DocumentReference? = nil
    
    typealias CompletionClosure = (() -> Void)
    
    var uid: String = ""
    
    var onBoarding: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "list")
        
        addButton.layer.cornerRadius = 5
        
        getData { () in
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData {
            self.tableView.reloadData()
        }
        
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                self.onBoarding = false
            }else{
                self.onBoarding = true
            }
        }
    
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath) as! CustomCell
        
        cell.alertdelegate = self
        
        cell.selectionStyle = .none
        
        cell.idLabel.text = listArray[indexPath.row].ownerPlayer
        cell.platformLabel.text = listArray[indexPath.row].platform
        cell.createdAtLabel.text = listArray[indexPath.row].createdAt
        cell.levelLabel.text = listArray[indexPath.row].playerLevel
        cell.startTime.text = listArray[indexPath.row].startTime
        cell.endTime.text = listArray[indexPath.row].endTime
        cell.commentLabel.text = listArray[indexPath.row].comment
        
        cell.uuid = listArray[indexPath.row].id
        
        let uuid = listArray[indexPath.row].id
        
        db.collection("lists").document(uuid).getDocument { (snapshot, error) in
            guard let data = snapshot?.data() else {
                return
            }
            if data["isEntried"] as! Bool {
                cell.button.setTitle("エントリーされています", for: .normal)
                cell.button.backgroundColor = UIColor.gray
                cell.button.isEnabled = false
            }else{
                cell.button.setTitle("エントリーする", for: .normal)
                cell.button.backgroundColor = UIColor.init(cgColor: CGColor(srgbRed: 252/255, green: 207/255, blue: 0/255, alpha: 1.0))
                cell.button.isEnabled = true
            }
        }
        
        return cell
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
        listArray.removeAll()
        db.collection("lists").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    let list = List()
                    let data = document.data()
                    let idString: String = data["ownerPlayer"] as! String
                    list.id = data["uuid"] as! String
                    list.ownerPlayer = String(idString.prefix(3)) + "********"
                    list.ownerPlayerId = data["ownerPlayerId"] as! String
                    list.entriedPlayer = data["entriedPlayer"] as! String
                    list.entriedPlayerId = data["entriedPlayerId"] as! String
                    list.platform = data["platform"] as! String
                    list.playerLevel = data["playerLevel"] as! String
                    list.startTime = data["startTime"] as! String
                    list.endTime = data["endTime"] as! String
                    list.createdAt = data["createdAt"] as! String
                    list.comment = data["comment"] as! String
                    list.isEntried = data["isEntried"] as! Bool
                    
                    self.listArray.append(list)
                    
                    completionClosure()
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func showDelegate(type: String) {
        let alertController = UIAlertController(title:"ログインしてください" , message: "", preferredStyle: .alert)
        if type == "my1v1" {
            alertController.title = "My1v1は1つまでです"
        }else if type == "noId" {
            alertController.title = "IDまたはプラットフォームを設定してください"
        }else if type == "isEntied" {
            alertController.title = "すでにエントリーされています"
        }
        let action = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

}
