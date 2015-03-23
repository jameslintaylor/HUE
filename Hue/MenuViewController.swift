//
//  MenuViewController.swift
//  Hue
//
//  Created by James Taylor on 2015-03-19.
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

// MARK: - MenuViewController

enum MenuState {
    
    case Camera, Samples
    
}

protocol MenuViewControllerDelegate: class {
    
    func menuViewController(viewController: MenuViewController, requestedChangeMenuToState: MenuState) -> Bool
    
}

class MenuViewController: UIViewController {

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
    
    weak var delegate: MenuViewControllerDelegate?
    var locked: Bool = false
    var state: MenuState = .Camera
    var supportedModes: [ColorMode] = [.HSB, .RGB, .HEX]
    var modeIdx: Int = 1
    
    var colorOverlay: UIView!
    var colorLabel: UILabel!
    
    override func loadView() {
        let rootView = UIView()
        
        self.colorOverlay = UIView()
        self.colorOverlay.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.colorOverlay.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        self.colorLabel = UILabel()
        self.colorLabel.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.colorLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight

        rootView.addSubview(self.colorOverlay)
        rootView.addSubview(self.colorLabel)
        rootView.clipsToBounds = true
        
        // gestures
        var swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeUpGestureRecognizer.direction = .Up
        
        var swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeDownGestureRecognizer.direction = .Down
        
        rootView.addGestureRecognizer(swipeUpGestureRecognizer)
        rootView.addGestureRecognizer(swipeDownGestureRecognizer)
        
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.colorLabel.font = UIFont(name: "GillSans-Italic", size: 24)
        self.colorLabel.textAlignment = .Center
        
    }
    
    // MARK: - Public Methods
    
    func updateWithColor(color: UIColor?) {
        
        if self.locked {
            return
        }
        
        self.colorOverlay.backgroundColor = color
        var currentMode = self.supportedModes[self.modeIdx]
        self.colorLabel.text = currentMode.descriptionForColor(color)
        self.colorLabel.textColor = color?.complimentaryColor()
    }
    
    // MARK: - Private Methods
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.locked = true
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.locked = false
    }

    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        self.locked = false
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        self.animateLabelChange(sender.direction)
        
        switch sender.direction {
            
        case UISwipeGestureRecognizerDirection.Down:
            self.modeIdx = (self.modeIdx + 1) % self.supportedModes.count
            
        default:
            self.modeIdx = self.modeIdx - 1 < 0 ? self.supportedModes.count - 1 : self.modeIdx - 1
            
        }
    }
    
    func animateLabelChange(direction: UISwipeGestureRecognizerDirection) {
        var tempLabel = self.colorLabel.copy() as UILabel
        self.view.addSubview(tempLabel)
        var dy: CGFloat = direction == .Down ? -100.0 : 100.0
        self.colorLabel.transform = CGAffineTransformMakeTranslation(0, dy)
        self.colorLabel.alpha = 0.0
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.2, options: nil, animations: {
        
            self.colorLabel.transform = CGAffineTransformIdentity
            self.colorLabel.alpha = 1.0
            tempLabel.transform = CGAffineTransformMakeTranslation(0, -dy)
            tempLabel.alpha = 0.0
            
        }, completion: { finished in
            
            tempLabel.removeFromSuperview()
            
        })
        
    }

}
