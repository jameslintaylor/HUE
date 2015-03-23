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
    
    func menuViewController(viewController: MenuViewController, requestedChangeMenuToState state: MenuState) -> Bool
    
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
    var state: MenuState! {
        didSet {
            self.animateLayout()
            self.animateUpdate()
        }
    }
    var supportedModes: [ColorMode] = [.HSB, .RGB, .HEX]
    var modeIdx: Int = 1
    
    var colorOverlay: UIView!
    var colorLabel: UILabel!
    var menuButton: UIView!
    var menuButtonLeftConstraint, menuButtonCenterXConstraint: NSLayoutConstraint!
    
    override func loadView() {
        let rootView = UIView()
        rootView.backgroundColor = UIColor(white: 0.8, alpha: 1)
        
        self.colorOverlay = UIView()
        self.colorOverlay.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.colorOverlay.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        self.colorLabel = UILabel()
        self.colorLabel.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.colorLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight

        self.menuButton = UIButton()
        self.menuButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.menuButton.backgroundColor = UIColor(white: 0.4, alpha: 0.5)
        self.menuButton.layer.cornerRadius = 2
        self.menuButton.userInteractionEnabled = false
        
        rootView.addSubview(self.colorOverlay)
        rootView.addSubview(self.colorLabel)
        rootView.addSubview(self.menuButton)
        rootView.clipsToBounds = true
        
        // menu button constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.menuButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 40))
        rootView.addConstraint(NSLayoutConstraint(item: self.menuButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 40))
        rootView.addConstraint(NSLayoutConstraint(item: self.menuButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0))
        
        self.menuButtonLeftConstraint = NSLayoutConstraint(item: self.menuButton, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20)
        self.menuButtonCenterXConstraint = NSLayoutConstraint(item: self.menuButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
        
        // gestures
        var swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeUpGestureRecognizer.direction = .Up
        var swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeDownGestureRecognizer.direction = .Down
        var swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeLeftGestureRecognizer.direction = .Left
        var swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeRightGestureRecognizer.direction = .Right
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        
        rootView.addGestureRecognizer(swipeUpGestureRecognizer)
        rootView.addGestureRecognizer(swipeDownGestureRecognizer)
        rootView.addGestureRecognizer(swipeLeftGestureRecognizer)
        rootView.addGestureRecognizer(swipeRightGestureRecognizer)
        rootView.addGestureRecognizer(tapGestureRecognizer)
        
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.state = .Camera
        
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
    
    func layoutCameraInterface() {
        self.view.removeConstraint(self.menuButtonCenterXConstraint)
        self.view.addConstraint(self.menuButtonLeftConstraint)
    }
    
    func updateCameraInterface() {
        self.colorLabel.alpha = 1
        self.colorOverlay.alpha = 1
    }
    
    func layoutSamplesInterface() {
        self.view.removeConstraint(self.menuButtonLeftConstraint)
        self.view.addConstraint(self.menuButtonCenterXConstraint)
    }
    
    func updateSamplesInterface() {
        self.colorLabel.alpha = 0
        self.colorOverlay.alpha = 0
    }
    
    func animateLayout() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {
            if self.state == .Camera { self.layoutCameraInterface() } else { self.layoutSamplesInterface() }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func animateUpdate() {
        UIView.transitionWithView(self.menuButton, duration: 0.2, options: .TransitionCrossDissolve, animations: {
            if self.state == .Camera { self.updateCameraInterface() } else { self.updateSamplesInterface() }
        }, completion: nil)
    }
    
    func animateLabelChange(direction: UISwipeGestureRecognizerDirection) {
        var tempLabel = self.colorLabel.copy() as UILabel
        self.view.addSubview(tempLabel)
        var dx: CGFloat = direction == .Left ? 100.0 : -100.0
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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.locked = true
        UIView.transitionWithView(self.colorLabel, duration: 0.2, options: .TransitionCrossDissolve, animations: {
            
        }, completion: nil)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.locked = false
    }

    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        self.locked = false
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Down:
            if self.delegate?.menuViewController(self, requestedChangeMenuToState: .Camera) == true {
                self.state = .Camera
            }
            
        case UISwipeGestureRecognizerDirection.Up:
            if self.delegate?.menuViewController(self, requestedChangeMenuToState: .Samples) == true {
                self.state = .Samples
            }
            
        case UISwipeGestureRecognizerDirection.Left:
            self.animateLabelChange(sender.direction)
            self.modeIdx = (self.modeIdx + 1) % self.supportedModes.count
        
        default:
            self.animateLabelChange(sender.direction)
            self.modeIdx = self.modeIdx - 1 < 0 ? self.supportedModes.count - 1 : self.modeIdx - 1
        }
    }
    
    func handleSingleTap(sender: UITapGestureRecognizer) {
        var tapLocation = sender.locationInView(sender.view)
        if CGRectContainsPoint(self.menuButton.frame, tapLocation) {
            var newState = (self.state == MenuState.Camera) ? MenuState.Samples : MenuState.Camera
            if self.delegate?.menuViewController(self, requestedChangeMenuToState: newState) == true {
                self.state = newState
            }
        } else {
            // save
        }
        
    }
    
}
