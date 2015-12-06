//
//  SampleView.swift
//  HUE
//
//  Created by James Taylor on 2015-03-24.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class SampleView: UIView, UIGestureRecognizerDelegate {

    // TODO: Listeners are great but I seem to have abused them here.
    var color: UIColor? {
        didSet {
            
            let complimentaryColor = color?.complimentaryColor()
            
            self.backgroundColor = self.color
            self.colorBorder.backgroundColor = complimentaryColor
            let currentMode = self.supportedModes[self.modeIndex]
            self.colorLabel.text = currentMode.descriptionForColor(color)
            self.colorLabel.textColor = complimentaryColor
            
        }
    }
    
    var supportedModes: [ColorFormat] = [.HSB, .RGB, .HEX]
    var modeIndex: Int = 0 {
        didSet {
            let currentMode = supportedModes[modeIndex]
            self.colorLabel.text = currentMode.descriptionForColor(color)
        }
    }
    
    var locked: Bool = false {
        didSet {
            self.userInteractionEnabled = !self.locked
            self.colorLabel.alpha = CGFloat(!self.locked)
        }
    }
    
    var colorBorder: UIView
    var colorLabel: UILabel
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        
        self.colorBorder = UIView()
        self.colorLabel = UILabel()
        
        super.init(frame: frame)
        
        self.colorBorder.frame.size = CGSize(width: 0, height: 1)
        self.colorBorder.translatesAutoresizingMaskIntoConstraints = true
        self.colorBorder.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        self.colorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.colorLabel.font = UIFont(name: "GillSans-Italic", size: 26)
        self.colorLabel.userInteractionEnabled = true
        self.colorLabel.textAlignment = .Center
        
        self.addSubview(self.colorBorder)
        self.addSubview(self.colorLabel)

        // color label constraints
        self.addConstraint(NSLayoutConstraint(item: self.colorLabel, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.colorLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.colorLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        
        // gestures
        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeLeftGestureRecognizer.direction = .Left
        swipeLeftGestureRecognizer.delegate = self
        let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeRightGestureRecognizer.direction = .Right
        swipeRightGestureRecognizer.delegate = self
        
        self.addGestureRecognizer(swipeLeftGestureRecognizer)
        self.addGestureRecognizer(swipeRightGestureRecognizer)
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    func animateLabelChange(direction: UISwipeGestureRecognizerDirection) {
        // Create a copy of the current label and add it to the view.
        guard let copy = colorLabel.copy() as? UILabel else {
            return
        }
        addSubview(copy)
        
        // Translate the real label to the initial point of it's animation.
        let dx: CGFloat = direction == .Left ? 80.0 : -80.0
        colorLabel.transform = CGAffineTransformMakeTranslation(dx, 0)
        colorLabel.alpha = 0.0
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.2, options: [], animations: {
            // Translate the real label into position
            self.colorLabel.transform = CGAffineTransformIdentity
            self.colorLabel.alpha = 1.0
            
            // Translate the temporary copied label out of position
            copy.transform = CGAffineTransformMakeTranslation(-dx/2, 0)
            copy.alpha = 0.0
        }, completion: { finished in
            // Clean up by removing the temporary copied label
            copy.removeFromSuperview()
        })
    }
    
    // MARK: - Handlers
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Left:
            modeIndex = (modeIndex + 1) % self.supportedModes.count
        default:
            // Simulate modulo behaviour since Swift's % operator calculates remainder.
            modeIndex = modeIndex - 1 < 0 ? self.supportedModes.count - 1 : modeIndex - 1
        }
        
        animateLabelChange(sender.direction)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}
