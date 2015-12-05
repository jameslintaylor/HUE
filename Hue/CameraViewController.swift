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
    var paused: Bool = false {
        
        didSet {
            
            if self.paused {
                self.camera.removeTarget(self.cropFilter)
            } else {
                self.camera.addTarget(self.cropFilter)
            }
            
        }
   
    }
    var capturing: Bool = false
    
    var capturedImage: UIImage?
    let camera: GPUImageStillCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: AVCaptureDevicePosition.Back)
    let cropFilter = GPUImageCropFilter()
    let thumbnailFilter = GPUImageCropFilter()
    var focusingChangedContext = UnsafeMutablePointer<()>()
    
    let cameraView = GPUImageView()
    let colorTarget = ColorTarget()
    var focusingIndicator: FocusingIndicator?
    let captureButton = CaptureButton()
    
    override func loadView() {
        
        let rootView = UIView()
        
        self.cameraView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        self.cameraView.translatesAutoresizingMaskIntoConstraints = true
        self.cameraView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        self.colorTarget.translatesAutoresizingMaskIntoConstraints = false
        
        self.captureButton.setBackgroundColor(UIColor.whiteColor(), forControlState: .Normal)
        self.captureButton.setBackgroundColor(UIColor(white: 0.6, alpha: 1), forControlState: .Highlighted)
        self.captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        rootView.addSubview(self.cameraView)
        rootView.addSubview(self.colorTarget)
        rootView.addSubview(self.captureButton)
        
        // color target constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 20))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 20))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: .CenterX, relatedBy: .Equal, toItem: rootView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorTarget, attribute: .CenterY, relatedBy: .Equal, toItem: rootView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        // capture button constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.captureButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 70))
        rootView.addConstraint(NSLayoutConstraint(item: self.captureButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 70))
        rootView.addConstraint(NSLayoutConstraint(item: self.captureButton, attribute: .CenterX, relatedBy: .Equal, toItem: rootView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.captureButton, attribute: .CenterY, relatedBy: .Equal, toItem: rootView, attribute: .Bottom, multiplier: 1.0, constant: -TAB_HEIGHT - 50))
        
        // gestures
        let tapGR = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        rootView.addGestureRecognizer(tapGR)
        
        self.view = rootView
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        processMGR = ColorProcessManager()
        processMGR.delegate = self
        
        camera.outputImageOrientation = .Portrait
        
        do {
            try camera.inputCamera.lockForConfiguration()
            camera.inputCamera.subjectAreaChangeMonitoringEnabled = true
            camera.inputCamera.unlockForConfiguration()
        } catch let e {
            print("Error: \(e)")
        }
        
        camera.addTarget(self.cameraView)
        camera.addTarget(self.cropFilter)
        camera.startCameraCapture()
        
        captureButton.addTarget(self, action: Selector("captureSample"), forControlEvents: .TouchUpInside)
        
        thumbnailFilter.cropRegion = CGRect(x: 0.0, y: 0.3, width: 1.0, height: 0.4)
        
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
    
    // MARK: - Private Methods
    
    func captureSample() {
        
        if self.capturing {
            return
        }
        
        self.capturing = true
        self.camera.addTarget(self.thumbnailFilter)
        self.camera.capturePhotoAsImageProcessedUpToFilter(self.thumbnailFilter, withCompletionHandler: { [unowned self] (image, error) -> Void in
            
            if error != nil {
                print("sample capture error: \(error.localizedDescription)")
            } else {
                self.delegate?.cameraViewController(self, capturedSampleWithColor: self.processMGR.color, thumbnail: image)
            }
            
            self.capturing = false
            self.camera.removeTarget(self.thumbnailFilter)
            
        })
        
    }
    
    func focusAtPoint(point: CGPoint) {
        
        // focusing indicator
        self.focusingIndicator?.shouldRemoveAnimated(false)
        self.focusingIndicator = FocusingIndicator()
        self.focusingIndicator!.center = point
        self.view.addSubview(self.focusingIndicator!)
        
        let captureDevice = self.camera.inputCamera
        if captureDevice.focusPointOfInterestSupported && captureDevice.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) {
            
            do {
                try captureDevice.lockForConfiguration()
                let normalizedPoint = CGPoint(x: point.x/SCR_WIDTH, y: point.y/SCR_HEIGHT)
                captureDevice.focusPointOfInterest = normalizedPoint
                captureDevice.focusMode = .AutoFocus
                captureDevice.unlockForConfiguration()
            } catch let e {
                print(e)
            }
            
        }
        
    }
    
    func beginAverageColorCaptureAtPoint(point: CGPoint) {
        
        let normalizedPoint = CGPoint(x: point.x/SCR_WIDTH, y: point.y/SCR_HEIGHT)
        
        let aspectRatio = self.cameraView.frame.width / self.cameraView.frame.height
        let dx: CGFloat = 0.01
        let dy: CGFloat = dx * aspectRatio
        
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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
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
        let tapLocation = sender.locationInView(self.view)
        self.focusAtPoint(tapLocation)
    }
   
    // MARK: - ColorProcessManager Delegate
    
    func colorProcessManager(manager: ColorProcessManager, updatedColor color: UIColor?) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.colorTarget.updateWithColor(color)
            self.captureButton.updateWithColor(color)
            
            self.delegate?.cameraViewController(self, targetUpdatedWithColor: color)
            
        }
        
    }
    
}

