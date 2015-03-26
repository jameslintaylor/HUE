//
//  SamplesViewController.swift
//  Hue
//
//  Created by James Taylor on 2015-03-17.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class SamplesViewController: UIViewController, SamplesTableViewManagerDelegate {
    
    let tableViewManager = SamplesTableViewManager()
    
    var tableView: UITableView!
    var editingSwitch: EditingSwitch!
    
    // mutable constraints
    var editingSwitchTopConstraint: NSLayoutConstraint!
    
    override func loadView() {
        
        var rootView = UIView()
        
        self.tableView = UITableView()
        self.tableView.contentInset = UIEdgeInsets(top: SAMPLE_HEIGHT, left: 0, bottom: 0, right: 0)
        self.tableView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        self.tableView.separatorStyle = .None
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.tableView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        self.editingSwitch = EditingSwitch()
        self.editingSwitch.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        rootView.addSubview(self.tableView)
        rootView.addSubview(self.editingSwitch)
        
        // editing switch constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.editingSwitch, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 80))
        rootView.addConstraint(NSLayoutConstraint(item: self.editingSwitch, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40))
        self.editingSwitchTopConstraint = NSLayoutConstraint(item: self.editingSwitch, attribute: .Top, relatedBy: .Equal, toItem: rootView, attribute: .Top, multiplier: 1, constant: SAMPLE_HEIGHT)
        rootView.addConstraint(self.editingSwitchTopConstraint)
        rootView.addConstraint(NSLayoutConstraint(item: self.editingSwitch, attribute: .Right, relatedBy: .Equal, toItem: rootView, attribute: .Right, multiplier: 1, constant: -10))
        
        self.view = rootView
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableViewManager.tableView = self.tableView
        self.tableViewManager.delegate = self
        self.tableView.dataSource = self.tableViewManager
        self.tableView.delegate = self.tableViewManager
        
        self.editingSwitch.addTarget(self, action: Selector("editingSwitchToggled:"), forControlEvents: .ValueChanged)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.editingSwitch.on = false
    }
    
    // MARK: - Handlers
    
    func editingSwitchToggled(editingSwitch: EditingSwitch) {
        self.tableView.setEditing(editingSwitch.on, animated: true)
    }
    
    // MARK: - SamplesTableViewManager Delegate 
    
    func tableView(tableView: UITableView, didScrollToYOffset yOffset: CGFloat) {
        self.editingSwitchTopConstraint.constant = max(SAMPLE_HEIGHT, SAMPLE_HEIGHT - yOffset)
    }
    
}
