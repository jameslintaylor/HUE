//
//  DraggableView.swift
//  HUE
//
//  Created by James Taylor on 2015-03-29.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

protocol DraggableViewDelegate: class {
    func draggableViewBeganDragging(view: DraggableView)
    func draggableView(view: DraggableView, draggingEndedWithVelocity velocity: CGPoint)
}

class DraggableView: UIView {

    weak var delegate: DraggableViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    override convenience init() {
        self.init(frame: CGRectZero)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        var panGR = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        self.addGestureRecognizer(panGR)
    }
    
    // MARK: - Handlers
    
    func handlePan(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(self.superview!)
        sender.setTranslation(CGPointZero, inView: self.superview!)
        
        switch sender.state {
            
        case .Began:
            self.delegate?.draggableViewBeganDragging(self)
            self.frame.origin.y = min(max(frame.origin.y + translation.y, 0), self.superview!.bounds.height - self.bounds.height)
            
        case .Changed:
            self.frame.origin.y = min(max(frame.origin.y + translation.y, 0), self.superview!.bounds.height - self.bounds.height)
            
        default:
            let velocity = sender.velocityInView(self.superview)
            self.delegate?.draggableView(self, draggingEndedWithVelocity: CGPoint(x: 0, y: velocity.y))
            
        }
        
    }
    
}
