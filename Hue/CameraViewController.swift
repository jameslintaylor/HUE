//
//  CameraViewController.swift
//  Hue
//
//  Created by James Lin Taylor on 2015-03-16.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

import GPUImage
import CoreData

class CameraViewController: UIViewController, ColorProcessManagerDelegate {

    var processMGR: ColorProcessManager!
    var managedObjectContext: NSManagedObjectContext!
    
    var camera: GPUImageStillCamera!
    var cropFilter: GPUImageCropFilter!
    var focusingChangedContext: UnsafeMutablePointer<()>!
    var movingColorTarget: Bool!
    
    var cameraView: GPUImageView!
    var focusingIndicator: FocusingIndicator?
    var colorIndicator: ColorIndicator?
        
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
        self.movingColorTarget = false
        
        self.cameraView = GPUImageView(frame: self.view.bounds)
        
        self.view.addSubview(self.cameraView)
        
        self.camera.addTarget(self.cameraView)
        self.camera.addTarget(self.cropFilter)
        self.camera.startCameraCapture()
        
        // Gestures
        var tapGR = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        var pressGR = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        pressGR.cancelsTouchesInView = false
        
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
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
        
        // color indicator
        self.colorIndicator?.shouldRemoveAnimated(false)
        self.colorIndicator = ColorIndicator()
        self.colorIndicator!.center = point
        self.view.addSubview(self.colorIndicator!)
        self.colorIndicator!.expand()
        
        let normalizedPoint = CGPoint(x: point.x/SCR_WIDTH, y: point.y/SCR_HEIGHT)
        let normalizedRegion = CGRect(x: normalizedPoint.x - 0.01, y: normalizedPoint.y - 0.01, width: 0.02, height: 0.02)
        self.cropFilter.cropRegion = normalizedRegion
        
        var averageColorOperation = self.processMGR.averageColorProcess()
        self.cropFilter.removeAllTargets()
        self.cropFilter.addTarget(averageColorOperation)
        
    }
    
    func moveAverageColorCaptureToPoint(point: CGPoint) {
        
        // color indicator
        self.colorIndicator?.center = point
        
        let normalizedPoint = CGPoint(x: point.x/SCR_WIDTH, y: point.y/SCR_HEIGHT)
        let normalizedRegion = CGRect(x: normalizedPoint.x - 0.02, y: normalizedPoint.y - 0.02, width: 0.04, height: 0.04)
        self.cropFilter.cropRegion = normalizedRegion
        
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
        
        var colorIndicatorRect = self.colorIndicator == nil ? CGRectZero : self.colorIndicator!.frame
        if CGRectContainsPoint(colorIndicatorRect, tapLocation) {
            
            // stop average color operations
            self.cropFilter.removeAllTargets()
            self.colorIndicator?.shrink()
            self.colorIndicator?.shouldRemoveAnimated(true)
            
        } else {
            
            self.focusAtPoint(tapLocation)

        }
        
    }
    
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .Began {
            
            var pressLocation = sender.locationInView(self.view)
            self.beginAverageColorCaptureAtPoint(pressLocation)
            
        }
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInView(self.view)
        
        var colorIndicatorRect = self.colorIndicator == nil ? CGRectZero : self.colorIndicator!.frame
        if self.movingColorTarget == true {
            
            self.moveAverageColorCaptureToPoint(touchLocation)
            
        } else if CGRectContainsPoint(colorIndicatorRect, touchLocation) {
            
            self.movingColorTarget = true
            self.colorIndicator?.shrink()
            
        }
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        if self.movingColorTarget == true {
            
            self.movingColorTarget = false
            self.colorIndicator?.expand()
            
        }
        
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        
        if self.movingColorTarget == true {
            
            self.movingColorTarget = false
            self.colorIndicator?.expand()
            
        }
        
    }
    
   
    // MARK: - ColorProcessManager Delegate
    
    func colorProcessManager(manager: ColorProcessManager, updatedColor color: UIColor?) {
        
        if let colorIndicator = self.colorIndicator {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                colorIndicator.setColor(color)
                
            })
            
        }
        
    }
    
}

