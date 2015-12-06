//
//  EditingSwitch.swift
//  HUE
//
//  Created by James Taylor on 2015-03-25.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class EditingSwitch: UIControl {
    /**
     **Indicates whether the switch is on or off.**
     
     Changing this value triggers an automatic update to the switches appearance and an action 
     for [UIControlEvent.ValueChanged] to be sent to any listeners.
     */
    private(set) var on = false {
        didSet {
            self.update()
            self.sendActionsForControlEvents(.ValueChanged)
        }
    }
    
    private let label = UILabel()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Setup the label
        label.text = "edit"
        label.font = UIFont(name: "GillSans", size: 18)
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Left
        
        self.addSubview(label)
        setupConstraints()
        
        // Setup gesture recognizers
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        self.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handlers
    
    func handleSingleTap(sender: UITapGestureRecognizer) {
        self.on = !self.on
    }
    
    // MARK: - Private methods
    private func setupConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        label.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        label.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
    }
    
    /**
     Updates the text displayed within the status label depending on the state {on, off} of the switch.
     */
    private func update() {
        label.text = on ? "editing" : "edit"
    }
}
