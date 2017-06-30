//
//  FamilyViewController.swift
//  DUI Instant Attorney
//
//  Created by macbook on 6/16/17.
//  Copyright © 2017 Balazs Benjamin. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FirebaseDatabase
import FirebaseAuth

class FamilyViewController: UIViewController {
    
    @IBOutlet weak var tfName: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var tfPhone: SkyFloatingLabelTextFieldWithIcon!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSubmit.layer.borderColor = UIColor.clear.cgColor
        btnSubmit.layer.cornerRadius = 0//5
        btnSubmit.layer.borderWidth = 1
        btnSubmit.layer.backgroundColor = uicolorFromHex(0xe3111a).cgColor
        
        /*
         putIcon(inTextField: tfName, iconName: "icn_user")
         putIcon(inTextField: tfCity, iconName: "icn_city")
         putIcon(inTextField: tfPhone, iconName: "icn_phone")
         putIcon(inTextField: tfEmail, iconName: "icn_email")
         */
        
        
        tfName.iconFont = UIFont(name: "FontAwesome", size: 18)
        tfName.iconText = "\u{f2c0}"
        
        tfPhone.iconFont = UIFont(name: "FontAwesome", size: 27)
        tfPhone.iconText = "\u{f10b}"
        
        tfName.text = UserDefaults.standard.string(forKey: "name1") ?? ""
        tfPhone.text = UserDefaults.standard.string(forKey: "phone1") ?? ""
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Quick Contact"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onEditing(_ textField: UITextField) {
        if let text = textField.text {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                if text.isEmpty {
                    floatingLabelTextField.errorMessage = "This field is required"
                } else {
                    floatingLabelTextField.errorMessage = ""
                }
                
                if floatingLabelTextField.tag == 103 {
                    if(!text.isPhoneNumber) {
                        floatingLabelTextField.errorMessage = "Invalid Phone number"
                    } else {
                        floatingLabelTextField.errorMessage = ""
                    }
                }
            }
        }
    }
    
    func checkValidate() -> Bool {
        if (tfName.text?.isEmpty)! {
            tfName.errorMessage = "This field is required"
            return false
        }
        if (tfPhone.text?.isEmpty)! {
            tfPhone.errorMessage = "This field is required"
            return false
        }
        if !(tfPhone.text?.isPhoneNumber)! {
            tfPhone.errorMessage = "Invalid Phone Number"
        }
        return true;
    }
    
    @IBAction func onSave(_ sender: Any) {
        if checkValidate() {
            let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("contacts")
            let newUser = [
                "name1":self.tfName.text!,
                "phone1":self.tfPhone.text!,
                ] as [String : Any]
            ref.setValue(newUser)
            
            let userDefaults = UserDefaults.standard
            userDefaults.set(self.tfName.text!, forKey: "name1")
            userDefaults.set(self.tfPhone.text!, forKey: "phone1")
            userDefaults.synchronize()
            
            tabBarController?.selectedIndex = 0
        }
    }
   
}
