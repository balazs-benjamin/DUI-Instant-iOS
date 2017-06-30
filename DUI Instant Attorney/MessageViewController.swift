//
//  MessageViewController.swift
//  HardingLaw
//
//  Created by mobile developer on 2017. 03. 06..
//  Copyright © 2017. mobile developer. All rights reserved.
//

import Foundation

import UIKit
import Firebase

class MessageViewController: UIViewController {
    var channelRef: DatabaseReference!
    var senderDisplayName: String = ""
    
    
    var isPushed = false
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet var chatVc:ChatViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if(isPushed) {
            btnBack.addTarget(self, action: #selector(backPushed), for: .touchUpInside)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Chat"
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender:Any?)
    {
        if (segue.identifier == "myEmbeddedSegue") {
            chatVc = segue.destination as? ChatViewController
            
            let userDefaults = UserDefaults.standard
            let sender_name = userDefaults.string(forKey: "name")
            
            chatVc.senderDisplayName = sender_name
            
            channelRef = Database.database().reference().child("channels")
            chatVc.channelRef = channelRef.child((Auth.auth().currentUser?.uid)!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backPushed() {
        self.dismiss(animated: true, completion: nil)
    }
}
