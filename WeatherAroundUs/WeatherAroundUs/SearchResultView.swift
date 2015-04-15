//
//  SearchResultView.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/14.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Alamofire

class SearchResultView: UIImageView, SearchInformationDelegate{
    
    var parentController: ViewController!
    
    var resultList = [UIButton]()
    var placeIDList = [String]()
    
    let theHeight: CGFloat = 20
    let maxCity: Int = 12
    
    var timer = NSTimer()
    var timeCount = 0
    
    
    func addACity(placeID: String, description: String){
        
        //add a card
        let aCity = UIButton(frame: CGRectMake(4, (theHeight + 4) * CGFloat(resultList.count), self.frame.width - 8, theHeight))
        aCity.alpha = 0
        aCity.addTarget(self, action: "chooseCity:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(aCity)
        resultList.insert(aCity, atIndex: 0)
        placeIDList.insert(placeID, atIndex: 0)
        
        var lab = UILabel(frame: aCity.bounds)
        lab.font = UIFont(name: "Slayer", size: 11)
        lab.text = description
        lab.textColor = UIColor(red: 186/255.0, green: 128/255.0, blue: 82/255.0, alpha: 1)
        aCity.addSubview(lab)
        
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.alpha = 1
            aCity.alpha = 0.8
            
            }, completion: { (finish) -> Void in
                self.timeCount = 0
                self.timer = NSTimer.scheduledTimerWithTimeInterval(25, target: self, selector: "startCounting", userInfo: nil, repeats: true)
        })
        
        // change size
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.frame.size = CGSizeMake(self.frame.width, (self.theHeight + 4) * CGFloat(self.resultList.count))
        })
        
    }
    
    func startCounting(){
        if timeCount < 8{
            timeCount++
        }else{
            
            removeCities()
            timer.invalidate()
            timeCount = 0
        }
    }
    
    func chooseCity(sender: UIButton){
        
        let placeid = placeIDList[find(resultList, sender)!]
        
        var req = Alamofire.request(.GET, NSURL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeid)&key=AIzaSyDHwdGU463x3_aJfg4TNWm0fijTjr9VEdg")!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                
                let result = JSON as! [String : AnyObject]
                let position = CLLocationCoordinate2DMake((((result["result"] as! [String : AnyObject])["geometry"] as! [String : AnyObject])["location"] as! [String : AnyObject])["lat"] as! Double, (((result["result"] as! [String : AnyObject])["geometry"] as! [String : AnyObject])["location"] as! [String : AnyObject])["lng"] as! Double)
                WeatherInfo.getLocalWeatherInformation(position, number: 10)
                self.parentController.mapView.animateToLocation(position)

            }
            
        }
        removeCities()
    }
    
    func removeCities(){
        
        for var index:Int = 0; index < resultList.count; index++ {
            let temp = resultList[index]
            temp.removeFromSuperview()
        }
        
        resultList.removeAll(keepCapacity: false)
        placeIDList.removeAll(keepCapacity: false)
        
        // change size
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.frame.size = CGSizeMake(self.frame.width, 0)
        })
    }
    
}
