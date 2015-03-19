//
//  ColorMenuViewController.swift
//  Hue
//
//  Created by James Taylor on 2015-03-19.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class ColorMenuViewController: UIViewController {

    enum ColorMode {
        
        case RGB, HSV, HEX
        
    }
    
    let colorLabel = UILabel()
    let colorSwatch = UIView()
    
    override func loadView() {
        
        let rootView = UIView()
        rootView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        self.colorLabel.font = UIFont(name: "GillSans-Italic", size: 20)
        self.colorLabel.textAlignment = .Right
        self.colorLabel.textColor = UIColor.whiteColor()
        self.colorLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.colorSwatch.layer.cornerRadius = 30
        self.colorSwatch.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        rootView.addSubview(self.colorLabel)
        rootView.addSubview(self.colorSwatch)
        
        // color label constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.colorLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -10))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorLabel, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))

        // color swatch constraints
        rootView.addConstraint(NSLayoutConstraint(item: self.colorSwatch, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 60))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorSwatch, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 60))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorSwatch, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        rootView.addConstraint(NSLayoutConstraint(item: self.colorSwatch, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Public Methods
    
    func updateWithColor(color: UIColor?) {
        
        self.colorSwatch.backgroundColor = color
        self.colorLabel.text = "hsv(12,102,25)"
        
    }
    
}
