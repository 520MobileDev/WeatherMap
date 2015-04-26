//
//  DetailWeatherView.swift
//  WeatherAroundUs
//
//  Created by Wang Yu on 4/25/15.
//  Copyright (c) 2015 Kedan Li. All rights reserved.
//

import UIKit

class DetailWeatherView: UIView {
    
    var parentController: CityDetailViewController!
    
    @IBOutlet var line: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(forecastInfos: [[String: AnyObject]]) {
        var beginY = line.frame.origin.y + line.frame.height + 5
        let blockHeight: CGFloat = 18
        let spaceHeight: CGFloat = 5

        let windSpeed = (forecastInfos[0] as [String: AnyObject])["speed"] as! Int
        let windDirection = (forecastInfos[0] as [String: AnyObject])["deg"] as! Int
        var windDirectionStr: String = ""
        if windDirection < 90 {
            windDirectionStr = "\(windDirection)° NE"
        } else if windDirection < 180 {
            windDirectionStr = "\(windDirection-90)° NW"
        } else if windDirection < 270 {
            windDirectionStr = "\(windDirection-180)° SW"
        } else {
            windDirectionStr = "\(windDirection-270)° SE"
        }
        var unit: String = "F"
        if parentController.isCnotF {
            unit = "C"
        }
        createTwoUILabelInMiddle("Wind Speed:", secondString: "\(windSpeed) mps", yPosition: beginY)
        beginY += blockHeight
        createTwoUILabelInMiddle("Wind Direction:", secondString: windDirectionStr, yPosition: beginY)
        beginY += blockHeight + spaceHeight
        let clouds = (forecastInfos[0] as [String: AnyObject])["speed"] as! Int
        createTwoUILabelInMiddle("Cloudiness:", secondString: "\(clouds) %", yPosition: beginY)
        beginY += blockHeight
        let chanceOfRain = (forecastInfos[0] as [String: AnyObject])["rain"] as? Double
        var chanceOfRainStr = "Yet updated"
        if chanceOfRain != nil {
            chanceOfRainStr = "\(chanceOfRain! * 100) %"
        }
        createTwoUILabelInMiddle("Chance of Rain:", secondString: chanceOfRainStr, yPosition: beginY)
        beginY += blockHeight + spaceHeight
        let humanity = (forecastInfos[0] as [String: AnyObject])["humidity"] as! Int
        createTwoUILabelInMiddle("Humanity:", secondString: "\(humanity) %", yPosition: beginY)
        beginY += blockHeight
        let pressure = (forecastInfos[0] as [String: AnyObject])["pressure"] as! Int
        createTwoUILabelInMiddle("Pressure:", secondString: "\(pressure) hPa", yPosition: beginY)
        beginY += blockHeight + spaceHeight
        let mornTemperature = ((forecastInfos[0]["temp"] as! [String: AnyObject])["morn"])!.intValue
        createTwoUILabelInMiddle("Morn Temp:", secondString: "\(parentController.degreeConvert(mornTemperature)) °" + unit, yPosition: beginY)
        beginY += blockHeight
        let nightTemperature = ((forecastInfos[0]["temp"] as! [String: AnyObject])["night"])!.intValue
        createTwoUILabelInMiddle("Niehgt Temp:", secondString: "\(parentController.degreeConvert(nightTemperature)) °" + unit, yPosition: beginY)

    }
    
    func createTwoUILabelInMiddle(firstStirng: String, secondString: String, yPosition: CGFloat) {
        let labelHeight: CGFloat = 20
        let xPostion = line.frame.origin.x
 
        var leftLabel = UILabel(frame: CGRectMake(xPostion, yPosition, line.frame.width / 2, labelHeight))
        var rightLabel = UILabel(frame: CGRectMake(xPostion + line.frame.width / 2 + 20, yPosition, line.frame.width / 2, labelHeight))
        leftLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
        rightLabel.font = leftLabel.font
        leftLabel.textColor = UIColor.whiteColor()
        rightLabel.textColor = leftLabel.textColor
        leftLabel.textAlignment = .Right
        rightLabel.textAlignment = .Left
        leftLabel.text = firstStirng
        rightLabel.text = secondString
        self.addSubview(leftLabel)
        self.addSubview(rightLabel)
    }
}
