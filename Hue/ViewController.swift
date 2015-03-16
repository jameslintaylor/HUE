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
    var cameraView: GPUImageView!

    var imageView: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.camera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPreset1920x1080, cameraPosition: AVCaptureDevicePosition.Back)
        self.camera.outputImageOrientation = UIInterfaceOrientation.Portrait
        
        self.cropFilter = GPUImageCropFilter()
        
        self.cameraView = GPUImageView(frame: self.view.bounds)
        self.imageView = UIImageView(frame: CGRect(origin: CGPointZero, size: CGSize(width: 80, height: 80)))
        
        self.view.addSubview(self.cameraView)
        self.view.addSubview(self.imageView)
        
        self.camera.addTarget(self.cameraView)
        self.camera.addTarget(self.cropFilter)
        self.camera.startCameraCapture()
        
        // Gestures
        var tapGR = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        var pressGR = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        
        self.view.addGestureRecognizer(tapGR)
        self.view.addGestureRecognizer(pressGR)
        
    }
    
    deinit {
        
        //
        
    }
    
    // MARK: Private Methods
    
    func focusAtPoint(point: CGPoint) {
        
        var captureDevice = self.camera.inputCamera
        
        if captureDevice.focusPointOfInterestSupported & captureDevice.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) {
            
            var error: NSError?
            
            if captureDevice.lockForConfiguration(&error) {
                
                captureDevice.focusPointOfInterest = point
                captureDevice.focusMode = AVCaptureFocusMode.AutoFocus
                captureDevice.unlockForConfiguration()
                
            } else {
                
                NSLog("Focus Error: \(error?.localizedDescription)")
                
            }
            
        }
        
    }
    
    func getAverageColorAtPoint(point: CGPoint) {
        
        let subImage = self.getImageAtRegion(CGRect(origin: CGPoint(x: point.x - 0.01, y: point.y - 0.01), size: CGSize(width: 0.02, height: 0.02)))
        self.imageView.image = subImage
        self.getAverageColorOfImage(subImage)
        
    }
    
    func getImageAtRegion(region: CGRect) -> UIImage {
        
        self.cropFilter.cropRegion = region
        self.cropFilter.useNextFrameForImageCapture()
        return self.cropFilter.imageFromCurrentFramebuffer()
        
    }
    
    func getAverageColorOfImage(image: UIImage) {
        
        var stillImageSource = GPUImagePicture(image: image)
        
        var averageColorOperation = GPUImageAverageColor()
        averageColorOperation.colorAverageProcessingFinishedBlock = { (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat, time: CMTime) -> Void in
            
            let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            var hsba = [CGFloat](count: 4, repeatedValue: 0.0)
            color.getHue(&hsba[0], saturation: &hsba[1], brightness: &hsba[2], alpha: &hsba[3])
            
            NSLog("hue: \(hsba[0]*360.0), saturation: \(hsba[1]), brightness: \(hsba[2])")
            
        }
        
        stillImageSource.addTarget(averageColorOperation)
        stillImageSource.processImage()
        
    }
    
    // MARK: Gesture Handling
    
    func handleSingleTap(sender: UITapGestureRecognizer) {
        
        var tapLocation = sender.locationInView(self.view)
        var normalizedLocation = CGPoint(x: tapLocation.x/self.view.bounds.width, y: tapLocation.y/self.view.bounds.height)
        self.focusAtPoint(normalizedLocation)
        
    }
    
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .Began {
            
            var pressLocation = sender.locationInView(self.view)
            var normalizedLocation = CGPoint(x: pressLocation.x/self.view.bounds.width, y: pressLocation.y/self.view.bounds.height)
            self.getAverageColorAtPoint(normalizedLocation)
            
        }
        
    }
    
}

