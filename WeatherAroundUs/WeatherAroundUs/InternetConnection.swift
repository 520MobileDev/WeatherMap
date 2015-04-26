//
//  InternetSearch.swift
//  WeatherAroundUs
//
//  Created by Kedan Li on 15/4/11.
//  Copyright (c) 2015年 Kedan Li. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

@objc protocol InternetConnectionDelegate: class {
    optional func gotCityNameAutoComplete(cities: [AnyObject])
    optional func gotImageUrls(btUrl: String, imageURL: String, cityID: String)
    optional func gotLocalCityWeather(cities: [AnyObject])
    optional func gotLocationWithPlaceID(location: CLLocationCoordinate2D)
    optional func gotWeatherForcastData(cityID: String, forcast:[AnyObject])
    optional func gotThreeHourForcastData(cityID: String, forcast:[AnyObject])
}

var connectionCount: Int = 0

class InternetConnection: NSObject {
    
    let apiKey = "ee87492c2987b4f04895330984934350"

    var delegate : InternetConnectionDelegate?
    
    var passData: [String: AnyObject]!
    
    // search city name using google framework
    func searchCityName(content:String){
        
        // avoid crash when there is space
        //handle case when there is chinese
        var searchContent = content.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(searchContent)&types=(cities)&language=en&key=AIzaSyDHwdGU463x3_aJfg4TNWm0fijTjr9VEdg")
        
        var req = Alamofire.request(.GET, url!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                let myjson = SwiftyJSON.JSON(JSON!)
                var predictions = myjson["predictions"].arrayObject
                if predictions != nil{
                    self.delegate?.gotCityNameAutoComplete!(predictions!)
                }
            }else{
                //resend
                self.searchCityName(content)
            }
            
        }
        
    }
    
    //search for local weather data
    func getLocalWeather(location: CLLocationCoordinate2D, number:Int){
        
        connectionCount++
        var req = Alamofire.request(.GET, NSURL(string: "http://api.openweathermap.org/data/2.5/find?lat=\(location.latitude)&lon=\(location.longitude)&cnt=\(number)&mode=json")!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                let myjson = SwiftyJSON.JSON(JSON!)
                if let data = myjson["list"].arrayObject{
                    self.delegate?.gotLocalCityWeather!(data)
                }
            }else{
                self.getLocalWeather(location, number: number)
            }
            connectionCount--
        }
    }
    
    // search for location with placeid
    func getLocationWithPlaceID(placeid: String){
        
        var req = Alamofire.request(.GET, NSURL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeid)&key=AIzaSyDHwdGU463x3_aJfg4TNWm0fijTjr9VEdg")!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                
                let myjson = SwiftyJSON.JSON(JSON!)
                let lat = myjson["result"]["geometry"]["location"]["lat"].doubleValue
                let long = myjson["result"]["geometry"]["location"]["lng"].doubleValue
                
                self.delegate?.gotLocationWithPlaceID!(CLLocationCoordinate2DMake(lat, long))
                
            }else{
                //resend
                self.getLocationWithPlaceID(placeid)
            }
        }
        
    }
    
    
    //searh url with flicker
    func flickrSearch(location: CLLocationCoordinate2D, name: String, cityID: String){
        var searchText = "https://api.flickr.com/services/rest/?accuracy=11&api_key=\(apiKey)&per_page=10&lat=\(location.latitude)&lon=\(location.longitude)&method=flickr.photos.search&sort=interestingness-desc&tags=scenic,landscape,city&format=json&nojsoncallback=1"
        searchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        var req = Alamofire.request(.GET, NSURL(string: searchText)!).responseJSON { (_, response, JSON, error) in

            if error == nil && JSON != nil {
                
                let myjson = SwiftyJSON.JSON(JSON!)
                
                let id = myjson["photos"]["photo"][0]["id"].string
                self.searchPhotoID(id!, cityID: cityID)
                
            }else{
                //resend
                self.searchForCityPhotos(location , name: name, cityID: cityID)
            }
        }

    }
    
    // get image url of sizes
    func searchPhotoID(photoID: String, cityID: String){
        
        var searchText = "https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=\(apiKey)&photo_id=\(photoID)&format=json&nojsoncallback=1"
        searchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        var req = Alamofire.request(.GET, NSURL(string: searchText)!).responseJSON { (_, response, JSON, error) in

            if error == nil && JSON != nil {
                
                let myjson = SwiftyJSON.JSON(JSON!)
                
                let tbUrl = myjson["sizes"]["size"][1]["source"].string
                let arr = myjson["sizes"]["size"].arrayObject!//["source"].string
                let imageUrl = myjson["sizes"]["size"][arr.count - 1]["source"].string
                
                ImageCache.smallImagesUrl.updateValue(tbUrl!, forKey: cityID)
                ImageCache.imagesUrl.updateValue(imageUrl!, forKey: cityID)
                self.delegate?.gotImageUrls!(tbUrl!, imageURL: imageUrl!, cityID: cityID)
                
            }else{
                //resend
                self.searchPhotoID(photoID, cityID: cityID)
            }
        }
        
    }
    
    // get small city image
    func googleSearch(location: CLLocationCoordinate2D, name: String, cityID: String){
        
        var geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(location) { (response, error) -> Void in
            
            if error == nil && response != nil{
                
                
                let address = response!.results()[0] as! GMSAddress
                
                var searchText = ""
                
                if address.subLocality != nil{
                    
                    if address.locality != nil{
                        searchText = address.subLocality + " " + address.locality
                    }else if address.administrativeArea != nil{
                        searchText = address.subLocality + " " + address.administrativeArea
                    }else{
                        searchText = address.subLocality + " " + address.country
                    }
                    
                }else if address.locality != nil{
                    if address.administrativeArea != nil{
                        searchText = address.locality + " " + address.administrativeArea
                    }else{
                        searchText = address.locality + " " + address.country
                    }
                }else if address.administrativeArea != nil{
                    searchText = address.administrativeArea + " " + address.country
                }else{
                    searchText = address.country
                }
                searchText = searchText + " -human -people -crowd -person"
                // avoid error when there is space
                searchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                self.getPictureURLOfACity(searchText, cityID: cityID)
                
            }else{
                //resend
                self.googleSearch(location, name: name, cityID: cityID)
            }
        }
    }
    
    func getPictureURLOfACity(searchText: String, cityID: String){
        
        let url = NSURL(string: "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=\(searchText)&imgtype=photo&imgsz=xxlarge%7Chuge&imgc=color&hl=en")!
        // request for the image
        var req = Alamofire.request(.GET, url).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                var tbUrl = ""
                var imageUrl = ""
                let myjson = SwiftyJSON.JSON(JSON!)
                if let data = myjson["responseData"]["results"].array{
                    for url in data {
                        //search for wiki result first
                        if url.description.rangeOfString("wikipedia") != nil{
                            
                            if let url =  url["tbUrl"].string
                            {
                                
                                tbUrl = url
                            }
                            
                            if let url = url["unescapedUrl"].string{
                                
                                imageUrl = url
                            }
                            
                            break;
                        }
                    }
                    
                }
                
                if tbUrl == ""{
                    // get the first result if there is no wiki result
                    if let url =  myjson["responseData"]["results"][0]["tbUrl"].string{
                        tbUrl = url
                    }
                    if let url = myjson["responseData"]["results"][0]["unescapedUrl"].string{
                        imageUrl = url
                    }
                }
                // save image in local
                ImageCache.smallImagesUrl.updateValue(tbUrl, forKey: cityID)
                ImageCache.imagesUrl.updateValue(imageUrl, forKey: cityID)
                self.delegate?.gotImageUrls!(tbUrl, imageURL: imageUrl, cityID: cityID)
                
            }else{
                //resend
                self.getPictureURLOfACity(searchText, cityID: cityID)
            }
        }
    }
    
    
    func getWeatherForcast(cityID: String){
        var req = Alamofire.request(.GET, NSURL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?id=\(cityID)&cnt=9")!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                let myjson = SwiftyJSON.JSON(JSON!)
                let list = myjson["list"].arrayObject
                if list != nil && list!.count == 9 {
                    self.delegate?.gotWeatherForcastData!(cityID, forcast:list!)
                }else{
                    //resend
                    self.getWeatherForcast(cityID)
                }
                
            }else{
               //resend
                self.getWeatherForcast(cityID)
            }
        }
    }
    
    func getThreeHourForcast(cityID: String){
        
        var req = Alamofire.request(.GET, NSURL(string: "http://api.openweathermap.org/data/2.5/forecast?id=\(cityID)")!).responseJSON { (_, response, JSON, error) in
            
            if error == nil && JSON != nil {
                let myjson = SwiftyJSON.JSON(JSON!)
                let list = myjson["list"].arrayObject
                if list != nil{
                    self.delegate?.gotThreeHourForcastData!(cityID, forcast:list!)
                }else{
                    //resend
                    self.getThreeHourForcast(cityID)
                }
                
            }else{
                //resend
                self.getThreeHourForcast(cityID)
            }
        }
    }

    
    // get image info
    func searchForCityPhotos(location: CLLocationCoordinate2D, name: String, cityID: String){
        
        //override cities to use google
        let cities = ["4914570","4887158","4887163","1795565","6942880"]
        if find(cities, cityID) > 0{
            googleSearch(location, name: name, cityID: cityID)
        }else{
            flickrSearch(location, name: name, cityID: cityID)
        }
        
    }
    
    
}

