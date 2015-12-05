//
//  SamplesViewBehaviour.swift
//  HUE
//
//  Created by James Taylor on 2015-03-29.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class SamplesViewBehaviour: UIDynamicBehavior {
   
    var view: UIDynamicItem
    var top: CGFloat
    var bottom: CGFloat
    
    var open: Bool = false {
        
        didSet {
        
            if self.open {
            
                self.removeChildBehavior(self.gravityBehaviour)
                self.addChildBehavior(self.topSnapBehaviour)
            
            } else {
            
                self.removeChildBehavior(self.topSnapBehaviour)
                self.addChildBehavior(self.gravityBehaviour)
                
            }
        }
    }
    
    var gravityBehaviour: UIGravityBehavior!
    var collisionBehaviour: UICollisionBehavior!
    var topSnapBehaviour: UISnapBehavior!
    var propertiesBehaviour: UIDynamicItemBehavior!
    
    init(view: UIDynamicItem, openTo top: CGFloat, closeTo bottom: CGFloat) {
        
        self.view = view
        self.top = top
        self.bottom = bottom
        
        super.init()
        
        self.setupChildBehaviours()
        self.addChildBehavior(self.gravityBehaviour)
        self.addChildBehavior(self.collisionBehaviour)
        self.addChildBehavior(self.propertiesBehaviour)

    }
    
    // MARK: - Private Methods
    
    func setupChildBehaviours() {
        
        self.gravityBehaviour = UIGravityBehavior(items: [self.view])
        self.gravityBehaviour.magnitude = 4
        
        self.collisionBehaviour = UICollisionBehavior(items: [self.view])
        self.collisionBehaviour.collisionMode = .Boundaries
        self.collisionBehaviour.addBoundaryWithIdentifier("bottom", fromPoint: CGPoint(x: 0, y: self.bottom + view.bounds.height), toPoint: CGPoint(x: view.bounds.width, y: self.bottom + view.bounds.height))
        
        self.topSnapBehaviour = UISnapBehavior(item: self.view, snapToPoint: CGPoint(x: self.view.center.x, y: self.top + self.view.bounds.height/2))
        self.topSnapBehaviour.damping = 0.2
        
        self.propertiesBehaviour = UIDynamicItemBehavior(items: [self.view])
        self.propertiesBehaviour.elasticity = 0.1
        self.propertiesBehaviour.allowsRotation = false
        
    }
    
    // MARK: - Public Methods
    
    func setInitialVelocity(velocity: CGFloat) {
        self.propertiesBehaviour.addLinearVelocity(CGPoint(x: 0, y: velocity), forItem: self.view)
    }
    
}
