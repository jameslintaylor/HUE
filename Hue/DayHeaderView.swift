//
//  SamplesHeaderView.swift
//  HUE
//
//  Created by James Taylor on 2015-03-24.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

let SECONDS_IN_A_DAY = 86400
let SECONDS_IN_TWO_DAYS = SECONDS_IN_A_DAY*2

class DayHeaderView: UIView {

    var ddMMyyyy: String? {
        didSet {
            self.update()
        }
    }
    var dayLabel: UILabel
    
    override init(frame: CGRect) {
        
        self.dayLabel = UILabel()
        
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        
        self.dayLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.dayLabel.font = UIFont(name: "GillSans", size: 18)
        self.dayLabel.textAlignment = .Left
        self.dayLabel.textColor = UIColor.whiteColor()
        
        self.addSubview(self.dayLabel)
        
    }

    convenience override init() {
        self.init(frame: CGRectZero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

    override func updateConstraints() {
        
        super.updateConstraints()
        
        // dayLabel constraints
        self.addConstraint(NSLayoutConstraint(item: self.dayLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 8))
        self.addConstraint(NSLayoutConstraint(item: self.dayLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.dayLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.dayLabel, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
    }
    
    // MARK: - Private Methods
    
    func update() {

        if self.ddMMyyyy == nil {
            return
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd:MM:yyyy"
        if let date = dateFormatter.dateFromString(self.ddMMyyyy!) {
            
            var text: String
        
            let secondsPassed = Int(NSDate().timeIntervalSinceDate(date))
            switch secondsPassed {
                
            case 0..<SECONDS_IN_A_DAY:
                text = "today"
                
            case SECONDS_IN_A_DAY..<SECONDS_IN_TWO_DAYS:
                text = "yesterday"
                
            default:
                let dateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit, fromDate: date)
                text = "\(dateComponents.day)/\(dateComponents.month)/\(dateComponents.year)"
            }
            
            self.dayLabel.text = text
        }
        
    }
    
}
