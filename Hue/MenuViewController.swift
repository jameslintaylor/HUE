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
    func menuViewControllerStartedSampleCapture(viewController: MenuViewController)
    func menuViewController(viewController: MenuViewController, didConfirmSampleCaptureWithColor color: UIColor?)
    
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
            self.animateUpdate()
        }
    }
    var supportedModes: [ColorMode] = [.HSB, .RGB, .HEX]
    var modeIdx: Int = 1
    
    var colorOverlay = UIView()
    var coloredBorder = UIView()
    var colorLabel = UILabel()
    var cameraIcon = UIImageView()
    
    override func loadView() {
        let rootView = UIView()
        rootView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        
        self.colorOverlay.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.colorOverlay.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        self.coloredBorder.frame.size = CGSize(width: 0, height: 1)
        self.coloredBorder.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.coloredBorder.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        self.colorLabel.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.colorLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        self.cameraIcon.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.cameraIcon.backgroundColor = UIColor.whiteColor()
        self.cameraIcon.layer.cornerRadius = 20
        
        rootView.addSubview(self.colorOverlay)
        rootView.addSubview(self.coloredBorder)
        rootView.addSubview(self.colorLabel)
        rootView.addSubview(self.cameraIcon)
        rootView.clipsToBounds = true
        
        // camera icon constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.cameraIcon, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        rootView.addConstraint(NSLayoutConstraint(item: self.cameraIcon, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40))
        rootView.addConstraint(NSLayoutConstraint(item: self.cameraIcon, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.cameraIcon, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        // gestures
        var captureGestureRecognizer = CaptureGestureRecognizer(target: self, action: Selector("handleCaptureGesture:"))
        var swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeUpGestureRecognizer.direction = .Up
        var swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeDownGestureRecognizer.direction = .Down
        var swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeLeftGestureRecognizer.direction = .Left
        var swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeRightGestureRecognizer.direction = .Right
        
        rootView.addGestureRecognizer(captureGestureRecognizer)
        rootView.addGestureRecognizer(swipeUpGestureRecognizer)
        rootView.addGestureRecognizer(swipeDownGestureRecognizer)
        rootView.addGestureRecognizer(swipeLeftGestureRecognizer)
        rootView.addGestureRecognizer(swipeRightGestureRecognizer)
        
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.state = .Camera
        
        self.colorLabel.font = UIFont(name: "GillSans-Italic", size: 26)
        self.colorLabel.textAlignment = .Center
        
    }
    
    // MARK: - Public Methods
    
    func updateWithColor(color: UIColor?) {
        
        if self.locked {
            return
        }
        
        self.colorOverlay.backgroundColor = color
        self.coloredBorder.backgroundColor = color?.complimentaryColor()
        var currentMode = self.supportedModes[self.modeIdx]
        self.colorLabel.text = currentMode.descriptionForColor(color)
        self.colorLabel.textColor = color?.complimentaryColor()
    }
    
    // MARK: - Private Methods
    
    func updateForCameraInterface() {
        self.colorLabel.transform = CGAffineTransformIdentity
        self.cameraIcon.transform = CGAffineTransformMakeTranslation(0, SWATCH_HEIGHT)
        self.colorOverlay.alpha = 1
        self.coloredBorder.alpha = 1
        self.colorLabel.alpha = 1
    }
   
    func updateForSamplesInterface() {
        self.colorLabel.transform = CGAffineTransformMakeTranslation(0, -SWATCH_HEIGHT)
        self.cameraIcon.transform = CGAffineTransformIdentity
        self.colorOverlay.alpha = 0
        self.coloredBorder.alpha = 0
        self.colorLabel.alpha = 0
    }
    
    func animateUpdate() {
        UIView.animateWithDuration(0.2) {
            if self.state == .Camera {
                self.updateForCameraInterface()
            } else {
                self.updateForSamplesInterface()
            }
        }
    }
    
    func animateLabelChange(direction: UISwipeGestureRecognizerDirection) {
        var tempLabel = self.colorLabel.copy() as UILabel
        self.view.addSubview(tempLabel)
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
    
    func handleCaptureGesture(sender: CaptureGestureRecognizer) {
        
        switch sender.state {
            
        case .Began:
            self.locked = true
            UIView.animateWithDuration(0.2) {
                self.colorLabel.alpha = 0.0
                self.colorLabel.transform = CGAffineTransformMakeScale(0.95, 0.95)
            }
            self.delegate?.menuViewControllerStartedSampleCapture(self)
            
        case .Changed:
            break
            
        case .Ended:
            self.locked = false
            UIView.animateWithDuration(0.2) {
                self.colorLabel.alpha = 1.0
                self.colorLabel.transform = CGAffineTransformIdentity
            }
            self.delegate?.menuViewController(self, didConfirmSampleCaptureWithColor: self.colorOverlay.backgroundColor)
            
        default:
            self.locked = false
            UIView.animateWithDuration(0.2) {
                self.colorLabel.alpha = 1.0
                self.colorLabel.transform = CGAffineTransformIdentity
            }
            
        }
        
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
    
}
