//
//  getCountryPhonceCode.swift
//  Auth App
//
//  Created by mobile developer on 2017. 05. 26..
//  Copyright © 2017. Balazs Benjamin. All rights reserved.
//

import UIKit

// validate email address
func isValidEmail(value:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: value)
}

// validate email password complexity
func isValidPassword(value:String) -> Bool {
//    let regEx = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[a-z])(?=.*[0-9]).{8,24}$"
    let regEx = "^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9]).{8,24}$"
    
    let regTest = NSPredicate(format:"SELF MATCHES %@", regEx)
    return regTest.evaluate(with: value)
}

// Show alert dialoge with the given messsage and set focus to the textfield if it's set
func showAlert(viewController:UIViewController, strMsg:String, focusItem:UITextField?) {
    let alert = UIAlertController(title: "", message: strMsg, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{(action) in
        if focusItem != nil {
            focusItem?.becomeFirstResponder()
        }
    }))
    viewController.present(alert, animated: true, completion: nil)
}

func putIcon(inTextField:UITextField, iconName:String) {
    //inTextField.layer.cornerRadius = 13
    //inTextField.layer.borderWidth = 1
    //inTextField.layer.borderColor = UIColor.white.cgColor
    
    let imageView = UIImageView()
    let image = UIImage(named: iconName)
    
    imageView.image = image
    imageView.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
    inTextField.addSubview(imageView)
    let leftView = UIView.init(frame: CGRect(x:10, y:0, width:40, height:30))
    inTextField.leftView = leftView
    inTextField.leftViewMode = .always

}

func showToast(string: String!, focus: Bool = false, textField:UITextField! = nil, view:UIView) {
    let toastLabel = UILabel(frame: CGRect(x:view.frame.size.width/2 - 150, y:view.frame.size.height/2, width:300, height:35))
    toastLabel.backgroundColor = UIColor.black
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = NSTextAlignment.center
    view.addSubview(toastLabel)
    toastLabel.text = string
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    
    if focus {
        textField.becomeFirstResponder()
    }
    
    UIView.animate(withDuration: 4.0, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
        
        toastLabel.alpha = 0.0
        
    })
}

func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}
