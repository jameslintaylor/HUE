//
//  ViewController.swift
//  Hue
//
//  Created by James Lin Taylor on 2015-03-16.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

import GPUImage

class ViewController: UIViewController {

    var camera: GPUImageStillCamera!
    var cropFilter: GPUImageCropFilter!
    var focusingChangedContext: UnsafeMutablePointer<()>!
    
    var cameraView: GPUImageView!
    var focusingIndicator: FocusingIndicator?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
        
        self.cameraView = GPUImageView(frame: self.view.bounds)
        
        self.view.addSubview(self.cameraView)
        
        self.camera.addTarget(self.cameraView)
        self.camera.addTarget(self.cropFilter)
        self.camera.startCameraCapture()
        
        // Gestures
        var tapGR = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        var pressGR = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        
        self.view.addGestureRecognizer(tapGR)
        self.view.addGestureRecognizer(pressGR)
        
        // Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleSubjectAreaChangedNotification:"), name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: nil)
        self.camera.inputCamera.addObserver(self, forKeyPath: "adjustingFocus", options: NSKeyValueObservingOptions.New, context: self.focusingChangedContext)
        
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, forKeyPath: AVCaptureDeviceSubjectAreaDidChangeNotification)
        self.camera.removeObserver(self, forKeyPath: "adjustingFocus", context: self.focusingChangedContext)
        
    }
    
    // MARK: Private Methods
    
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
        
        var averageColorOperation = GPUImageAverageColor()
        averageColorOperation.colorAverageProcessingFinishedBlock = { (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat, time: CMTime) -> Void in
            
            let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            var hsba = [CGFloat](count: 4, repeatedValue: 0.0)
            color.getHue(&hsba[0], saturation: &hsba[1], brightness: &hsba[2], alpha: &hsba[3])
            
            NSLog("hue: \(hsba[0]*360.0), saturation: \(hsba[1]), brightness: \(hsba[2])")
            
        }
        
        self.cropFilter.addTarget(averageColorOperation)
        
    }
    
    // MARK: Notification Handling
    
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
    
    // MARK: Gesture Handling
    
    func handleSingleTap(sender: UITapGestureRecognizer) {
        
        var tapLocation = sender.locationInView(self.view)
        self.focusAtPoint(tapLocation)
        
        // stop average color operations
        self.cropFilter.removeAllTargets()
        
    }
    
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .Began {
            
            var pressLocation = sender.locationInView(self.view)
            self.beginAverageColorCaptureAtPoint(pressLocation)
            
        }
        
    }
    
}

