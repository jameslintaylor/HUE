//
//  CaptureGestureRecognizer.swift
//  HUE
//
//  Created by James Taylor on 2015-03-23.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import Foundation
import UIKit

class CaptureGestureRecognizer: UIGestureRecognizer {
    
    var rootLocation = CGPointZero
    var cancelTimer: NSTimer?
    var timerFired = false
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInView(touch.view)
        self.rootLocation = touchLocation
        self.cancelTimer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("timerFired:"), userInfo: nil, repeats: false)
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInView(touch.view)
        let distSquared = pow(touchLocation.x - self.rootLocation.x, 2) + pow(touchLocation.y - self.rootLocation.y, 2)
        
        if !self.timerFired & (distSquared > 4) {
            self.state = .Cancelled
        } else {
            self.state = .Changed
        }
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        if !self.timerFired {
            self.state = .Cancelled
        } else {
            self.state = .Ended
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        if !self.timerFired {
            self.state = .Cancelled
        } else {
            self.state = .Ended
        }
    }
    
    override func reset() {
        self.rootLocation = CGPointZero
        self.timerFired = false
        self.cancelTimer?.invalidate()
        self.cancelTimer = nil
    }
    
    // MARK: - Private Methods
    
    func timerFired(timer: NSTimer) {
        self.timerFired = true
        self.state = .Began
    }
    
}