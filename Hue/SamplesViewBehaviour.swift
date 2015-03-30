//
//  SamplesViewBehaviour.swift
//  HUE
//
//  Created by James Taylor on 2015-03-29.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class SamplesViewBehaviour: UIDynamicBehavior {
   
    var view, tab: UIDynamicItem
    
    var attachmentBehaviour: UIAttachmentBehavior!
    var propertiesBehaviour: UIDynamicItemBehavior!
    
    var displayLink: CADisplayLink?
    
    init(view: UIDynamicItem, tab: UIDynamicItem) {
        
        self.view = view
        self.tab = tab
        
        super.init()
        
        self.setupChildBehaviours()
        self.addChildBehavior(self.attachmentBehaviour)
        self.addChildBehavior(self.propertiesBehaviour)
        
    }
    
    // MARK: - Private Methods
    
    func setupChildBehaviours() {
        
        self.attachmentBehaviour = UIAttachmentBehavior(item: self.view, attachedToAnchor: CGPoint(x: self.tab.center.x, y: self.tab.center.y - TAB_HEIGHT + self.view.bounds.height/2))
        self.attachmentBehaviour.length = 0
        self.attachmentBehaviour.damping = 1
        
        self.propertiesBehaviour = UIDynamicItemBehavior(items: [self.view])
        self.propertiesBehaviour.density = 0
        self.propertiesBehaviour.allowsRotation = false
        
    }
    
    func updateAnchorPoint() {
        self.attachmentBehaviour.anchorPoint = CGPoint(x: self.tab.center.x, y: self.tab.center.y - TAB_HEIGHT/2 + self.view.bounds.height/2)
    }
    
    // MARK: - Public Methods
    
    func startAnchorPointUpdates() {
        self.displayLink = CADisplayLink(target: self, selector: Selector("updateAnchorPoint"))
        self.displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func endAnchorPointUpdates() {
        self.displayLink?.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
}
