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
    
    var microPrism: CALayer
    var splitImage: CAShapeLayer
    
    override init() {
        
        self.isDisplayingFocused = false
        self.isDisplayingFocusing = false
    
        self.microPrism = CALayer()
        self.splitImage = CAShapeLayer()
        
        super.init(frame: CGRect(origin: CGPointZero, size: CGSize(width: 80, height: 80)))
        
        self.microPrism.frame = self.bounds
        self.microPrism.cornerRadius = self.bounds.width/2
        self.microPrism.backgroundColor = UIColor.whiteColor().CGColor
        
        self.splitImage.frame = self.bounds
        var splitPath = UIBezierPath(ovalInRect: CGRectInset(self.bounds, 15, 15))
        splitPath.moveToPoint(CGPoint(x: 15, y: self.bounds.height/2))
        splitPath.addLineToPoint(CGPoint(x: self.bounds.width - 15, y: self.bounds.height/2))
        self.splitImage.path = splitPath.CGPath
        self.splitImage.fillColor = UIColor(white: 0.9, alpha: 1).CGColor
        self.splitImage.strokeColor = self.microPrism.backgroundColor
        self.splitImage.lineWidth = 1
        
        self.layer.addSublayer(self.microPrism)
        self.layer.addSublayer(self.splitImage)
        
        self.alpha = 0.4
        
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
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            self.alpha = 0.8
            self.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(1.2, 1.2), CGFloat(M_PI/6))
            
        }, completion: { (finished) -> Void in
        
            UIView.animateWithDuration(2.0, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
                
                self.alpha = 0.4
                self.transform = CGAffineTransformIdentity
                
            }, completion: { (finished) -> Void in
            
                //
                
            })
            
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
