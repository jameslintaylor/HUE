//
//  ColorTarget.swift
//  Hue
//
//  Created by James Lin Taylor on 2015-03-16.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class ColorTarget: UIView {
    
    override init() {
        
        super.init(frame: CGRect(origin: CGPointZero, size: CGSize(width: 20, height: 20)))
        
        let layer1 = CAShapeLayer()
        layer1.frame = self.bounds
        layer1.path = UIBezierPath(ovalInRect: layer1.bounds).CGPath
        layer1.fillColor = nil
        layer1.strokeColor = UIColor(white: 0, alpha: 0.2).CGColor
        layer1.lineWidth = 8
        
        let layer2 = CAShapeLayer()
        layer2.frame = CGRectInset(self.bounds, 4, 4)
        layer2.path = UIBezierPath(ovalInRect: layer2.bounds).CGPath
        layer2.fillColor = nil
        layer2.strokeColor = UIColor(white: 1, alpha: 1).CGColor
        layer2.lineWidth = 1
        
        self.layer.addSublayer(layer1)
        self.layer.addSublayer(layer2)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
