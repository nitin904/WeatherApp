//
//  ViewController.swift
//  WeatherApp
//
//  Created by Xcode User on 2020-04-19.
//  Copyright © 2020 Xcode User. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import CoreLocation
import SwiftyJSON
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var backgroundView: UIView!
    
    let gradientLayer = CAGradientLayer()
    
    
    let apiKey = "503d35b59cad0822300b61f85dcc6060"
    
    var lat = 12.12345
    var lon = 103.12345
    
    var activityIndicator: NVActivityIndicatorView!
    
    //to get user location
    let locationManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //adding gradient layerr as sub layer of background view
        backgroundView.layer.addSublayer(gradientLayer)
        
        //settig up activity indicator properties
         let indicatorSize: CGFloat = 70
         let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        
        activityIndicator.backgroundColor = UIColor.black
        //adding activity indicator to sub view
        view.addSubview(activityIndicator)
        
        //getting user location - will popup to ask user
        locationManager.requestWhenInUseAuthorization()
               
        activityIndicator.startAnimating()
        
        //chcking location services is enable or not
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setBlueGradientBackground()
        //setGreyGradientBackground()
    }
    
    
    
     //called whenever ocation info is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
       //gettting info about location and fetching latitude and longitude
        //location manager will give us an array
       let location = locations[0]
       lat = location.coordinate.latitude
       lon = location.coordinate.longitude

        //Using almofire to get the coordinates from openweatherAPI and getting JSON response back
   Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric").responseJSON {
            response in
        
        //stop activity indicator if we get response back
        self.activityIndicator.stopAnimating()
        
    //reading back the JSON data
        if let responseStr = response.result.value {
          
          //extract the JSON data and storing it in the variables
          let jsonResponse = JSON(responseStr)
          //Fetching the weather object
          //weather is an array and fetching first element
          let jsonWeather = jsonResponse["weather"].array![0]
            
          //fetching the temperature value
          let jsonTemp = jsonResponse["main"]
          
           //fetching the icon value
          let iconName = jsonWeather["icon"].stringValue
          
          //fetching the location name and appending it to label
          self.locationLabel.text = jsonResponse["name"].stringValue
          
           //Uodating image depending upon the datafected and icon fetched
          self.conditionImageView.image = UIImage(named: iconName)
          
          //fetching the main value from JSON that notifies the temp and appending it to label
          self.conditionLabel.text = jsonWeather["main"].stringValue
            
          //appending the temperature value to label
          self.temperatureLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
          
          
          //get info about the current date and day
          let date = Date()
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "EEEE"
          self.dayLabel.text = dateFormatter.string(from: date)
               
          //getting info about the daytime from JSON and updating background
          let suffix = iconName.suffix(1)
          if(suffix == "n"){
             self.setGreyGradientBackground()
            }else{
                self.setBlueGradientBackground()
            }
        }
    }
    
        //stop updatig the location as location manager will constantly search to update the location and consumes battery.
       self.locationManager.stopUpdatingLocation()
        
        
}
    
    
    
    
    //changing backgound according to the day time i.e day or night
    //day color background
    func setBlueGradientBackground(){
        
        //setting the background color bu using UICOLOR property
        let topColor = UIColor(red: 95.0/255.0, green: 165.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255.0, green: 114.0/255.0, blue: 184.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
        
    }
    
    //night color background
    func setGreyGradientBackground(){
        //setting the background color bu using UICOLOR property
        let topColor = UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0).cgColor
               let bottomColor = UIColor(red: 72.0/255.0, green: 72.0/255.0, blue: 72.0/255.0, alpha: 1.0).cgColor
               gradientLayer.frame = view.bounds
               gradientLayer.colors = [topColor, bottomColor]
        
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    


}

