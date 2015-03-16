//
//  FocusingIndicator.swift
//  Hue
//
//  Created by James Lin Taylor on 2015-03-16.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class FocusingIndicator: UIView {

    var isDisplayingFocused: Bool
    var isDisplayingFocusing: Bool
    
    override init() {
        
        self.isDisplayingFocused = false
        self.isDisplayingFocusing = false
        
        super.init(frame: CGRect(origin: CGPointZero, size: CGSize(width: 80, height: 80)))
        
        self.layer.cornerRadius = 40
        self.backgroundColor = UIColor.whiteColor()
        self.alpha = 0.5
        
    }

    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    deinit {
        
        NSLog("Focusing Indicator deinitialized")
        
    }
    
    // Mark: Public methods
    
    func startFocusingAnimation() {
        
        self.isDisplayingFocusing = true
        
        UIView.animateKeyframesWithDuration(4, delay: 0.0, options: UIViewKeyframeAnimationOptions.Repeat, animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.2, animations: {
                
                self.alpha = 0.8
                self.transform = CGAffineTransformMakeScale(1.4, 1.4)
                
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.2, relativeDuration: 3.8, animations: {
                
                self.transform = CGAffineTransformMakeScale(0.8, 0.8)
                
            })
            
        }, completion: { (finished) -> Void in
            
            
        })
            
        
    }
    
    func startFocusedAnimation() {
        
        self.isDisplayingFocusing = false
        self.isDisplayingFocused = true
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            self.alpha = 0.1
            self.transform = CGAffineTransformMakeScale(0.4, 0.4)
            
        }, completion: { (finished) -> Void in
            
            
        })
        
    }
    
    func shouldRemoveAnimated(animated: Bool) {
        
        if animated {
        
            UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
                
                self.alpha = 0.0
                
            }, completion: { (finished) -> Void in
            
                self.removeFromSuperview()
                    
            })
        
        } else {
            
            self.removeFromSuperview()
            
        }
            
    }
    
}
