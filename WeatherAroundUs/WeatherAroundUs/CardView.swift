//
//  CardView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/4.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Spring

class CardView: DesignableView {

    var icon: UIImageView!
    var temperature: UILabel!
    var city: UILabel!
    var smallImage: UIImage!
    var weatherDescription: UILabel!
    
    var iconBack: DesignableView!
    var temperatureBack: DesignableView!
    var cityBack: DesignableView!
    var weatherDescriptionBack: DesignableView!
    var smallImageBack: DesignableView!

    var iconBackCenter: CGPoint!
    var temperatureBackCenter: CGPoint!
    var cityBackCenter: CGPoint!
    var weatherDescriptionBackCenter: CGPoint!
    
    var hide = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(){
        
        self.userInteractionEnabled = false
        
        let fontFamilyNames = UIFont.familyNames()
        for familyName in fontFamilyNames {
            println("------------------------------")
            println("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNamesForFamilyName(familyName as! String)
            println("Font Names = [\(names)]")
        }
        
        let sideWidth:CGFloat = 6
        
        iconBack = DesignableView(frame: CGRectMake(sideWidth, sideWidth, self.frame.height * 0.75 - sideWidth * 2, self.frame.height * 0.75 - sideWidth * 2))
        self.addSubview(iconBack)
        addShadow(iconBack)
        addVisualEffectView(iconBack)
        icon = UIImageView(frame: CGRectMake(3, 3, iconBack.frame.width - 6, iconBack.frame.height - 6))
        iconBack.addSubview(icon)
        iconBackCenter = iconBack.center
        
        temperatureBack = DesignableView(frame: CGRectMake(sideWidth * 2 + iconBack.frame.width, iconBack.frame.width - self.frame.height * 0.2 + sideWidth, self.frame.height * 0.6, self.frame.height * 0.2))
        self.addSubview(temperatureBack)
        addShadow(temperatureBack)
        addVisualEffectView(temperatureBack)
        temperature = UILabel(frame: CGRectMake(3, 5, temperatureBack.frame.width - 6, temperatureBack.frame.height - 6))
        temperature.font = UIFont(name: "AvenirNextCondensed-Regular", size: 25)
        temperature.adjustsFontSizeToFitWidth = true
        temperature.textAlignment = NSTextAlignment.Center
        temperature.textColor = UIColor.darkGrayColor()
        temperatureBack.addSubview(temperature)
        temperatureBackCenter = temperatureBack.center

        cityBack = DesignableView(frame: CGRectMake(sideWidth, iconBack.frame.height + sideWidth * 2, iconBack.frame.width * 1.5, self.frame.height - iconBack.frame.height - 3 * sideWidth))
        self.addSubview(cityBack)
        addShadow(cityBack)
        addVisualEffectView(cityBack)
        city = UILabel(frame: CGRectMake(3, 3, cityBack.frame.width - 6, cityBack.frame.height - 6))
        city.font = UIFont(name: "AvenirNextCondensed-Medium", size: 22)
        city.textAlignment = NSTextAlignment.Center
        city.textColor = UIColor.darkGrayColor()
        cityBack.addSubview(city)
        cityBackCenter = cityBack.center
        
        weatherDescriptionBack = DesignableView(frame: CGRectMake(sideWidth * 2 + cityBack.frame.width, cityBack.frame.origin.y, self.frame.width - sideWidth * 3 - cityBack.frame.width, cityBack.frame.height))
        self.addSubview(weatherDescriptionBack)
        addShadow(weatherDescriptionBack)
        addVisualEffectView(weatherDescriptionBack)
        
        weatherDescription = UILabel(frame: CGRectMake(3, 3, weatherDescriptionBack.frame.width - 6, weatherDescriptionBack.frame.height - 6))
        weatherDescription.font = UIFont(name: "AvenirNextCondensed-Regular", size: 18)
        weatherDescription.textColor = UIColor.darkGrayColor()
        weatherDescription.textAlignment = NSTextAlignment.Center
        weatherDescriptionBack.addSubview(weatherDescription)
        weatherDescriptionBackCenter = weatherDescriptionBack.center
        
        smallImageBack = DesignableView(frame: CGRectMake(sideWidth + temperatureBack.frame.origin.x + temperatureBack.frame.width, sideWidth, self.frame.width - sideWidth * 2 - temperatureBack.frame.origin.x - temperatureBack.frame.width, temperatureBack.frame.height))
        //self.addSubview(smallImageBack)
        addShadow(smallImageBack)
        addVisualEffectView(smallImageBack)

        
    }
 
    func displayCity(cityID: String){
        
        if hide {
            hide = false
            
            let info: AnyObject? = WeatherInfo.citiesAroundDict[cityID]
            self.icon.image = UIImage(named: (((WeatherInfo.citiesAroundDict[cityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String)!
            
            var temp = ((info as! [String: AnyObject])["main"] as! [String: AnyObject])["temp"] as! Double
            temp = temp - 273
            let tempF = temp * 9 / 5 + 32
            self.temperature.text = "\(Int(temp))°C / \(Int(tempF))°F"
            self.city.text = (info as! [String: AnyObject])["name"] as? String
            println(self.city.text)
            self.weatherDescription.text = (((info as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["description"] as? String
            
            weatherDescriptionBack.center = weatherDescriptionBackCenter
            weatherDescriptionBack.animation = "slideLeft"
            weatherDescriptionBack.animate()
            cityBack.center = cityBackCenter
            cityBack.animation = "slideUp"
            cityBack.animate()
            iconBack.center = iconBackCenter
            iconBack.animation = "slideRight"
            iconBack.animate()
            temperatureBack.center = temperatureBackCenter
            temperatureBack.animation = "slideLeft"
            temperatureBack.animate()
            
        }else{
        
            iconBack.animation = "swing"
            iconBack.animate()
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.icon.alpha = 0
                self.temperature.alpha = 0
                self.city.alpha = 0
                self.weatherDescription.alpha = 0
                }) { (done) -> Void in
                    
                    let info: AnyObject? = WeatherInfo.citiesAroundDict[cityID]
                    self.icon.image = UIImage(named: (((WeatherInfo.citiesAroundDict[cityID] as! [String : AnyObject])["weather"] as! [AnyObject])[0] as! [String : AnyObject])["icon"] as! String)!
                    
                    var temp = ((info as! [String: AnyObject])["main"] as! [String: AnyObject])["temp"] as! Double
                    temp = temp - 273
                    let tempF = temp * 9 / 5 + 32
                    self.temperature.text = "\(Int(temp))°C / \(Int(tempF))°F"
                    self.city.text = (info as! [String: AnyObject])["name"] as? String
                    self.weatherDescription.text = (((info as! [String: AnyObject])["weather"] as! [AnyObject])[0] as! [String: AnyObject])["description"] as? String
                    
                    UIView.animateWithDuration(0.4, animations: { () -> Void in
                        self.icon.alpha = 1
                        self.temperature.alpha = 1
                        self.city.alpha = 1
                        self.weatherDescription.alpha = 1
                        }) { (done) -> Void in
                    }
            }
        }
    }
    
    func addVisualEffectView(view: UIView){
        var effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        effectView.frame = view.bounds
        view.addSubview(effectView)
    }
    
    func addShadow(view: UIView){
        view.layer.shadowOffset = CGSizeMake(0, 1);
        view.layer.shadowRadius = 0.5;
        view.layer.shadowOpacity = 0.3;
    }
    
    func hideSelf(){

        if !hide {
            hide = true
            weatherDescriptionBack.center = CGPointMake(weatherDescriptionBack.center.x + weatherDescriptionBack.frame.width * 1.5, weatherDescriptionBack.center.y)
            weatherDescriptionBack.animation = "slideLeft"
            weatherDescriptionBack.animate()
            
            cityBack.center = CGPointMake(cityBack.center.x, cityBack.center.y + cityBack.frame.height * 1.5)
            cityBack.animation = "slideUp"
            cityBack.animate()
            
            iconBack.center = CGPointMake(iconBack.center.x - iconBack.frame.width * 1.5 , iconBack.center.y)
            iconBack.animation = "slideRight"
            iconBack.animate()
            
            temperatureBack.center = CGPointMake(temperatureBack.center.x + temperatureBack.frame.width * 3.5, temperatureBack.center.y)
            temperatureBack.animation = "slideLeft"
            temperatureBack.animate()
        }
    }
    
    // movement  0 - 200
    func moveAccordingToDrag(movement:CGFloat){
        self.transform = CGAffineTransformMakeTranslation(0, movement)
    }

}
