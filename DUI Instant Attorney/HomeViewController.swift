//
//  HomeViewController.swift
//  DUI Instant Attorney
//
//  Created by macbook on 6/16/17.
//  Copyright © 2017 Balazs Benjamin. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SendGrid
import Alamofire
import CoreLocation
import FirebaseDatabase

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var btnAlert: UIButton!
    let userDefaults = UserDefaults.standard
    
    var locationManager = CLLocationManager()
    
    var reportID = ""
    var reportRef:DatabaseReference!
    var routesRef:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userDefaults.bool(forKey: "tracking_started") {
            btnAlert.setImage(UIImage(named: "alarm_red"), for: .normal)
        } else {
            btnAlert.setImage(UIImage(named: "alarm_blue"), for: .normal)
        }
        
        
        locationManager.delegate = self
        
        reportRef = Database.database().reference().child("reports")
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "icn_message"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(rightButtonAction), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        
        self.tabBarController?.navigationItem.rightBarButtonItem = item1
        
    }
    
    func rightButtonAction(sender: UIBarButtonItem) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let messageViewController = storyBoard.instantiateViewController(withIdentifier: "messageView") as! MessageViewController
        //self.present(messageViewController, animated:true, completion:nil)
        
        navigationController?.pushViewController(messageViewController,  animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated:true);
        self.tabBarController?.navigationItem.title = "Home"
        self.navigationController?.title = "Home"
    }
    
    @IBAction func onTouchUpAlert(_ sender: Any) {
        if userDefaults.bool(forKey: "tracking_started") {
            let alert = UIAlertController(title: "", message: "Would you stop tracking your routes?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler:{(action) in
                
                self.btnAlert.setImage(UIImage(named: "alarm_blue"), for: .normal)
                
                self.userDefaults.set(false, forKey: "tracking_started")
                self.userDefaults.synchronize()
                
                self.locationManager.stopMonitoringSignificantLocationChanges()
                
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler:{(action) in
            }))
            present(alert, animated: true, completion: nil)
        } else {
            
            self.userDefaults.set(true, forKey: "tracking_started")
            self.userDefaults.synchronize()
            
            self.btnAlert.setImage(UIImage(named: "alarm_red"), for: .normal)
            
            self.sendSMS(phoneNumber: attorneyCell)
            self.sendEmail(toEmail: attorneyEmail)
            
            if CLLocationManager.authorizationStatus() != .authorizedAlways {
                self.locationManager.requestAlwaysAuthorization()
            }
            self.locationManager.distanceFilter = kCLDistanceFilterNone
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            self.locationManager.startMonitoringSignificantLocationChanges()
            
            self.reportRef = Database.database().reference().child("reports").childByAutoId()
            
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let newReport = [
                "senderName": self.userDefaults.string(forKey: "name") ?? "",
                "senderAddress": self.userDefaults.string(forKey: "city") ?? "",
                "senderPhone": self.userDefaults.string(forKey: "phone") ?? "",
                "senderEmail": self.userDefaults.string(forKey: "email") ?? "",
                "senderId":self.userDefaults.string(forKey: "userid") ?? "",
                "createdAt": dateFormatter.string(from: now),
                ] as [String : Any]
            self.reportRef.setValue(newReport)
            
            self.routesRef = self.reportRef.child("route")

            
            let alert = UIAlertController(title: "", message: strAnnounced + "Would you announce your friend/family too?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler:{(action) in
                if isKeyPresentInUserDefaults(key: "name1") && isKeyPresentInUserDefaults(key: "phone1"){
                    self.sendSMS(phoneNumber: self.userDefaults.string(forKey: "phone1")!)
                    showToast(string: "Sent SMS to your friend.", view: self.view)
                } else {
                    showToast(string: "Not registered friend/family contact.", view: self.view)

                }
                
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler:{(action) in
            }))
            present(alert, animated: true, completion: nil)

        }

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        
        let newRouteRef = routesRef.childByAutoId()
        

        let newRoute = [
            "latitude":lat,
            "longitude":long,
            ] as [String : Any]

        
        newRouteRef.setValue(newRoute)
    }
    
    func sendEmail(toEmail:String) {
        Session.shared.authentication = Authentication.apiKey(SendGrid_API_KEY)

        let myEmail = UserDefaults.standard.string(forKey: "email")
        let myPhone = UserDefaults.standard.string(forKey: "phone")
        let myName = UserDefaults.standard.string(forKey: "name")

        let personalization = Personalization(recipients: toEmail)
        let plainText = Content(contentType: ContentType.plainText, value: strSOS + "\r\n\(myPhone!), \(myName!)")

        //let htmlText = Content(contentType: ContentType.htmlText, value: "<h1>Hello World</h1>")
        let email = Email(
            personalizations: [personalization],
            from: Address(email:myEmail!, name:myName!),
            //                    content: [plainText, htmlText],
            content: [plainText],
            subject: "Arrest SOS!"
        )
        do {
            try Session.shared.send(request: email)
        } catch {
            print(error)
        }
    }
    
    func sendSMS(phoneNumber:String) {
        let myPhone = UserDefaults.standard.string(forKey: "phone")
        let myName = UserDefaults.standard.string(forKey: "name")
        
        let params = [
            "api_key": "3953a6ed",
            "api_secret": "be483b077c7dc423",
            "to": phoneNumber,
            "from": "\(myPhone!)",
            "text": strSOS + "\r\n\(myPhone!), \(myName!)",
        ]
        
        Alamofire.request("https://rest.nexmo.com/sms/json",
                          method: .post, parameters: params, encoding:URLEncoding.default)
            .responseJSON { response in
                //SwiftLoader.hide()
                
                print(response.request as Any)  // original URL request
                print(response.response as Any) // URL response
                print(response.result.value as Any)   // result of response serialization
                
                
                
        }
    }
    
}
