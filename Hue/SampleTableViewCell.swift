//
//  SampleTableViewCell.swift
//  HUE
//
//  Created by James Taylor on 2015-03-24.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class SampleTableViewCell: UITableViewCell {
    
    var sampleView: SampleView
    
    init(reuseIdentifier: String?) {
        
        self.sampleView = SampleView()
        
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        
        self.sampleView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.contentView.addSubview(self.sampleView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        
        // sampleView constraints
        self.contentView.addConstraint(NSLayoutConstraint(item: self.sampleView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.sampleView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.sampleView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.sampleView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        
    }

}
