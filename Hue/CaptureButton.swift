//
//  CaptureButton.swift
//  HUE
//
//  Created by James Taylor on 2015-03-30.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

enum UIControlStateKey {
    
    case Normal, Highlighted, Other
    
    init(controlState: UIControlState) {
        
        switch controlState {
            
        case UIControlState.Normal:
            self = .Normal
            
        case UIControlState.Highlighted:
            self = .Highlighted
            
        default:
            self = .Other
            
        }
        
    }
    
}

class CaptureButton: UIButton {
    
    var backgroundColors = [UIControlStateKey: UIColor?]()
    var outerRing = CALayer()
    var innerCircle = CALayer()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        self.outerRing.borderWidth = 6
        self.outerRing.borderColor = UIColor(white: 1, alpha: 1).CGColor
        
        self.layer.addSublayer(self.outerRing)
        self.layer.addSublayer(self.innerCircle)
        
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        self.layer.cornerRadius = self.bounds.width/2
        
        self.outerRing.frame = self.bounds
        self.outerRing.cornerRadius = self.outerRing.bounds.width/2
        
        self.innerCircle.frame = CGRectInset(self.bounds, self.outerRing.borderWidth + 2, self.outerRing.borderWidth + 2)
        self.innerCircle.cornerRadius = self.innerCircle.bounds.width/2
        
    }
    
    // MARK: - Public Methods
    
    func setBackgroundColor(color: UIColor?, forControlState controlState: UIControlState) {
        self.backgroundColors[UIControlStateKey(controlState: controlState)] = color
        self.updateBackgroundColor()
    }
    
    func updateWithColor(color: UIColor?) {
        let complimentaryColor = color?.complimentaryColor()
        self.imageView?.tintColor = complimentaryColor
    }
    
    // MARK: - Private Methods
    
    func updateBackgroundColor() {
     
        if let color = self.backgroundColors[UIControlStateKey(controlState: self.state)] {
            self.innerCircle.backgroundColor = color?.CGColor
        }
   
    }
    
    // MARK: - Handlers
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
     
        super.touchesBegan(touches, withEvent: event)
        
        self.updateBackgroundColor()
        self.layer.transform = CATransform3DMakeScale(0.95, 0.95, 1)
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    
        super.touchesEnded(touches, withEvent: event)
        
        self.updateBackgroundColor()
        self.layer.transform = CATransform3DIdentity
   
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
      
        super.touchesCancelled(touches, withEvent: event)
    
        self.updateBackgroundColor()
        self.layer.transform = CATransform3DIdentity

    }
}
