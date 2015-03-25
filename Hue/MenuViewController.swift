//
//  MenuViewController.swift
//  Hue
//
//  Created by James Taylor on 2015-03-19.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

enum MenuState {
    
    case Camera, Samples
    
}

protocol MenuViewControllerDelegate: class {
    
    func menuViewController(viewController: MenuViewController, requestedChangeMenuToState state: MenuState) -> Bool
    func menuViewControllerStartedSampleCapture(viewController: MenuViewController)
    func menuViewController(viewController: MenuViewController, didConfirmSampleCaptureWithColor color: UIColor?)
    
}

class MenuViewController: UIViewController {
    
    weak var delegate: MenuViewControllerDelegate?
    var locked: Bool = false
    var state: MenuState! {
        didSet {
            self.animateUpdate()
        }
    }
    
    var sampleView: SampleView!
    var cameraIcon: UIImageView!
    
    override func loadView() {
        let rootView = UIView()
        rootView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        
        self.sampleView = SampleView()
        self.sampleView.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.sampleView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        self.cameraIcon = UIImageView()
        self.cameraIcon.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.cameraIcon.backgroundColor = UIColor.whiteColor()
        self.cameraIcon.layer.cornerRadius = 20
        
        rootView.addSubview(self.sampleView)
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
        
        rootView.addGestureRecognizer(captureGestureRecognizer)
        rootView.addGestureRecognizer(swipeUpGestureRecognizer)
        rootView.addGestureRecognizer(swipeDownGestureRecognizer)
        
        self.view = rootView
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.state = .Camera
    }
    
    // MARK: - Public Methods
    
    func updateWithColor(color: UIColor?) {
        
        if self.locked {
            return
        }
        
        self.sampleView.color = color
        
    }
    
    // MARK: - Private Methods
    
    func updateForCameraInterface() {
    
        self.cameraIcon.transform = CGAffineTransformMakeTranslation(0, SAMPLE_HEIGHT)
        self.sampleView.alpha = 1
    
    }
   
    func updateForSamplesInterface() {
        
        self.cameraIcon.transform = CGAffineTransformIdentity
        self.sampleView.alpha = 0
    
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
    
    // MARK: - Handlers
    
    func handleCaptureGesture(sender: CaptureGestureRecognizer) {
        
        switch sender.state {
            
        case .Began:
            self.locked = true
            self.delegate?.menuViewControllerStartedSampleCapture(self)
            
        case .Changed:
            break
            
        case .Ended:
            self.locked = false
            self.delegate?.menuViewController(self, didConfirmSampleCaptureWithColor: self.sampleView.color)
            
        default:
            self.locked = false
            
        }
        
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
            
        case UISwipeGestureRecognizerDirection.Down:
            if self.delegate?.menuViewController(self, requestedChangeMenuToState: .Camera) == true {
                self.state = .Camera
            }
            
        default:
            if self.delegate?.menuViewController(self, requestedChangeMenuToState: .Samples) == true {
                self.state = .Samples
            }
        }
    }
    
}
