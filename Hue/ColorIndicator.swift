//
//  ColorIndicator.swift
//  Hue
//
//  Created by James Lin Taylor on 2015-03-16.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class ColorIndicator: UIView {

    override init() {
        
        super.init(frame: CGRect(origin: CGPointZero, size: CGSize(width: 80, height: 80)))
        
        self.layer.cornerRadius = 40
        self.backgroundColor = UIColor.clearColor()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    deinit {
        
        NSLog("Color Indicator deinitialized")
        
    }
    
    // MARK: Public methods
    
    func setColor(color: UIColor?) {
        
        self.backgroundColor = color
        
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
