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
    
    lazy var averageColorProcess: GPUImageAverageColor = {
        
        var process = GPUImageAverageColor()
        process.colorAverageProcessingFinishedBlock = { (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat, time: CMTime) -> Void in
            
            let averageColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            self.color = self.color == nil ? averageColor : self.color!.blendWithColor(averageColor, weight: 0.2)
            self.delegate?.colorProcessManager(self, updatedColor: self.color)
        }
        
        return process
        
    }()
    
    var color: UIColor?
    
}

extension UIColor {
    
    /// returns the average color between the receiver and the specified color.
    func blendWithColor(color: UIColor, weight: CGFloat) -> UIColor? {
        
        var rgbaSelf = [CGFloat](count: 4, repeatedValue: 0.0)
        self.getRed(&rgbaSelf[0], green: &rgbaSelf[1], blue: &rgbaSelf[2], alpha: &rgbaSelf[3])
        
        var rgbaOther = [CGFloat](count: 4, repeatedValue: 0.0)
        color.getRed(&rgbaOther[0], green: &rgbaOther[1], blue: &rgbaOther[2], alpha: &rgbaOther[3])

        var r = rgbaSelf[0] * (1.0 - weight) + rgbaOther[0] * (weight)
        var g = rgbaSelf[1] * (1.0 - weight) + rgbaOther[1] * (weight)
        var b = rgbaSelf[2] * (1.0 - weight) + rgbaOther[2] * (weight)
        var a = rgbaSelf[3] * (1.0 - weight) + rgbaOther[3] * (weight)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
        
    }
    
}