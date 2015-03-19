//
//  CameraViewController.swift
//  Hue
//
//  Created by James Lin Taylor on 2015-03-16.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

import GPUImage

class CameraViewController: UIViewController, ColorProcessManagerDelegate {

    var processMGR: ColorProcessManager!
    
    var camera: GPUImageStillCamera!
    var cropFilter: GPUImageCropFilter!
    var focusingChangedContext: UnsafeMutablePointer<()>!
    
    let colorMenuViewContainer = UIView()
    let colorMenuViewController = ColorMenuViewController()
    
    let cameraView = GPUImageView()
    let colorTarget = ColorTarget()
    
    var focusingIndicator: FocusingIndicator?
    
    override func loadView() {
        
        let rootView = UIView()
        
        self.cameraView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.colorTarget.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.colorMenuViewContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        rootView.addSubview(self.cameraView)
        rootView.addSubview(self.colorTarget)
        rootView.addSubview(self.colorMenuViewContainer)
        
        // camera view constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.cameraView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.cameraView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.cameraView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.cameraView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0))
        
        // color target constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 20))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 20))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0))
        
        // color save button constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.colorMenuViewContainer, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorMenuViewContainer, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 80))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorMenuViewContainer, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorMenuViewContainer, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
        
        // gestures
        var tapGR = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        rootView.addGestureRecognizer(tapGR)
        
        self.view = rootView
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        self.processMGR = ColorProcessManager()
        self.processMGR.delegate = self
        
        self.camera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPreset1920x1080, cameraPosition: AVCaptureDevicePosition.Back)
        self.camera.outputImageOrientation = UIInterfaceOrientation.Portrait
        
        var error: NSError?
        if (self.camera.inputCamera.lockForConfiguration(&error)) {
            
            self.camera.inputCamera.subjectAreaChangeMonitoringEnabled = true
            self.camera.inputCamera.unlockForConfiguration()
            
        } else {
            
            NSLog("Camera configuration error: \(error?.localizedDescription)")
            
        }
        
        self.cropFilter = GPUImageCropFilter()
        self.focusingChangedContext = UnsafeMutablePointer<()>()
        
        // Color menu bar view controller
        self.colorMenuViewController.view.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.colorMenuViewController.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.colorMenuViewController.view.frame = self.colorMenuViewContainer.bounds
        self.colorMenuViewContainer.addSubview(self.colorMenuViewController.view)
        self.addChildViewController(self.colorMenuViewController)
        self.colorMenuViewController.didMoveToParentViewController(self)
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleSubjectAreaChangedNotification:"), name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: nil)
        self.camera.inputCamera.addObserver(self, forKeyPath: "adjustingFocus", options: NSKeyValueObservingOptions.New, context: self.focusingChangedContext)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.camera.addTarget(self.cameraView)
        self.camera.addTarget(self.cropFilter)
        self.camera.startCameraCapture()
        
        // start average color operations
        self.beginAverageColorCaptureAtPoint(CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2))
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        self.camera.removeAllTargets()
        self.camera.stopCameraCapture()
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: AVCaptureDeviceSubjectAreaDidChangeNotification)
        self.camera.removeObserver(self, forKeyPath: "adjustingFocus", context: self.focusingChangedContext)
    }
    
    // MARK: - Private Methods
    
    func focusAtPoint(point: CGPoint) {
        
        // focusing indicator
        self.focusingIndicator?.shouldRemoveAnimated(false)
        self.focusingIndicator = FocusingIndicator()
        self.focusingIndicator!.center = point
        self.view.addSubview(self.focusingIndicator!)
        
        var captureDevice = self.camera.inputCamera
        if captureDevice.focusPointOfInterestSupported & captureDevice.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) {
            
            var error: NSError?
            
            if captureDevice.lockForConfiguration(&error) {
                
                let normalizedPoint = CGPoint(x: point.x/SCR_WIDTH, y: point.y/SCR_HEIGHT)
                captureDevice.focusPointOfInterest = normalizedPoint
                captureDevice.focusMode = AVCaptureFocusMode.AutoFocus
                captureDevice.unlockForConfiguration()
                
            } else {
                
                NSLog("Camera configuration error: \(error?.localizedDescription)")
                
            }
            
        }
        
    }
    
    func beginAverageColorCaptureAtPoint(point: CGPoint) {
        
        let normalizedPoint = CGPoint(x: point.x/SCR_WIDTH, y: point.y/SCR_HEIGHT)
        let normalizedRegion = CGRect(x: normalizedPoint.x - 0.01, y: normalizedPoint.y - 0.01, width: 0.02, height: 0.02)
        self.cropFilter.cropRegion = normalizedRegion
        
        self.cropFilter.removeAllTargets()
        self.cropFilter.addTarget(self.processMGR.averageColorProcess)
        
    }
    
    // MARK: - Notification Handling
    
    func handleSubjectAreaChangedNotification(notification: NSNotification) {
        
        // remove focusing indicator
        self.focusingIndicator?.shouldRemoveAnimated(true)
        
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if context == self.focusingChangedContext {
            
            if self.camera.inputCamera.adjustingFocus {
                
                // queue focusing animation
                self.focusingIndicator?.startFocusingAnimation()
                
            } else {
                
                // queue focused animation
                self.focusingIndicator?.startFocusedAnimation()
                
            }
            
        }
        
    }
    
    // MARK: - Gesture Handling
    
    func handleSingleTap(sender: UITapGestureRecognizer) {
        
        var tapLocation = sender.locationInView(self.view)
        self.focusAtPoint(tapLocation)
    }
   
    // MARK: - ColorProcessManager Delegate
    
    func colorProcessManager(manager: ColorProcessManager, updatedColor color: UIColor?) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.colorMenuViewController.updateWithColor(color)
        })
    }
    
}

