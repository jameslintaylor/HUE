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
    var redLabel: UILabel!
    var greenLabel: UILabel!
    var blueLabel: UILabel!
    var targetLayer: CAShapeLayer!
    var shadowView: UIView!
    
    override init() {
        
        super.init(frame: CGRect(origin: CGPointZero, size: CGSize(width: 80, height: 80)))
        
        self.colorView = UIView(frame: self.bounds)
        self.colorView.layer.cornerRadius = 40
        self.colorView.layer.borderWidth = 1
        self.colorView.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.redLabel = UILabel(frame: CGRect(x: self.bounds.width/2 - 60, y: -140, width: 40, height: 80))
        self.redLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        self.redLabel.shadowOffset = CGSize(width: -1, height: -1)
        self.redLabel.shadowColor = UIColor(hue: 0, saturation: 1, brightness: 0.2, alpha: 1)
        self.redLabel.textColor = UIColor(hue: 0, saturation: 0, brightness: 0.8, alpha: 1)
        self.redLabel.textAlignment = NSTextAlignment.Center
        
        self.greenLabel = UILabel(frame: CGRect(x: self.bounds.width/2 - 20, y: -140, width: 40, height: 80))
        self.greenLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        self.greenLabel.shadowOffset = CGSize(width: 0, height: -1)
        self.greenLabel.shadowColor = UIColor(hue: 1/3, saturation: 1, brightness: 0.2, alpha: 1)
        self.greenLabel.textColor = UIColor(hue: 1/3, saturation: 0, brightness: 0.8, alpha: 1)
        self.greenLabel.textAlignment = NSTextAlignment.Center
        
        self.blueLabel = UILabel(frame: CGRect(x: self.bounds.width/2 + 20, y: -140, width: 40, height: 80))
        self.blueLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        self.blueLabel.shadowOffset = CGSize(width: 1, height: -1)
        self.blueLabel.shadowColor = UIColor(hue: 2/3, saturation: 1, brightness: 0.2, alpha: 1)
        self.blueLabel.textColor = UIColor(hue: 2/3, saturation: 0, brightness: 0.8, alpha: 1)
        self.blueLabel.textAlignment = NSTextAlignment.Center
    
        self.targetLayer = CAShapeLayer()
        self.targetLayer.frame = self.bounds
        self.targetLayer.path = UIBezierPath(ovalInRect: CGRectInset(self.bounds, 34, 34)).CGPath
        self.targetLayer.fillColor = nil
        self.targetLayer.strokeColor = UIColor.whiteColor().CGColor
        self.targetLayer.lineWidth = 1
        
        self.shadowView = UIView(frame: self.bounds)
        
        var shadowLayer = CAShapeLayer()
        shadowLayer.frame = self.shadowView.bounds
        var shadowPath = UIBezierPath()
        shadowPath.moveToPoint(CGPoint(x: self.bounds.width - 34, y: self.bounds.height/2))
        shadowPath.addArcWithCenter(CGPoint(x: self.bounds.width/2, y: self.bounds.height/2), radius: self.bounds.width/2 - 34, startAngle: 0, endAngle: CGFloat(M_PI), clockwise: false)
        shadowPath.addLineToPoint(CGPoint(x: -SCR_WIDTH, y: -SCR_HEIGHT))
        shadowPath.addLineToPoint(CGPoint(x: self.bounds.width + SCR_WIDTH, y: -SCR_HEIGHT))
        shadowPath.closePath()
        shadowLayer.path = shadowPath.CGPath
        shadowLayer.fillColor = UIColor(white: 1, alpha: 0.4).CGColor
        
        self.shadowView.layer.addSublayer(shadowLayer)
        self.shadowView.transform = CGAffineTransformMakeScale(0.1, 1)
        
        self.addSubview(self.shadowView)
        self.layer.addSublayer(self.targetLayer)
        self.addSubview(self.redLabel)
        self.addSubview(self.greenLabel)
        self.addSubview(self.blueLabel)
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
        
        var rgba = [CGFloat](count: 4, repeatedValue: 0.0)
        color?.getRed(&rgba[0], green: &rgba[1], blue: &rgba[2], alpha: &rgba[3])
        var r: Int = Int(rgba[0]*255)
        var g: Int = Int(rgba[1]*255)
        var b: Int = Int(rgba[2]*255)
        self.redLabel.text = "\(r)"
        self.greenLabel.text = "\(g)"
        self.blueLabel.text = "\(b)"
        
    }
    
    func expand() {
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            self.colorView.center.y = -40
            self.redLabel.alpha = 1.0
            self.greenLabel.alpha = 1.0
            self.blueLabel.alpha = 1.0
            self.shadowView.transform = CGAffineTransformIdentity
            self.shadowView.alpha = 1.0
            
        }, completion: { (finished) -> Void in
        
            
            
        })
        
    }
    
    func shrink() {
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            self.colorView.center.y = self.bounds.height/2
            self.redLabel.alpha = 0.0
            self.greenLabel.alpha = 0.0
            self.blueLabel.alpha = 0.0
            self.shadowView.transform = CGAffineTransformMakeScale(0.1, 1)
            self.shadowView.alpha = 0.0
            
        }, completion: { (finished) -> Void in
                
                
                
        })
        
    }
    
    func shouldRemoveAnimated(animated: Bool) {
        
        if animated {
            
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
                
                self.alpha = 0.0
                
            }, completion: { (finished) -> Void in
                    
                self.removeFromSuperview()
                    
            })
            
        } else {
            
            self.removeFromSuperview()
            
        }
        
    }
    
}
