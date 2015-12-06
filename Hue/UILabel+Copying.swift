//
//  UILabel+Copying.swift
//  HUE
//
//  Created by James Lin Taylor on 2015-12-06.
//  Copyright © 2015 James Lin Taylor. All rights reserved.
//

import UIKit

extension UILabel {
    public override func copy() -> AnyObject {
        let copy = UILabel(frame: frame)

        // These are not all the values of a UILabel, but they are the ones relevant for my purposes.
        copy.font = font
        copy.text = text
        copy.textColor = textColor
        copy.backgroundColor = backgroundColor
        
        return copy
    }
}