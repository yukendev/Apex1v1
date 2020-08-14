//
//  CustomCell.swift
//  1v1ForApex
//
//  Created by 手塚友健 on 2020/07/27.
//  Copyright © 2020 手塚友健. All rights reserved.
//

import UIKit
import Firebase

class CustomCell: UITableViewCell {
    
    
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
   
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var alertdelegate: alertDelegate?
    
    var uuid: String = ""
    
    let db = Firestore.firestore()
    var ref: DocumentReference? = nil
    
    var onBoarding: Bool = false
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.cornerRadius = 10
        platformLabel.layer.cornerRadius = 5
        platformLabel.clipsToBounds = true
        commentLabel.layer.cornerRadius = 5
        commentLabel.clipsToBounds = true
        levelLabel.layer.borderWidth = 2.0
        levelLabel.layer.cornerRadius = 5
        levelLabel.layer.borderColor = CGColor(srgbRed: 252/255, green: 207/255, blue: 0/255, alpha: 1.0)
        timeView.layer.borderWidth = 2.0
        timeView.layer.cornerRadius = 5
        timeView.layer.borderColor = CGColor(srgbRed: 252/255, green: 207/255, blue: 0/255, alpha: 1.0)
        
        button.layer.cornerRadius = 5
        
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                self.onBoarding = false
            }else{
                self.onBoarding = true
            }
        }
        
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    
    @IBAction func entryAction(_ sender: Any) {
        if onBoarding {
            let uid = Auth.auth().currentUser?.uid
            db.collection("users").document(uid!).getDocument { (snapshot, error) in
                guard let data = snapshot?.data() else {
                    return
                }
                if data["apexId"] as! String == "" || data["platform"] as! String == "" {
                    self.alertdelegate?.showDelegate(type: "noId")
                }else{
                    self.db.collection("lists").document(self.uuid).getDocument { (snapshot, error) in
                        guard let listData = snapshot?.data() else {
                            return
                        }
                        if listData["isEntried"] as! Bool {
                            self.alertdelegate?.showDelegate(type: "isEntried")
                        }else{
                            if data["my1v1"] as! String == "" {
                                self.db.collection("users").document(uid!).updateData([
                                    "isPlaying": true,
                                    "my1v1": self.uuid
                                ]) { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                    }
                                }
                                
                                self.db.collection("users").document(listData["ownerPlayerId"] as! String).updateData([
                                    "isPlaying": true
                                ])
                                
                                self.db.collection("lists").document(self.uuid).updateData([
                                    "entriedPlayer": data["apexId"] as! String,
                                    "entriedPlayerId": data["uid"] as! String,
                                    "isEntried": true
                                ])
                            }else{
                                self.alertdelegate?.showDelegate(type: "my1v1")
                            }
                        }
                    }
                }
            }
        }else{
            self.alertdelegate?.showDelegate(type: "")
        }
    }
    
    
    
    
    
}



