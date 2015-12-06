//
//  CellDeleteControl.swift
//  HUE
//
//  Created by James Lin Taylor on 2015-12-05.
//  Copyright © 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class CellDeleteControl: UIView {

    private let cancelContainer = CALayer()
    private let cancelLayer = CAShapeLayer()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Setup layers
        cancelLayer.bounds.size = CGSize(width: 20, height: 20)
        cancelLayer.lineWidth = 2
        cancelLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI/4), 0, 0, 1)
        
        // Drawing
        let cancelPath = UIBezierPath()
        cancelPath.moveToPoint(CGPoint(x: 10, y: 0))
        cancelPath.addLineToPoint(CGPoint(x: 10, y: 20))
        cancelPath.moveToPoint(CGPoint(x: 0, y: 10))
        cancelPath.addLineToPoint(CGPoint(x: 20, y: 10))
        cancelLayer.path = cancelPath.CGPath
        
        cancelLayer.backgroundColor = UIColor.redColor().CGColor
        layer.addSublayer(cancelLayer)
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
