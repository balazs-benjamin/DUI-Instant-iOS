//
//  ViewController.swift
//  DUI Instant Attorney
//
//  Created by mobile developer on 2017. 06. 05..
//  Copyright © 2017. Balazs Benjamin. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FirebaseAuth
import FirebaseDatabase
import RappleProgressHUD

extension String {
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.characters.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.characters.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
}

class RegisterViewController: UIViewController {

    @IBOutlet weak var tfName: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var tfCity: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var tfPhone: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var tfEmail: SkyFloatingLabelTextFieldWithIcon!
    
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

        tfCity.iconFont = UIFont(name: "FontAwesome", size: 18)
        tfCity.iconText = "\u{f19c}"

        tfPhone.iconFont = UIFont(name: "FontAwesome", size: 27)
        tfPhone.iconText = "\u{f10b}"

        tfEmail.iconFont = UIFont(name: "FontAwesome", size: 18)
        tfEmail.iconText = "\u{f003}"
        
        
        
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "main", sender: nil)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    @IBAction func onRegister(_ sender: Any) {
        if checkValidate() {
            RappleActivityIndicatorView.startAnimatingWithLabel("Registering...")
            Auth.auth().signInAnonymously(completion: { (user, error) in
                RappleActivityIndicatorView.stopAnimating()
                if let err:Error = error {
                    print(err.localizedDescription)
                    return
                }
                
                let ref = Database.database().reference().child("users").child(user!.uid)
                var oneSignalId = UserDefaults.standard.string(forKey: "OneSignalId")
                if oneSignalId == nil { oneSignalId = ""}
                let newUser = [
                    "name":self.tfName.text!,
                    "city":self.tfCity.text!,
                    "phone":self.tfPhone.text!,
                    "email":self.tfEmail.text!,
                    "OneSignalId": oneSignalId! as String
                    ] as [String : Any]
                ref.setValue(newUser)
                
                let channelRef = Database.database().reference().child("channels").child(user!.uid)
                let newChannel = [
                    "name":self.tfName.text!,
                    "city":self.tfCity.text!,
                    "phone":self.tfPhone.text!,
                    "email":self.tfEmail.text!,
                    ] as [String : Any]
                channelRef.setValue(newChannel)
                
                let userDefaults = UserDefaults.standard
                userDefaults.set(user!.uid, forKey: "userid")
                userDefaults.set(self.tfName.text!, forKey: "name")
                userDefaults.set(self.tfCity.text!, forKey: "city")
                userDefaults.set(self.tfPhone.text!, forKey: "phone")
                userDefaults.set(self.tfEmail.text!, forKey: "email")
                userDefaults.synchronize()
                
                self.performSegue(withIdentifier: "addFriend", sender: nil)
                
            })
        }
    }
    
    func checkValidate() -> Bool {
        if (tfName.text?.isEmpty)! {
            tfName.errorMessage = "This field is required"
            return false
        }
        if (tfCity.text?.isEmpty)! {
            tfCity.errorMessage = "This field is required"
            return false
        }
        if (tfPhone.text?.isEmpty)! {
            tfPhone.errorMessage = "This field is required"
            return false
        }
        if (tfEmail.text?.isEmpty)! {
            tfEmail.errorMessage = "This field is required"
            return false
        }
        if !(tfPhone.text?.isPhoneNumber)! {
            tfPhone.errorMessage = "Invalid Phone Number"
        }
        if !isValidEmail(value: tfEmail.text!) {
            tfEmail.errorMessage = "Invalid Email"
            return false
        }
        return true;
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
                
                if floatingLabelTextField.tag == 104 {
                    if !isValidEmail(value: text) {
                        floatingLabelTextField.errorMessage = "Invalid email"
                    } else {
                        floatingLabelTextField.errorMessage = ""
                    }
                } else if floatingLabelTextField.tag == 103 {
                    if(!text.isPhoneNumber) {
                        floatingLabelTextField.errorMessage = "Invalid Phone number"
                    } else {
                        floatingLabelTextField.errorMessage = ""
                    }
                }
            }
        }
    }

}

