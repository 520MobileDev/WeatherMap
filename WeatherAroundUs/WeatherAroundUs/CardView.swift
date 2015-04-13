//
//  CardView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/4.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit

class CardView: UIView {

    @IBOutlet var icon: UIImageView!
    @IBOutlet var temperature: UILabel!
    @IBOutlet var city: UILabel!
    @IBOutlet var weather: UILabel!
    
    func displayCity(cityID: String){
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.icon.alpha = 0
            self.temperature.alpha = 0
            self.city.alpha = 0
            self.weather.alpha = 0
            }) { (done) -> Void in
                /*
                //let info = WeatherInfo.citiesAroundDict[cityID]
                self.icon.image = UIImage(named: "cloudAndSun")!
                var temp = ((info as! [String: AnyObject])["main"] as! [String: AnyObject])["temp"] as! Double
                temp = temp - 273
                self.temperature.text = "\(Int(temp))"
                self.city.text = (info as! [String: AnyObject])["name"] as! String
                self.weather.text = ((info as! [String: AnyObject])["weather"] as! [String: AnyObject])["description"] as! String*/
        }
    }

}
