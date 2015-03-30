//
//  SamplesViewController.swift
//  Hue
//
//  Created by James Taylor on 2015-03-17.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

let HEADER_HEIGHT: CGFloat = 40
let SAMPLE_HEIGHT: CGFloat = 100

protocol SamplesViewControllerDelegate: class {  }

class SamplesViewController: UIViewController, SamplesTableViewManagerDelegate {
    
    weak var delegate: SamplesViewControllerDelegate?
    let tableViewManager = SamplesTableViewManager()
    
    var tableView: UITableView!
    var editingSwitch: EditingSwitch!
    var sampleView: SampleView!
    
    // mutable constraints
    var editingSwitchTopConstraint: NSLayoutConstraint!
    
    override func loadView() {
        
        var rootView = UIView()
        rootView.backgroundColor = UIColor.blackColor()
        
        self.tableView = UITableView()
        self.tableView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        self.tableView.separatorStyle = .None
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.editingSwitch = EditingSwitch()
        self.editingSwitch.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.sampleView = SampleView()
        self.sampleView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        rootView.addSubview(self.tableView)
        rootView.addSubview(self.editingSwitch)
        rootView.addSubview(self.sampleView)
        
        // table view constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: .Width, relatedBy: .Equal, toItem: rootView, attribute: .Width, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: .Top, relatedBy: .Equal, toItem: rootView, attribute: .Top, multiplier: 1, constant: TAB_HEIGHT))
        rootView.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: .Left, relatedBy: .Equal, toItem: rootView, attribute: .Left, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: .Bottom, relatedBy: .Equal, toItem: rootView, attribute: .Bottom, multiplier: 1, constant: 0))
        
        // editing switch constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.editingSwitch, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 80))
        rootView.addConstraint(NSLayoutConstraint(item: self.editingSwitch, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40))
        self.editingSwitchTopConstraint = NSLayoutConstraint(item: self.editingSwitch, attribute: .Top, relatedBy: .Equal, toItem: rootView, attribute: .Top, multiplier: 1, constant: SAMPLE_HEIGHT)
        rootView.addConstraint(self.editingSwitchTopConstraint)
        rootView.addConstraint(NSLayoutConstraint(item: self.editingSwitch, attribute: .Right, relatedBy: .Equal, toItem: rootView, attribute: .Right, multiplier: 1, constant: -10))
        
        // sample view constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.sampleView, attribute: .Width, relatedBy: .Equal, toItem: rootView, attribute: .Width, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.sampleView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: TAB_HEIGHT))
        rootView.addConstraint(NSLayoutConstraint(item: self.sampleView, attribute: .Left, relatedBy: .Equal, toItem: rootView, attribute: .Left, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.sampleView, attribute: .Top, relatedBy: .Equal, toItem: rootView, attribute: .Top, multiplier: 1, constant: 0))
        
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
    
    // MARK: - Public Methods
    
    func setSampleColor(color: UIColor?) {
        self.sampleView.color = color
    }
    
    // MARK: - Handlers
    
    func editingSwitchToggled(editingSwitch: EditingSwitch) {
        self.tableViewManager.setEditing(self.editingSwitch.on)
    }
    
    // MARK: - SamplesTableViewManager Delegate 
    
    func tableView(tableView: UITableView, didScrollToYOffset yOffset: CGFloat) {
        self.editingSwitchTopConstraint.constant = max(SAMPLE_HEIGHT, SAMPLE_HEIGHT - yOffset)
    }
    
}
