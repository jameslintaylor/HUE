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
    /**
     Tells the delegate when the manager's color value was updated.
     */
    func colorProcessManagerUpdatedColor(manager: ColorProcessManager)
}

class ColorProcessManager: NSObject {
    /**
     The manager's current color value. Note that this is a computed property so users should 
     compute it once (per cycle) and reuse where possible.
     */
    var color: UIColor {
        get {
            return UIColor(red: red, green: green, blue: blue, alpha: 1)
        }
    }
    
    /**
     The object that acts as the delegate of the manager.
     
     The delegate must adopt the `ColorProcessManagerDelegate` protocol. The delegate is not retained.
     */
    weak var delegate: ColorProcessManagerDelegate?
    
    // Color components
    private var red: CGFloat = 0
    private var green: CGFloat = 0
    private var blue: CGFloat = 0
    
    lazy var averageColorProcess: GPUImageAverageColor = {
        var process = GPUImageAverageColor()
        process.colorAverageProcessingFinishedBlock = { [weak self] (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat, time: CMTime) -> Void in
            guard let strongSelf = self else {
                return
            }
            
            // Perform a low pass filter of sorts on the new color to smoothen transitions between colors.
            strongSelf.red = strongSelf.red*0.8 + red*0.2
            strongSelf.green = strongSelf.green*0.8 + green*0.2
            strongSelf.blue = strongSelf.blue*0.8 + blue*0.2
            
            strongSelf.delegate?.colorProcessManagerUpdatedColor(strongSelf)
        }
        
        return process
    }()
}
