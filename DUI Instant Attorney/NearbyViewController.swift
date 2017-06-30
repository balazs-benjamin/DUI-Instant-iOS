//
//  NearbyViewController.swift
//  DUI Instant Attorney
//
//  Created by macbook on 6/16/17.
//  Copyright © 2017 Balazs Benjamin. All rights reserved.
//

import UIKit


import GoogleMaps
import CoreLocation
import Alamofire


class NearbyViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var mapView:GMSMapView!
    var locationManager = CLLocationManager()
    var lat = 39.746478
    var long = -104.991775
    var radius = 5000
    var APIKey = "AIzaSyBIuLv2rY63J1THdtdx55EtqtO1E978JWk"
    var type = "police"
    var bFirstLoad = true
    
    var bounds = GMSCoordinateBounds()
    var path = GMSMutablePath()
    var myPosition = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
        
        let selectedIndex = tabBarController!.selectedIndex
        
        if selectedIndex == 1 {
            self.tabBarController?.navigationItem.title = "Bail Bonds"
            type = "bail_bonds"
        } else {
            self.tabBarController?.navigationItem.title = "Police"
            type = "police"
        }
        
        

        getData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        long = userLocation.coordinate.longitude;
        lat = userLocation.coordinate.latitude;
        myPosition = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        if !bFirstLoad{
            return
        }
        bFirstLoad = false
        
        mapView.isMyLocationEnabled = true
        
        /*
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 13.0)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = ""
        marker.snippet = ""
        marker.map = mapView
        */
        
        getData()
        
        print(long, lat)
        
        //Do What ever you want with it
    }
    
    func getData() {
        mapView.clear()
        var url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&type=\(type)&key=\(APIKey)&rankby=distance"
        if type == "bail_bonds" {
            url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&keyword==\(type)&key=\(APIKey)&rankby=distance"
        }

        path.removeAllCoordinates()
        path.add(myPosition)

        Alamofire.request(url).responseJSON { response in
            debugPrint(response)
            
            if let json = response.result.value {
                print("JSON: \(json)")
                
                var names = [String]()
                var lats = [Double]()
                var longs = [Double]()
                var vicinitys = [String]()
                
                let jsonResult = json as! [String : AnyObject]
                if let results = jsonResult["results"] as? [[String : AnyObject]] {
                    for result in results{
                        if let name = result["name"] as? String {
                            names.append(name)
                        }
                        if let vicinity = result["vicinity"] as? String {
                            vicinitys.append(vicinity)
                        }
                        if let geometry = result["geometry"] as? [String : AnyObject] {
                            if let location = geometry["location"] as? [String : AnyObject] {
                                if let lat = location["lat"] as? Double {
                                    lats.append(lat)
                                }
                                if let long = location["lng"] as? Double {
                                    longs.append(long)
                                }
                            }
                        }
                    }
                }
                
                
                print(names)
                print(vicinitys)
                print(lats)
                print(longs)
                
                if names.count > 0 {
                    
                    for i in 0...names.count-1 {
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: lats[i], longitude: longs[i])
                        marker.title = names[i]
                        marker.snippet = vicinitys[i]
                        marker.icon = GMSMarker.markerImage(with: UIColor.green)
                        marker.map = self.mapView
                        marker.opacity = 0.85
                        marker.isFlat = true
                        marker.appearAnimation = GMSMarkerAnimation.pop
                        
                        if self.mapView.selectedMarker == nil {
                            self.mapView.selectedMarker = marker
                        }
                        self.path.add(marker.position)
                    }
                    
                    self.bounds = GMSCoordinateBounds.init(path: self.path)
                    let update = GMSCameraUpdate.fit(self.bounds, withPadding: 100)
                    self.mapView.animate(with: update)
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        // Dispose of any resources that can be recreated.
    }
}

