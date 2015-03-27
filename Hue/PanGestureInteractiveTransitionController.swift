//
//  PanGestureInteractiveTransitionController.swift
//  HUE
//
//  Created by James Taylor on 2015-03-27.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class PanGestureInteractiveTransitionController: AWPercentDrivenInteractiveTransition {
   
    private var gestureRecognizedBlock: ((UIPanGestureRecognizer) -> Void)!
    private var recognizer: UIPanGestureRecognizer!
    
    var topToBottomTransition: Bool = true
    
    init(gestureRecognizerInView view: UIView, recognizedBlock gestureRecognizedBlock: (UIPanGestureRecognizer) -> Void) {
        
        super.init()
        
        self.gestureRecognizedBlock = gestureRecognizedBlock
        self.recognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        view.addGestureRecognizer(self.recognizer)
        
    }
    
    override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        self.topToBottomTransition = self.recognizer.velocityInView(self.recognizer.view!).y > 0
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .Began:
            self.gestureRecognizedBlock(sender)
            
        case .Changed:
            let translation = sender.translationInView(sender.view!)
            var d = translation.y/SCR_HEIGHT
            if !self.topToBottomTransition { d *= -1 }
            self.updateInteractiveTransition(d)
            
        default:
            let velocity = sender.velocityInView(sender.view!)
            if self.topToBottomTransition ^ (velocity.y < 0) {
                self.finishInteractiveTransition()
            } else {
                self.cancelInteractiveTransition()
            }
            
        }
        
    }
    
}
