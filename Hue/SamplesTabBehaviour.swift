//
//  SamplesTabBehaviour.swift
//  HUE
//
//  Created by James Taylor on 2015-03-29.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class SamplesTabBehaviour: UIDynamicBehavior {
   
    var tab: UIDynamicItem
    var attachmentPoint: CGPoint
    
    var open: Bool = false {
        didSet {
            if self.open {
                self.removeChildBehavior(self.gravityBehaviour)
                self.addChildBehavior(self.attachmentBehaviour)
            } else {
                self.removeChildBehavior(self.attachmentBehaviour)
                self.addChildBehavior(self.gravityBehaviour)
            }
        }
    }
    
    var gravityBehaviour: UIGravityBehavior!
    var collisionBehaviour: UICollisionBehavior!
    var attachmentBehaviour: UIAttachmentBehavior!
    var propertiesBehaviour: UIDynamicItemBehavior!
    
    init(tab: UIDynamicItem, openToPoint point: CGPoint) {
        
        self.tab = tab
        self.attachmentPoint = point
        
        super.init()
        
        self.setupChildBehaviours()
        self.addChildBehavior(self.gravityBehaviour)
        self.addChildBehavior(self.collisionBehaviour)
        self.addChildBehavior(self.propertiesBehaviour)

    }
    
    // MARK: - Private Methods
    
    func setupChildBehaviours() {
        
        self.gravityBehaviour = UIGravityBehavior(items: [self.tab])
        self.gravityBehaviour.magnitude = 4
        
        self.collisionBehaviour = UICollisionBehavior(items: [self.tab])
        self.collisionBehaviour.setTranslatesReferenceBoundsIntoBoundaryWithInsets(UIEdgeInsetsZero)
        
        self.attachmentBehaviour = UIAttachmentBehavior(item: self.tab, attachedToAnchor: self.attachmentPoint)
        self.attachmentBehaviour.length = 0
        self.attachmentBehaviour.damping = 0.6
        self.attachmentBehaviour.frequency = 5
        
        self.propertiesBehaviour = UIDynamicItemBehavior(items: [self.tab])
        self.propertiesBehaviour.elasticity = 0.1
        self.propertiesBehaviour.allowsRotation = false
        
    }
    
    // MARK: - Public Methods
    
    func setInitialVelocity(velocity: CGPoint) {
        self.propertiesBehaviour.addLinearVelocity(velocity, forItem: self.tab)
    }
    
}
