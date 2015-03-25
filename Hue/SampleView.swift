//
//  SampleView.swift
//  HUE
//
//  Created by James Taylor on 2015-03-24.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

// MARK: - Extensions
extension UIColor {
    
    func hexString() -> String {
        
        var rgba = [CGFloat](count: 4, repeatedValue: 0.0)
        self.getRed(&rgba[0], green: &rgba[1], blue: &rgba[2], alpha: &rgba[3])
        var rgba255 = rgba.map() { Int($0 * 255) }
        return NSString(format: "%02X%02X%02X", rgba255[0], rgba255[1], rgba255[2])
        
    }
    
    func complimentaryColor() -> UIColor? {
        var hsba = [CGFloat](count: 4, repeatedValue: 0.0)
        self.getHue(&hsba[0], saturation: &hsba[1], brightness: &hsba[2], alpha: &hsba[3])
        var diff = hsba[2] < 0.5 ? 1.0 - hsba[2] : -hsba[2]
        hsba[2] += diff/2
        return UIColor(hue: hsba[0], saturation: hsba[1], brightness: hsba[2], alpha: hsba[3])
    }
    
}

extension UILabel {
    
    public override func copy() -> AnyObject {
        var copiedLabel = UILabel(frame: self.frame)
        
        copiedLabel.setTranslatesAutoresizingMaskIntoConstraints(self.translatesAutoresizingMaskIntoConstraints())
        copiedLabel.autoresizingMask = self.autoresizingMask
        
        copiedLabel.font = self.font
        copiedLabel.textAlignment = self.textAlignment
        copiedLabel.textColor = self.textColor
        copiedLabel.text = self.text
        copiedLabel.backgroundColor = self.backgroundColor
        
        return copiedLabel
    }
    
}

// MARK: - ColorMode Declaration

enum ColorMode {
    
    case RGB, HSB, HEX
    
    func descriptionForColor(color: UIColor?) -> String {
        var description: String = "UNKNOWN"
        
        switch self {
            
        case RGB:
            var rgba = [CGFloat](count: 4, repeatedValue: 0.0)
            color?.getRed(&rgba[0], green: &rgba[1], blue: &rgba[2], alpha: &rgba[3])
            var rgba255 = rgba.map() { Int($0 * 255) }
            description = "rgb(\(rgba255[0]), \(rgba255[1]), \(rgba255[2]))"
            
        case HSB:
            var hsba = [CGFloat](count: 4, repeatedValue: 0.0)
            color?.getHue(&hsba[0], saturation: &hsba[1], brightness: &hsba[2], alpha: &hsba[3])
            var h = Int(hsba[0] * 360)
            var s = Int(hsba[1] * 100)
            var b = Int(hsba[2] * 100)
            description = "hsb(\(h), \(s), \(b))"
            
        default:
            if let hexDescription = color?.hexString() {
                description = "#\(hexDescription)"
            }
            
        }
        
        return description
    }
    
}

// MARK: - SampleView

class SampleView: UIView {

    var color: UIColor? {
        didSet {
            self.update()
        }
    }
    
    var supportedModes: [ColorMode] = [.HSB, .RGB, .HEX] {
        didSet {
            self.modeIdx = 0
        }
    }
    
    var modeIdx: Int = 0 {
        didSet {
            self.update()
        }
    }
    
    var colorBorder: UIView
    var colorLabel: UILabel
    
    override init(frame: CGRect) {
        
        self.colorBorder = UIView()
        self.colorLabel = UILabel()
        
        super.init(frame: frame)
        
        self.colorBorder.frame.size = CGSize(width: 0, height: 1)
        self.colorBorder.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.colorBorder.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        self.colorLabel.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.colorLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.colorLabel.font = UIFont(name: "GillSans-Italic", size: 26)
        self.colorLabel.textAlignment = .Center
        
        self.addSubview(self.colorBorder)
        self.addSubview(self.colorLabel)
        
        // gestures
        var swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeLeftGestureRecognizer.direction = .Left
        var swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeRightGestureRecognizer.direction = .Right
        
        self.addGestureRecognizer(swipeLeftGestureRecognizer)
        self.addGestureRecognizer(swipeRightGestureRecognizer)
    }
    
    convenience override init() {
        self.init(frame: CGRectZero)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    
    
    // MARK: - Private Methods
    
    private func update() {
        
        self.backgroundColor = self.color
        
        self.colorBorder.backgroundColor = color?.complimentaryColor()
        var currentMode = self.supportedModes[self.modeIdx]
        self.colorLabel.text = currentMode.descriptionForColor(color)
        self.colorLabel.textColor = color?.complimentaryColor()
        
    }
    
    func animateLabelChange(direction: UISwipeGestureRecognizerDirection) {
        var tempLabel = self.colorLabel.copy() as UILabel
        self.addSubview(tempLabel)
        var dx: CGFloat = direction == .Left ? 60.0 : -60.0
        self.colorLabel.transform = CGAffineTransformMakeTranslation(dx, 0)
        self.colorLabel.alpha = 0.0
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.2, options: nil, animations: {
            
            self.colorLabel.transform = CGAffineTransformIdentity
            self.colorLabel.alpha = 1.0
            tempLabel.transform = CGAffineTransformMakeTranslation(-dx, 0)
            tempLabel.alpha = 0.0
            
            }, completion: { finished in
                tempLabel.removeFromSuperview()
        })
        
    }
    
    // MARK: - Handlers
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
            
        case UISwipeGestureRecognizerDirection.Left:
            self.animateLabelChange(sender.direction)
            self.modeIdx = (self.modeIdx + 1) % self.supportedModes.count
            
        default:
            self.animateLabelChange(sender.direction)
            self.modeIdx = self.modeIdx - 1 < 0 ? self.supportedModes.count - 1 : self.modeIdx - 1
        }
        
    }
    
}
