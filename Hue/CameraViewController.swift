//
//  CameraViewController.swift
//  Hue
//
//  Created by James Lin Taylor on 2015-03-16.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

import GPUImage

protocol CameraViewControllerDelegate: class {
    
    func cameraViewController(viewController: CameraViewController, didUpdateWithColor color: UIColor?)
    
}

class CameraViewController: UIViewController, ColorProcessManagerDelegate {

    weak var delegate: CameraViewControllerDelegate?
    var processMGR: ColorProcessManager!
    
    var camera: GPUImageStillCamera!
    var cropFilter: GPUImageCropFilter!
    var focusingChangedContext: UnsafeMutablePointer<()>!
    
    let cameraView = GPUImageView()
    let colorTarget = ColorTarget()
    let overlay = UIView()
    
    var focusingIndicator: FocusingIndicator?
        
    override func loadView() {
        
        let rootView = UIView()
        
        self.cameraView.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.cameraView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        self.colorTarget.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.overlay.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.overlay.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.overlay.backgroundColor = UIColor(white: 0.8, alpha: 1)
        
        rootView.addSubview(self.cameraView)
        rootView.addSubview(self.colorTarget)
        rootView.addSubview(self.overlay)
        
        // color target constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 20))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 20))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0))
        
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
    
        // hide overlay
        self.hideOverlay()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        self.camera.removeAllTargets()
        self.camera.stopCameraCapture()
    
        // show overlay
        self.showOverlay()
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
        
        var aspectRatio = self.cameraView.frame.width / self.cameraView.frame.height
        var dx: CGFloat = 0.01
        var dy: CGFloat = dx * aspectRatio
        
        let normalizedRegion = CGRect(x: normalizedPoint.x - dx/2, y: normalizedPoint.y - dy/2, width: dx, height: dy)
        self.cropFilter.cropRegion = normalizedRegion
        
        self.cropFilter.removeAllTargets()
        self.cropFilter.addTarget(self.processMGR.averageColorProcess)
        
    }
    
    func showOverlay() {
        
        UIView.animateWithDuration(0.2) { self.overlay.alpha = 1.0 }
        
    }
    
    func hideOverlay() {
        
        UIView.animateWithDuration(0.2) { self.overlay.alpha = 0.0 }

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
        
        self.delegate?.cameraViewController(self, didUpdateWithColor: color)
    
    }
    
}

