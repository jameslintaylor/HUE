//
//  SampleTableViewCell.swift
//  HUE
//
//  Created by James Taylor on 2015-03-24.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

// MARK: -

class SamplesTableViewCell: UITableViewCell {
    /**
     The `Sample` object associated with the cell.
     
     Changing this property triggers an automatic update to the cell's appearance.
     */
    weak var sample: Sample? {
        didSet {
            update()
        }
    }
    
    private let sampleContainer = UIView()
    private let sampleView = SampleView()
    private let thumbnailView = UIImageView()
    private let targetView = ColorTarget()
    private let gestureContainer = UIView()
    
    // Yuck! Mutable constraint
    private var sampleContainerWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Initializers
    
    init(reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        
        sampleView.translatesAutoresizingMaskIntoConstraints = true
        sampleView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        thumbnailView.clipsToBounds = true
        thumbnailView.contentMode = .ScaleAspectFill
        
        // MARK: What the hell is this container garbage
        contentView.addSubview(sampleContainer)
        sampleContainer.addSubview(sampleView)
        
        contentView.addSubview(thumbnailView)
        thumbnailView.addSubview(targetView)
        
        contentView.addSubview(gestureContainer)
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        // Sample container constraints
        sampleContainer.translatesAutoresizingMaskIntoConstraints = false
        sampleContainer.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor).active = true
        sampleContainer.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
        sampleContainer.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor).active = true
        
        // Sample container retained width constraint
        sampleContainerWidthConstraint = sampleContainer.widthAnchor.constraintEqualToAnchor(contentView.widthAnchor)
        sampleContainerWidthConstraint.active = true
        
        // Gesture container constraints
        gestureContainer.translatesAutoresizingMaskIntoConstraints = false
        gestureContainer.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor).active = true
        gestureContainer.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
        gestureContainer.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor).active = true
        gestureContainer.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor).active = true
        
        // Thumbnail view constraints
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor).active = true
        thumbnailView.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
        thumbnailView.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor).active = true
        thumbnailView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor).active = true
        
        // Target view constraints
        targetView.translatesAutoresizingMaskIntoConstraints = false
        targetView.widthAnchor.constraintEqualToConstant(20).active = true
        targetView.heightAnchor.constraintEqualToConstant(20).active = true
        targetView.centerXAnchor.constraintEqualToAnchor(thumbnailView.centerXAnchor).active = true
        targetView.centerYAnchor.constraintEqualToAnchor(thumbnailView.centerYAnchor).active = true
    }

    // MARK: - Private methods
    
    func update() {
        // Sample view
        sampleView.color = sample?.color
        contentView.backgroundColor = sample?.color?.darkerColor()
        
        // Cancel layer
        sampleView.transform = CGAffineTransformIdentity
    }
  
    // MARK: - UITableViewCell
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        print("Cell set selected: \(selected)")
        
        UIView.transitionWithView(self.thumbnailView, duration: 0.2, options: .TransitionCrossDissolve, animations: {
            self.thumbnailView.image = self.selected ? self.sample?.thumbnailImage : nil
            self.targetView.updateWithColor( self.selected ? self.sample?.color : nil)
            }, completion: nil)
        
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        self.sampleContainerWidthConstraint?.constant = self.editing ? -70 : 0
        self.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.sampleView.locked = self.editing
            self.layoutIfNeeded()
            }, completion: nil)
        
        self.gestureContainer.userInteractionEnabled = self.editing
    }
    
}
