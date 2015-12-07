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

class DayHeader: UIView {
    /**
     The date the header will display.
     Changing this property triggers an automatic update to the header's appearance.
     */
    var date: NSDate? {
        didSet {
            update()
        }
    }
    
    private let label = UILabel()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Configure the day label
        label.font = UIFont(name: "GillSans", size: 18)
        label.textAlignment = .Left
        label.textColor = UIColor.whiteColor()
        label.text = "Hello"
        
        backgroundColor = UIColor(white: 0.1, alpha: 1)
        addSubview(label)
        setupConstraints()
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    /**
     Setup the initial constraints for the header. This method should only be called once on initialization.
     */
    private func setupConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 4).active = true
        label.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        label.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        label.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
    }
    
    /**
     Update the header. This method is triggered after an update to the date property.
     */
    private func update() {
        guard let date = self.date else {
            return
        }
        
        // TODO: There should be a better way..
        var text: String
        let secondsPassed = Int(NSDate().timeIntervalSinceDate(date))
        switch secondsPassed {
            case 0..<SECONDS_IN_A_DAY:
                text = "today"
            case SECONDS_IN_A_DAY..<SECONDS_IN_TWO_DAYS:
                text = "yesterday"
            default:
                let dateComponents = NSCalendar.currentCalendar().components([.Day, .Month, .Year], fromDate: date)
                text = "\(dateComponents.day)/\(dateComponents.month)/\(dateComponents.year)"
        }
        
        label.text = text
    }
}
