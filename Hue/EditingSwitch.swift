//
//  EditingSwitch.swift
//  HUE
//
//  Created by James Taylor on 2015-03-25.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class EditingSwitch: UIControl {

    var on: Bool {
        didSet {
            self.update()
            self.sendActionsForControlEvents(.ValueChanged)
        }
    }
    var titleLabel: UILabel
    
    // mutable constraints
    var titleLabelLeftConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        
        self.on = false
        self.titleLabel = UILabel()
        
        super.init(frame: frame)
        self.clipsToBounds = true
        
        self.titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.titleLabel.text = "edit"
        self.titleLabel.font = UIFont(name: "GillSans", size: 18)
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.textAlignment = .Right
        
        self.addSubview(self.titleLabel)
        
        // titleLabel constraints
        self.titleLabelLeftConstraint = NSLayoutConstraint(item: self.titleLabel, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
        self.addConstraint(self.titleLabelLeftConstraint)
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        
        // gestures
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        self.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Handlers
    func update() {
        
        // title label
        var startingText: String
        var finishedText: String
        var leftConstraint: CGFloat
        
        if self.on {
            leftConstraint = -20
            startingText = "editing"
            finishedText = "editing"
        } else {
            leftConstraint = 0
            startingText = "edit"
            finishedText = "edit"
        }
        
        self.titleLabel.text = startingText
        self.titleLabelLeftConstraint.constant = leftConstraint
        self.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            
            self.layoutIfNeeded()
            
        }, completion: { finished in
            
            self.titleLabel.text = finishedText
            
        })
        
    }
    
    // MARK: - Handlers
    
    func handleSingleTap(sender: UITapGestureRecognizer) {
        self.on = !self.on
    }
    
}
