//
//  DraggableView.swift
//  HUE
//
//  Created by James Taylor on 2015-03-30.
//  Copyright (c) 2015 James Lin Taylor. Both rights reserved.
//

import UIKit

protocol DraggableViewDelegate: class {
    func draggableViewBeganDragging(view: DraggableView)
    func draggableView(view: DraggableView, draggingEndedWithVelocity velocity: CGPoint)
}

struct DraggableViewAxis : RawOptionSetType {
    
    private var value: UInt = 0
    
    init(_ value: UInt) { self.value = value }
    init(rawValue value: UInt) { self.value = value }
    init(nilLiteral: ()) { self.value = 0 }
    static var allZeros: DraggableViewAxis { return self(0) }
    static func fromMask(raw: UInt) -> DraggableViewAxis { return self(raw) }
    var rawValue: UInt { return self.value }
    
    static var Horizontal: DraggableViewAxis   { return self(0b0) }
    static var Vertical: DraggableViewAxis  { return self(0b1) }
    
}

class DraggableView: UIView, UIGestureRecognizerDelegate {
    
    weak var delegate: DraggableViewDelegate?
    
    var animator: UIDynamicAnimator
    var attachmentBehaviour: UIAttachmentBehavior?
    var axes: DraggableViewAxis = .Horizontal | .Vertical // default
    
    var viewToDrag: UIView!
    
    init(frame: CGRect, inView containerView: UIView) {
        
        self.animator = UIDynamicAnimator(referenceView: containerView)
        
        super.init(frame: frame)
        
        self.viewToDrag = self
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    convenience init(inView containerView: UIView) {
        self.init(frame: CGRectZero, inView: containerView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handlers
    
    func handlePan(sender: UIPanGestureRecognizer) {
        
        let translationInView = sender.translationInView(self)
        sender.setTranslation(CGPointZero, inView: self)
        
        switch sender.state {
            
        case .Began:
            
            self.attachmentBehaviour = UIAttachmentBehavior(item: self.viewToDrag, attachedToAnchor: CGPoint(x: self.viewToDrag.center.x, y: self.viewToDrag.center.y))
            self.animator.addBehavior(self.attachmentBehaviour)
            self.delegate?.draggableViewBeganDragging(self)
        
        case .Changed:
            
            if self.axes & .Horizontal != nil {
                self.attachmentBehaviour?.anchorPoint.x += translationInView.x
            }
            
            if self.axes & .Vertical != nil {
                self.attachmentBehaviour?.anchorPoint.y += translationInView.y
            }
            
        default:
            
            self.animator.removeBehavior(self.attachmentBehaviour)
            
            var velocity = sender.velocityInView(self)
            
            if self.axes & .Horizontal == nil {
                velocity.x = 0
            }
            
            if self.axes & .Vertical == nil {
                velocity.y = 0
            }
                        
            self.delegate?.draggableView(self, draggingEndedWithVelocity: velocity)
            
        }
        
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            
            var velocity = (panGestureRecognizer as UIPanGestureRecognizer).velocityInView(self)
            velocity.x = abs(velocity.x)
            velocity.y = abs(velocity.y)
            
            if (self.axes & .Horizontal != nil) && (velocity.x > velocity.y) {
                return true
            }
            
            if (self.axes & .Vertical != nil) && (velocity.y > velocity.x) {
                return true
            }
            
            return false
            
        }
        
        return true
        
    }
    
}
