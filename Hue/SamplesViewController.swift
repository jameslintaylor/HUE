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

protocol SamplesViewControllerDelegate: class {
    
    func samplesViewControllerShouldShowSamples(viewController: SamplesViewController)
    func samplesViewControllerShouldHideSamples(viewController: SamplesViewController)
    func samplesViewControllerShouldSwitchModes(viewController: SamplesViewController)
    func samplesViewControllerConfusedUser(viewController: SamplesViewController)
    
}

enum SamplesViewControllerAppearance {
    case ShowingSamples, HidingSamples
}

class SamplesViewController: UIViewController, SamplesTableViewManagerDelegate {
    
    weak var delegate: SamplesViewControllerDelegate?
    let tableViewManager = SamplesTableViewManager()
    
    var appearance: SamplesViewControllerAppearance = .HidingSamples {
        didSet {
            self.updateAppearance()
        }
    }
    
    var tableView: UITableView!
    var editingSwitch: EditingSwitch!
    var sampleView: SampleView!
    var samplesLabelBackground: UIView!
    var samplesLabel: UILabel!
    var tab: DraggableView!
    
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
        
        self.samplesLabelBackground = UIView()
        self.samplesLabelBackground.backgroundColor = UIColor(white: 0.1, alpha: 1)
        self.samplesLabelBackground.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.samplesLabel = UILabel()
        self.samplesLabel.font = UIFont(name: "GillSans-Italic", size: 24)
        self.samplesLabel.textAlignment = .Center
        self.samplesLabel.textColor = UIColor(white: 0.2, alpha: 1)
        self.samplesLabel.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.samplesLabel.userInteractionEnabled = false
        self.samplesLabel.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        self.tab = DraggableView(inView: rootView)
        self.tab.axes = .Vertical
        self.tab.view = rootView
        self.tab.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        rootView.addSubview(self.tableView)
        rootView.addSubview(self.editingSwitch)
        rootView.addSubview(self.tab)
        self.tab.addSubview(self.sampleView)
        self.tab.addSubview(self.samplesLabelBackground)
        self.tab.addSubview(self.samplesLabel)
        
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
        
        // samples label constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.samplesLabelBackground, attribute: .Width, relatedBy: .Equal, toItem: rootView, attribute: .Width, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.samplesLabelBackground, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: TAB_HEIGHT))
        rootView.addConstraint(NSLayoutConstraint(item: self.samplesLabelBackground, attribute: .Left, relatedBy: .Equal, toItem: rootView, attribute: .Left, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.samplesLabelBackground, attribute: .Top, relatedBy: .Equal, toItem: rootView, attribute: .Top, multiplier: 1, constant: 0))
        
        // tab constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.tab, attribute: .Width, relatedBy: .Equal, toItem: rootView, attribute: .Width, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.tab, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: TAB_HEIGHT))
        rootView.addConstraint(NSLayoutConstraint(item: self.tab, attribute: .Left, relatedBy: .Equal, toItem: rootView, attribute: .Left, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.tab, attribute: .Top, relatedBy: .Equal, toItem: rootView, attribute: .Top, multiplier: 1, constant: 0))
        
        // gestures recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        self.tab.addGestureRecognizer(tapGestureRecognizer)
        
        self.view = rootView
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableViewManager.tableView = self.tableView
        self.tableViewManager.delegate = self
        self.tableView.dataSource = self.tableViewManager
        self.tableView.delegate = self.tableViewManager
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.editingSwitch.addTarget(self, action: Selector("editingSwitchToggled:"), forControlEvents: .ValueChanged)
        self.editingSwitch.on = false
    }
    
    // MARK: - Public Methods
    
    func setSampleColor(color: UIColor?) {
        self.sampleView.color = color
    }
    
    func animateSampleSaved() {

        self.sampleView.alpha = 0

        var tempView = self.sampleView.snapshotViewAfterScreenUpdates(false)
        self.view.addSubview(tempView)
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: nil, animations: {
            
            self.sampleView.alpha = 1
            tempView.center.y += TAB_HEIGHT
            
        }, completion: { finished in
        
            tempView.removeFromSuperview()
            
        })
        
    }
    
    // MARK: - Private Methods
    
    func updateAppearance() {
        
        UIView.animateWithDuration(0.2) {
            self.samplesLabelBackground.alpha = self.appearance == .ShowingSamples ? 1 : 0
            self.samplesLabel.alpha = self.appearance == .ShowingSamples ? 1 : 0
        }
        
        self.editingSwitch.on = false
       
    }

    
    // MARK: - Handlers
    
    func editingSwitchToggled(editingSwitch: EditingSwitch) {
        self.tableViewManager.setEditing(self.editingSwitch.on)
    }
    
    func handleSingleTap(sender: UITapGestureRecognizer) {
        self.delegate?.samplesViewControllerConfusedUser(self)
    }
    
    // MARK: - SamplesTableViewManager Delegate
    
    func tableView(tableView: UITableView, didScrollToYOffset yOffset: CGFloat) {
        
        if yOffset < -SCR_HEIGHT/5 {
            self.delegate?.samplesViewControllerShouldHideSamples(self)
        }
        
        self.editingSwitchTopConstraint.constant = max(SAMPLE_HEIGHT, SAMPLE_HEIGHT - yOffset)
        
        var samplesLabelTranslation = max(0, -yOffset/2)
        var samplesLabelScale = max(1, 1 - yOffset/tableView.bounds.height)
        
        self.samplesLabel.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, samplesLabelTranslation), samplesLabelScale, samplesLabelScale)
        
    }
    
    func tableView(tableView: UITableView, displayingNoData noData: Bool) {
        
        UIView.animateWithDuration(0.2) {
            self.samplesLabel.text = noData ? "no samples" : "my samples"
            self.editingSwitch.alpha = noData ? 0 : 1
        }
       
    }
    
}
