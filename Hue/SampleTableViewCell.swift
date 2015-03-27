//
//  SampleTableViewCell.swift
//  HUE
//
//  Created by James Taylor on 2015-03-24.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

protocol SampleTableViewCellDelegate: class {
    
    func sampleTableViewCellRequestedDelete(cell: SampleTableViewCell)
    
}

class SampleTableViewCell: UITableViewCell {
    
    weak var delegate: SampleTableViewCellDelegate?
    weak var sample: Sample? {
        didSet {
            self.sampleUpdated()
        }
    }
    
    var cancelContainer: CALayer
    var cancelLayer: CAShapeLayer
    var sampleContainer: UIView
    var sampleView: SampleView
    var thumbnailView: UIImageView
    var targetView: ColorTarget
    
    var gestureContainer: UIView
    
    // mutable constraint
    var sampleContainerWidthConstraint: NSLayoutConstraint!
    
    init(reuseIdentifier: String?) {
        
        self.cancelContainer = CALayer()
        self.cancelLayer = CAShapeLayer()
        self.sampleContainer = UIView()
        self.sampleView = SampleView()
        self.thumbnailView = UIImageView()
        self.targetView = ColorTarget()
        
        self.gestureContainer = UIView()
        
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        
        self.cancelLayer.bounds.size = CGSize(width: 20, height: 20)
        var cancelPath = UIBezierPath()
        cancelPath.moveToPoint(CGPoint(x: 10, y: 0))
        cancelPath.addLineToPoint(CGPoint(x: 10, y: 20))
        cancelPath.moveToPoint(CGPoint(x: 0, y: 10))
        cancelPath.addLineToPoint(CGPoint(x: 20, y: 10))
        self.cancelLayer.path = cancelPath.CGPath
        self.cancelLayer.lineWidth = 2
        self.cancelLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI/4), 0, 0, 1)
        
        self.sampleContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.sampleView.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.sampleView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        self.thumbnailView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.thumbnailView.clipsToBounds = true
        self.thumbnailView.contentMode = .ScaleAspectFill
        
        self.targetView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.gestureContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.contentView.layer.addSublayer(self.cancelContainer)
        self.cancelContainer.addSublayer(self.cancelLayer)
        self.contentView.addSubview(self.sampleContainer)
        self.sampleContainer.addSubview(self.sampleView)
        self.contentView.addSubview(self.thumbnailView)
        self.thumbnailView.addSubview(self.targetView)
        
        self.contentView.addSubview(self.gestureContainer)
        
        self.setupConstraints()
        
        // gestures
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        var swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe:"))
        swipeGestureRecognizer.direction = .Left
        
        self.gestureContainer.addGestureRecognizer(tapGestureRecognizer)
        self.gestureContainer.addGestureRecognizer(swipeGestureRecognizer)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.cancelContainer.frame = CGRect(x: self.frame.width - 70, y: 0, width: 70, height: self.frame.height)
        self.cancelLayer.position = CGPoint(x: self.cancelContainer.bounds.width/2, y: self.cancelContainer.bounds.height/2)
        
    }
    
    func setupConstraints() {
        
        // sampleContainer constraints
        self.sampleContainerWidthConstraint = NSLayoutConstraint(item: self.sampleContainer, attribute: .Width, relatedBy: .Equal, toItem: self.contentView, attribute: .Width, multiplier: 1, constant: 0)
        self.contentView.addConstraint(self.sampleContainerWidthConstraint)
        self.contentView.addConstraint(NSLayoutConstraint(item: self.sampleContainer, attribute: .Height, relatedBy: .Equal, toItem: self.contentView, attribute: .Height, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.sampleContainer, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.sampleContainer, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1, constant: 0))
        
        // gestureContainer constraints
        self.contentView.addConstraint(NSLayoutConstraint(item: self.gestureContainer, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 70))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.gestureContainer, attribute: .Height, relatedBy: .Equal, toItem: self.contentView, attribute: .Height, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.gestureContainer, attribute: .Right, relatedBy: .Equal, toItem: self.contentView, attribute: .Right, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.gestureContainer, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1, constant: 0))
        
        // thumbnailView constraints
        self.contentView.addConstraint(NSLayoutConstraint(item: self.thumbnailView, attribute: .Width, relatedBy: .Equal, toItem: self.contentView, attribute: .Width, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.thumbnailView, attribute: .Height, relatedBy: .Equal, toItem: self.contentView, attribute: .Height, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.thumbnailView, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.thumbnailView, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1, constant: 0))
        
        // targetView constraints
        self.thumbnailView.addConstraint(NSLayoutConstraint(item: self.targetView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 20))
        self.thumbnailView.addConstraint(NSLayoutConstraint(item: self.targetView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 20))
        self.thumbnailView.addConstraint(NSLayoutConstraint(item: self.targetView, attribute: .CenterX, relatedBy: .Equal, toItem: self.thumbnailView, attribute: .CenterX, multiplier: 1, constant: 0))
        self.thumbnailView.addConstraint(NSLayoutConstraint(item: self.targetView, attribute: .CenterY, relatedBy: .Equal, toItem: self.thumbnailView, attribute: .CenterY, multiplier: 1, constant: 0))
        
    }
    
    // MARK: UITableViewCell Methods
    
    override func setSelected(selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
        UIView.transitionWithView(self.thumbnailView, duration: 0.2, options: .TransitionCrossDissolve, animations: {
            self.thumbnailView.image = self.selected ? self.sample?.thumbnailImage : nil
            self.targetView.updateWithColor( self.selected ? self.sample?.color : nil)
        }, completion: nil)
                
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        self.sampleContainerWidthConstraint?.constant = self.editing ? -70 : 0
        self.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.cancelLayer.strokeColor = self.editing ? UIColor(hue: 0.0, saturation: 1.0, brightness: 0.6, alpha: 1).CGColor : UIColor.whiteColor().CGColor
            self.sampleView.locked = self.editing
            self.layoutIfNeeded()
        }, completion: nil)
        
        self.gestureContainer.userInteractionEnabled = self.editing
        
    }
    
    // MARK: - Private Methods
    
    func sampleUpdated() {
        
        self.sampleView.color = self.sample?.color
        self.contentView.backgroundColor = sample?.color?.darkerColor()
        
        self.cancelContainer.transform = CATransform3DIdentity
        self.sampleView.transform = CGAffineTransformIdentity
    }

    
    func animateDeletion() {
        self.cancelContainer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
    }
    
    // MARK: - Handlers
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
            
        case UISwipeGestureRecognizerDirection.Left:
            UIView.animateWithDuration(0.2) { self.sampleView.transform = CGAffineTransformMakeTranslation(-400, 0) }
            self.animateDeletion()
            self.delegate?.sampleTableViewCellRequestedDelete(self)
            
        default:
            break
            
        }
            
    }
    
    func handleSingleTap(sender: UITapGestureRecognizer) {
        self.animateDeletion()
        self.delegate?.sampleTableViewCellRequestedDelete(self)
    }
  
}
