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
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.layer.cornerRadius = 40
        self.layer.borderWidth = 1
        
        self.setImage(UIImage(named: "CameraIcon")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
    }
    
    override convenience init() {
        self.init(frame: CGRectZero)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func setBackgroundColor(color: UIColor?, forControlState controlState: UIControlState) {
        self.backgroundColors[UIControlStateKey(controlState: controlState)] = color
    }
    
    func updateWithColor(color: UIColor?) {
        
        let complimentaryColor = color?.complimentaryColor()
        self.layer.borderColor = complimentaryColor?.CGColor
        self.backgroundColor = self.state == .Normal ? color : complimentaryColor
        self.imageView?.tintColor = complimentaryColor
        
    }
    
    // MARK: - Private Methods
    
    func updateBackgroundColor() {
     
        if let color = self.backgroundColors[UIControlStateKey(controlState: self.state)] {
            self.backgroundColor = color
        }
   
    }
    
    // MARK: - Handlers
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
     
        super.touchesBegan(touches, withEvent: event)
        
        self.updateBackgroundColor()
        self.layer.transform = CATransform3DMakeScale(0.95, 0.95, 1)
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
    
        super.touchesEnded(touches, withEvent: event)
        
        self.updateBackgroundColor()
        self.layer.transform = CATransform3DIdentity
   
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
      
        super.touchesCancelled(touches, withEvent: event)
    
        self.updateBackgroundColor()
        self.layer.transform = CATransform3DIdentity

    }
}
