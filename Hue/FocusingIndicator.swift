//
//  FocusingIndicator.swift
//  Hue
//
//  Created by James Lin Taylor on 2015-03-16.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class FocusingIndicator: UIView {

    override init() {
        
        super.init(frame: CGRect(origin: CGPointZero, size: CGSize(width: 80, height: 80)))
        
        self.backgroundColor = UIColor.blackColor()
        
    }

    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    deinit {
        
        NSLog("Focusing Indicator deinitialized")
        
    }
    
    // Mark: Public methods
    
    func startFocusingAnimation() {
        
        self.backgroundColor = UIColor.orangeColor()
        
    }
    
    func startFocusedAnimation() {
        
        self.backgroundColor = UIColor.greenColor()
        
    }
    
    func shouldRemoveAnimated(animated: Bool) {
        
        self.backgroundColor = UIColor.blackColor()
        self.removeFromSuperview()
        
    }
    
}
