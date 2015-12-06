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
    var samplesLabelBackground: UIView!
    var samplesLabel: UILabel!
    var pullDownLabel: UILabel!
    var popUpLabel: UILabel!
    var sampleView: SampleView!
    var tabBar: UIView!
    var tab: DraggableView!
    
    // mutable constraints
    var editingSwitchTopConstraint: NSLayoutConstraint!
    
    override func loadView() {
        
        let rootView = UIView()
        rootView.backgroundColor = UIColor.blackColor()
        
        self.tableView = UITableView()
        self.tableView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        self.tableView.separatorStyle = .None
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
        tableView.allowsSelection = true
        tableView.allowsSelectionDuringEditing = false
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = 80
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.editingSwitch = EditingSwitch()
        self.editingSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        self.samplesLabelBackground = UIView()
        self.samplesLabelBackground.backgroundColor = UIColor(white: 0.1, alpha: 1)
        self.samplesLabelBackground.translatesAutoresizingMaskIntoConstraints = true
        self.samplesLabelBackground.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.samplesLabel = UILabel()
        self.samplesLabel.font = UIFont(name: "GillSans-Italic", size: 24)
        self.samplesLabel.textAlignment = .Center
        self.samplesLabel.textColor = UIColor(white: 0.6, alpha: 1)
        self.samplesLabel.translatesAutoresizingMaskIntoConstraints = true
        self.samplesLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.pullDownLabel = UILabel()
        self.pullDownLabel.text = "\n\n pull down to return to the camera"
        self.pullDownLabel.numberOfLines = 3
        self.pullDownLabel.font = UIFont(name: "GillSans-Italic", size: 20)
        self.pullDownLabel.textAlignment = .Center
        self.pullDownLabel.textColor = UIColor(white: 0.6, alpha: 1)
        self.pullDownLabel.translatesAutoresizingMaskIntoConstraints = true
        self.pullDownLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.popUpLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: TAB_HEIGHT), size: CGSize(width: 0, height: 40)))
        self.popUpLabel.numberOfLines = 1
        self.popUpLabel.font = UIFont(name: "GillSans-Italic", size: 20)
        self.popUpLabel.textAlignment = .Center
        self.popUpLabel.textColor = UIColor(white: 0.6, alpha: 1)
        self.popUpLabel.alpha = 0
        self.popUpLabel.translatesAutoresizingMaskIntoConstraints = true
        self.popUpLabel.autoresizingMask = .FlexibleWidth
        
        self.sampleView = SampleView()
        self.sampleView.translatesAutoresizingMaskIntoConstraints = true
        self.sampleView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.tabBar = UIView()
        self.tabBar.layer.cornerRadius = 1
        self.tabBar.translatesAutoresizingMaskIntoConstraints = false
        
        self.tab = DraggableView(inView: rootView)
        self.tab.axes = .Vertical
        self.tab.viewToDrag = rootView
        self.tab.translatesAutoresizingMaskIntoConstraints = false
        
        rootView.addSubview(self.tableView)
        rootView.addSubview(self.editingSwitch)
        self.tab.addSubview(self.samplesLabelBackground)
        self.tab.addSubview(self.samplesLabel)
        self.tab.addSubview(self.pullDownLabel)
        self.tab.addSubview(self.popUpLabel)
        self.tab.addSubview(self.sampleView)
        self.tab.addSubview(self.tabBar)
        rootView.addSubview(self.tab)

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
        
        // tab bar constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.tabBar, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 60))
        rootView.addConstraint(NSLayoutConstraint(item: self.tabBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 2))
        rootView.addConstraint(NSLayoutConstraint(item: self.tabBar, attribute: .CenterX, relatedBy: .Equal, toItem: self.tab, attribute: .CenterX, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.tabBar, attribute: .Top, relatedBy: .Equal, toItem: self.tab, attribute: .Top, multiplier: 1, constant: 4))
        
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
    }
    
    // MARK: - Public Methods
    
    func setSampleColor(color: UIColor?) {
        
        if self.appearance == .ShowingSamples {
            return
        }
        
        self.sampleView.color = color
        self.tabBar.backgroundColor = color?.complimentaryColor()
    
    }
    
    func animateSampleSaved() {

        self.sampleView.alpha = 0

        let tempView = self.sampleView.snapshotViewAfterScreenUpdates(false)
        self.view.addSubview(tempView)
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            
            self.sampleView.alpha = 1
            tempView.center.y += TAB_HEIGHT
            
        }, completion: { finished in
        
            tempView.removeFromSuperview()
            
        })
        
    }
    
    func showPopUp() {
        
        UIView.animateKeyframesWithDuration(0.6, delay: 0, options: [], animations: {
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.2, animations: {
                self.popUpLabel.alpha = 1
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.4, relativeDuration: 0.2, animations: {
                self.popUpLabel.alpha = 0
            })
            
        }, completion: nil)
    
    }
    
    // MARK: - Private methods
    
    func updateAppearance() {
        UIView.animateWithDuration(0.2) {
            self.sampleView.alpha = self.appearance == .ShowingSamples ? 0 : 1
        }
        if self.appearance == .ShowingSamples {
            self.tabBar.backgroundColor = UIColor(white: 0.2, alpha: 1)
        }
    }

    
    // MARK: - Handlers
    
    func editingSwitchToggled(editingSwitch: EditingSwitch) {
        // Set editing mode on the table view and trigger an animated row height update cycle.
        tableView.beginUpdates()
        tableView.setEditing(editingSwitch.on, animated: true)
        tableView.endUpdates()
    }
    
    func handleSingleTap(sender: UITapGestureRecognizer) {
        self.delegate?.samplesViewControllerConfusedUser(self)
    }
    
    // MARK: - SamplesTableViewManager Delegate
    
    func tableView(tableView: UITableView, didScrollToYOffset yOffset: CGFloat) {
        
        if (yOffset < -tableView.bounds.height/5) && (self.appearance == .ShowingSamples) {
            self.delegate?.samplesViewControllerShouldHideSamples(self)
        }
       
        self.editingSwitchTopConstraint.constant = max(SAMPLE_HEIGHT, SAMPLE_HEIGHT - yOffset)
        
        let samplesLabelTranslation = max(0, -yOffset/2)
        let samplesLabelScale = max(1, 1 - yOffset/tableView.bounds.height)
        
        self.samplesLabel.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, samplesLabelTranslation), samplesLabelScale, samplesLabelScale)
        self.pullDownLabel.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, samplesLabelTranslation), 1/samplesLabelScale, 1/samplesLabelScale)
        
    }
    
    func tableView(tableView: UITableView, displayingNoData noData: Bool) {
        
        UIView.animateWithDuration(0.2) {
            
            self.samplesLabel.text = noData ? "no samples" : "my samples"
            self.editingSwitch.alpha = noData ? 0 : 1
            self.pullDownLabel.alpha = noData ? 1 : 0
            
        }
       
    }
    
}
