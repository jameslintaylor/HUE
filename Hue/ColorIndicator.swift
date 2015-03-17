//
//  ColorIndicator.swift
//  Hue
//
//  Created by James Lin Taylor on 2015-03-16.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class ColorIndicator: UIView {

    var colorView: UIView!
    var colorLabel: UILabel!
    var targetLayer: CAShapeLayer!
    
    override init() {
        
        super.init(frame: CGRect(origin: CGPointZero, size: CGSize(width: 80, height: 80)))
        
        self.colorView = UIView(frame: CGRectInset(self.bounds, 10, 10))
        self.colorView.layer.cornerRadius = 30
        self.colorView.layer.borderWidth = 1
        self.colorView.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.colorLabel = UILabel(frame: CGRect(x: self.bounds.width, y: 0, width: 300, height: self.bounds.height))
        self.colorLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14.0)
        self.colorLabel.numberOfLines = 3
        self.colorLabel.textColor = UIColor.whiteColor()
        self.colorLabel.layer.shadowColor = UIColor.blackColor().CGColor
        
        self.targetLayer = CAShapeLayer()
        self.targetLayer.frame = self.frame
        self.targetLayer.path = UIBezierPath(ovalInRect: CGRectInset(self.bounds, 34, 34)).CGPath
        self.targetLayer.fillColor = nil
        self.targetLayer.strokeColor = UIColor.whiteColor().CGColor
        self.targetLayer.lineWidth = 1
        
        self.layer.addSublayer(self.targetLayer)
        self.addSubview(self.colorLabel)
        self.addSubview(self.colorView)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    deinit {
        
        NSLog("Color Indicator deinitialized")
        
    }
    
    // MARK: Public methods
    
    func setColor(color: UIColor?) {
        
        self.colorView.backgroundColor = color
        
        var hsba = [CGFloat](count: 4, repeatedValue: 0.0)
        color?.getHue(&hsba[0], saturation: &hsba[1], brightness: &hsba[2], alpha: &hsba[3])
        var h: Int = Int(hsba[0]*360)
        var s: Int = Int(hsba[1]*100)
        var b: Int = Int(hsba[2]*100)
        self.colorLabel.text = "H - \(h)\nS - \(s)%\nB - \(b)%"
        
    }
    
    func expand() {
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            self.colorView.center.y = -20
            self.colorLabel.frame.origin.x = self.bounds.width * 3/4
            
        }, completion: { (finished) -> Void in
        
            
            
        })
        
    }
    
    func shrink() {
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            self.colorView.center.y = self.bounds.height/2
            self.colorLabel.frame.origin.x = self.bounds.width
            
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
