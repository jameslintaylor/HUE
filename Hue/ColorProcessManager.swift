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
    
    func colorProcessManager(manager: ColorProcessManager, computedAverageColor color: UIColor?)
    
}

class ColorProcessManager: NSObject {
   
    weak var delegate: ColorProcessManagerDelegate?
    
    override init() {

        super.init()

    }
    
    // MARK: Public methods
    
    func averageColorProcess() -> GPUImageAverageColor {
        
        var averageColorOperation = GPUImageAverageColor()
        averageColorOperation.colorAverageProcessingFinishedBlock = { (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat, time: CMTime) -> Void in
            
            let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            self.delegate?.colorProcessManager(self, computedAverageColor: color)
            
//            var hsba = [CGFloat](count: 4, repeatedValue: 0.0)
//            color.getHue(&hsba[0], saturation: &hsba[1], brightness: &hsba[2], alpha: &hsba[3])
//            NSLog("hue: \(hsba[0]*360.0), saturation: \(hsba[1]), brightness: \(hsba[2])")
            
        }
        
        return averageColorOperation
        
    }
    
}
