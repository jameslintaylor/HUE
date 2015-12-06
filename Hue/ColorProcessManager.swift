//
//  ColorProcessManager.swift
//  Hue
//
//  Created by James Lin Taylor on 2015-03-16.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit
import GPUImage

protocol ColorProcessManagerDelegate: class {
    func colorProcessManager(manager: ColorProcessManager, updatedColor color: UIColor?)
}

class ColorProcessManager: NSObject {
    weak var delegate: ColorProcessManagerDelegate?
    var color: UIColor?
    
    lazy var averageColorProcess: GPUImageAverageColor = {
        
        var process = GPUImageAverageColor()
        process.colorAverageProcessingFinishedBlock = { (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat, time: CMTime) -> Void in
            
            let averageColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            
            // Perform a low pass filter of sorts on the new color to smoothen transitions between colors.
            self.color = UIColor.averageColorBetween(self.color, withColor: averageColor, weightedBy: 0.2)
            self.delegate?.colorProcessManager(self, updatedColor: self.color)
        }
        
        return process
    }()
    
}
