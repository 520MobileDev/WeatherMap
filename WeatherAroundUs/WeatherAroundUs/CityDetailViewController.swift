//
//  CityDetailViewController.swift
//  WeatherAroundUs
//
//  Created by Wang Yu on 4/23/15.
//  Copyright (c) 2015 Kedan Li. All rights reserved.
//

import UIKit
import Spring
import Shimmer

class CityDetailViewController: UIViewController, ImageCacheDelegate, UIScrollViewDelegate, MotionManagerDelegate{

    @IBOutlet var backgroundImageView: UIScrollView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mainTemperatureShimmerView: FBShimmeringView!
    
    @IBOutlet var switchWeatherUnitButton: UIButton!
    @IBOutlet var mainTemperatureDisplay: UILabel!
    @IBOutlet var dateDisplayLabel: UILabel!
    @IBOutlet var mainTempatureToTopHeightConstraint: NSLayoutConstraint!
    @IBOutlet var basicForecastViewHeight: NSLayoutConstraint!
    
    @IBOutlet var detailWeatherView: DetailWeatherView!
    @IBOutlet var digestWeatherView: DigestWeatherView!
    @IBOutlet var forecastView: BasicWeatherView!

    var isFnotC = NSUserDefaults.standardUserDefaults().objectForKey("temperatureDisplay")!.boolValue!

    var tempImage: UIImage!
    
    var cityID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        forecastView.parentController = self
        digestWeatherView.parentController = self
        detailWeatherView.parentController = self
        
        mainTempatureToTopHeightConstraint.constant = view.frame.height / 3
        mainTemperatureShimmerView.contentView = mainTemperatureDisplay
        mainTemperatureShimmerView.shimmering = true

        forecastView.clipsToBounds = true
        digestWeatherView.clipsToBounds = true
        detailWeatherView.clipsToBounds = true
        
        if isFnotC == true {
            mainTemperatureDisplay.text = "°F"
        } else {
            mainTemperatureDisplay.text = "°C"

        }
    }
    
    
    // have to override function to manipulate status bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        backgroundImageView.image = tempImage
        setBackgroundImage()
        switchWeatherUnitButton.addTarget(self, action: "switchWeatherUnitButtonDidPressed", forControlEvents: UIControlEvents.TouchUpInside)
        
        UserMotion.delegate = self
        UserMotion.start()
    
    }
    
    override func viewDidAppear(animated: Bool) {
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height / 3 + basicForecastViewHeight.constant + digestWeatherView.frame.height + detailWeatherView.frame.height + 250)
        
        let nineDayWeatherForcast = WeatherInfo.citiesForcast[cityID] as! [[String: AnyObject]]
        forecastView.setup(nineDayWeatherForcast)
        digestWeatherView.setup(nineDayWeatherForcast)
        detailWeatherView.setup(nineDayWeatherForcast)

        
        var currDate = NSDate()
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        let dateStr = dateFormatter.stringFromDate(currDate)
        dateDisplayLabel.text = dateStr

        switchWeatherUnitButtonDidPressed()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -90 {
            self.performSegueWithIdentifier("backToMain", sender: self)
        }
    }
    
    func setBackgroundImage() {
        let imageDict = ImageCache.imagesUrl
        let imageUrl = imageDict[cityID]!
        var cache = ImageCache()
        cache.delegate = self
        cache.getImageFromCache(imageUrl, cityID: cityID)
    }
    
    func degreeConvert(degree: Int32) -> Int32 {
        if isFnotC {
            return degree - 273
        } else {
            return Int32(round(Double(Double(degree) - 273.13) * 9.0 / 5.0 + 32))
        }
    }
    
    func switchWeatherUnitButtonDidPressed() {

        NSUserDefaults.standardUserDefaults().setBool(isFnotC, forKey: "temperatureDisplay")
        NSUserDefaults.standardUserDefaults().synchronize()

        isFnotC = !isFnotC
        
        let todayDegree = (((WeatherInfo.citiesForcast[cityID] as! [[String: AnyObject]])[0]["temp"] as! [String: AnyObject])["day"])!.intValue
        if isFnotC {
            mainTemperatureDisplay.text = "\(degreeConvert(todayDegree))°C"
        } else {
            mainTemperatureDisplay.text = "\(degreeConvert(todayDegree))°F"
        }
        let nineDayWeatherForcast = WeatherInfo.citiesForcast[cityID] as! [[String: AnyObject]]
        digestWeatherView.reloadTemperature(nineDayWeatherForcast)
        forecastView.reloadTempatureContent()
        detailWeatherView.reloadTempatureContent(nineDayWeatherForcast)
    }
    
    func gotImageFromCache(image: UIImage, cityID: String) {
        backgroundImageView.image = image
    }
    
    func gotAttitudeRoll(roll: CGFloat) {
        println(roll)
    }
}
