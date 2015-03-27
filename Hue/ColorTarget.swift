//
//  ColorTarget.swift
//  Hue
//
//  Created by James Lin Taylor on 2015-03-16.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class ColorTarget: UIView {
    
    let outerRing = CAShapeLayer()
    let innerRing = CAShapeLayer()
    
    override init() {
        super.init(frame: CGRect(origin: CGPointZero, size: CGSize(width: 20, height: 20)))
        
        self.layer.addSublayer(self.outerRing)
        self.layer.addSublayer(self.innerRing)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func updateWithColor(color: UIColor?) {
        
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        self.innerRing.strokeColor = color?.complimentaryColor()?.CGColor
        self.outerRing.strokeColor = color?.lighterColor()?.colorWithAlphaComponent(0.4).CGColor
        CATransaction.commit()
        
    }
    
    // MARK: - Private Methods
    
    func setup() {
        self.outerRing.frame = self.bounds
        self.outerRing.path = UIBezierPath(ovalInRect: self.outerRing.bounds).CGPath
        self.outerRing.fillColor = nil
        self.outerRing.strokeColor = UIColor(white: 1, alpha: 0.4).CGColor
        self.outerRing.lineWidth = 8
        
        self.innerRing.frame = CGRectInset(self.bounds, 4, 4)
        self.innerRing.path = UIBezierPath(ovalInRect: self.innerRing.bounds).CGPath
        self.innerRing.fillColor = nil
        self.innerRing.strokeColor = UIColor(white: 1, alpha: 1).CGColor
        self.innerRing.lineWidth = 1
    }
    
}
