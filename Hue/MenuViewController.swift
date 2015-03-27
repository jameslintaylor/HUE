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
    
    func menuViewController(viewController: MenuViewController, capturedSampleWithColor color: UIColor?)
    
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
        self.cameraIcon.image = UIImage(named: "CameraIcon")
        
        rootView.addSubview(self.sampleView)
        rootView.addSubview(self.cameraIcon)
        rootView.clipsToBounds = true
        
        // camera icon constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.cameraIcon, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 60))
        rootView.addConstraint(NSLayoutConstraint(item: self.cameraIcon, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 60))
        rootView.addConstraint(NSLayoutConstraint(item: self.cameraIcon, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.cameraIcon, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
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
    
    func updateForState(state: MenuState) {
        if self.state != state {
            self.state = state
        }
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
    
}
