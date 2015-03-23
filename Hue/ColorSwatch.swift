//
//  ColorSwatch.swift
//  HUE
//
//  Created by James Taylor on 2015-03-21.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class ColorSwatch: UIView {

    var locked = false
    
    let backgroundView = UIView()
    let colorLabel = UILabel()
    
    override init() {
        
        super.init(frame: CGRectZero)
        
        self.colorLabel.font = UIFont(name: "GillSans-Italic", size: 24)
        self.colorLabel.textAlignment = NSTextAlignment.Center
        self.colorLabel.alpha = 0.0
        
        self.addSubview(self.backgroundView)
        self.addSubview(self.colorLabel)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        self.backgroundView.frame = self.bounds
        self.backgroundView.layer.cornerRadius = self.bounds.width/2
        self.colorLabel.frame = self.bounds
        
    }
    
    // MARK: - Public Methods
    
    func lock() { self.locked = true }
    func unlock() { self.locked = false }
    
    func setColor(color: UIColor?) {
        
        if self.locked {
            return
        }
        
        self.backgroundView.backgroundColor = color
        self.colorLabel.textColor = color
        
        var hsba = [CGFloat](count: 4, repeatedValue: 0.0)
        color?.getHue(&hsba[0], saturation: &hsba[1], brightness: &hsba[2], alpha: &hsba[3])
        
        self.colorLabel.text = "hsb(\(hsba[0]), \(hsba[1]), \(hsba[2]))"
        
    }
    
    func expand() {
        
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: -2, options: nil, animations: {
            
            self.transform = CGAffineTransformMakeScale(8, 8)
            
        }, completion: nil)
        
    }
    
    func shrink() {
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            self.backgroundView.transform = CGAffineTransformIdentity
            
        }, completion: nil)
        
    }
    
    func showText() {
        
        self.colorLabel.alpha = 1.0
        UIView.animateWithDuration(0.4) { self.colorLabel.textColor = UIColor.whiteColor() }
        
    }
    
    func hideText() {
        
        UIView.animateWithDuration(0.4, animations: {
            
            self.colorLabel.textColor = self.backgroundView.backgroundColor
            self.colorLabel.alpha = 0.0
            
        }, completion: nil)
        
    }
    
}
