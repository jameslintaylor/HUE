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
    
    func cameraViewController(viewController: CameraViewController, targetUpdatedWithColor color: UIColor?)
    func cameraViewController(viewController: CameraViewController, capturedSampleWithColor color: UIColor?, thumbnail: UIImage?)
    
}

class CameraViewController: UIViewController, ColorProcessManagerDelegate {

    weak var delegate: CameraViewControllerDelegate?
    var processMGR: ColorProcessManager!
    
    var capturedImage: UIImage?
    let camera: GPUImageStillCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPreset1920x1080, cameraPosition: AVCaptureDevicePosition.Back)
    let cropFilter = GPUImageCropFilter()
    let thumbnailFilter = GPUImageCropFilter()
    var focusingChangedContext = UnsafeMutablePointer<()>()
    
    let cameraView = GPUImageView()
    let colorTarget = ColorTarget()
    var focusingIndicator: FocusingIndicator?
    let captureButton = UIButton()
    
    override func loadView() {
        
        let rootView = UIView()
        
        self.cameraView.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.cameraView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        self.colorTarget.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.captureButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.captureButton.backgroundColor = UIColor.redColor()
        self.captureButton.layer.cornerRadius = 40
        
        rootView.addSubview(self.cameraView)
        rootView.addSubview(self.colorTarget)
        rootView.addSubview(self.captureButton)
        
        // color target constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 20))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 20))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: .CenterX, relatedBy: .Equal, toItem: rootView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: .CenterY, relatedBy: .Equal, toItem: rootView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        // capture button constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.captureButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 80))
        rootView.addConstraint(NSLayoutConstraint(item: self.captureButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 80))
        rootView.addConstraint(NSLayoutConstraint(item: self.captureButton, attribute: .CenterX, relatedBy: .Equal, toItem: rootView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.captureButton, attribute: .CenterY, relatedBy: .Equal, toItem: rootView, attribute: .Bottom, multiplier: 1.0, constant: -TAB_HEIGHT - 60))
        
        // gestures
        var tapGR = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        rootView.addGestureRecognizer(tapGR)
        
        self.view = rootView
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        self.processMGR = ColorProcessManager()
        self.processMGR.delegate = self
        
        self.camera.outputImageOrientation = .Portrait
        
        var error: NSError?
        if (self.camera.inputCamera.lockForConfiguration(&error)) {
            self.camera.inputCamera.subjectAreaChangeMonitoringEnabled = true
            self.camera.inputCamera.unlockForConfiguration()
        } else {
            NSLog("Camera configuration error: \(error?.localizedDescription)")
        }
        
        self.camera.addTarget(self.cameraView)
        self.camera.addTarget(self.cropFilter)
        self.camera.addTarget(self.thumbnailFilter)
        self.camera.startCameraCapture()
        
        self.captureButton.addTarget(self, action: Selector("captureSample"), forControlEvents: .TouchUpInside)
        
        self.thumbnailFilter.cropRegion = CGRect(x: 0.0, y: 0.3, width: 1.0, height: 0.4)
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleSubjectAreaChangedNotification:"), name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: nil)
        self.camera.inputCamera.addObserver(self, forKeyPath: "adjustingFocus", options: NSKeyValueObservingOptions.New, context: self.focusingChangedContext)
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.beginAverageColorCaptureAtPoint(CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2))
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.camera.removeObserver(self, forKeyPath: "adjustingFocus", context: self.focusingChangedContext)
    }
    
    // MARK: - Public Methods
    
    
    
    // MARK: - Private Methods
    
    func captureSample() {
        
        let color = self.processMGR.color
        self.camera.capturePhotoAsImageProcessedUpToFilter(self.thumbnailFilter, withCompletionHandler: { [unowned self] (image, error) -> Void in
            
            if error != nil {
                
                println("sample capture error: \(error.localizedDescription)")
            
            } else {
            
                self.delegate?.cameraViewController(self, capturedSampleWithColor: color, thumbnail: image)
            
            }
            
        })
        
    }
    
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
        
        self.cropFilter.addTarget(self.processMGR.averageColorProcess)
        
    }
    
    func endAverageColorCapture() {
        self.cropFilter.removeAllTargets()
    }
    
    // MARK: - Notification Handling
    
    func handleSubjectAreaChangedNotification(notification: NSNotification) {
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
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.colorTarget.updateWithColor(color)
            self.captureButton.backgroundColor = color
            
            self.delegate?.cameraViewController(self, targetUpdatedWithColor: color)
            
        }
        
    }
    
}

