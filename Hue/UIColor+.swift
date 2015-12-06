//
//  UIColor+.swift
//  HUE
//
//  Created by James Lin Taylor on 2015-12-06.
//  Copyright © 2015 James Lin Taylor. All rights reserved.
//

import UIKit

extension UIColor {
    /**
     Returns the weighted average between two input colors.
     
     The average is computed by taking a weighted average of the rgb values of the respective input colors seperately.
     
     - parameter firstColor: The first `UIColor` to be used in computing the average.
     - parameter secondColor: The second `UIColor` to be used in computing the average.
     - parameter weight: The weight (between 0.0 and 1.0) of the second color. A weight of 0.0 will essentially 'ignore' the second color, whereas a weight of 1.0 will take the second color exclusively. The default value is 0.5.
     */
    static func averageColorBetween(firstColor: UIColor?, withColor secondColor: UIColor?, var weightedBy weight: CGFloat = 0.5) -> UIColor? {
        // Bind the weight to a value between 0.0 and 1.0.
        weight = max(min(weight, 1.0), 0.0)
        
        // Get the rgba values of the first color
        var rgbaFirst = [CGFloat](count: 4, repeatedValue: 0.0)
        firstColor?.getRed(&rgbaFirst[0], green: &rgbaFirst[1], blue: &rgbaFirst[2], alpha: &rgbaFirst[3])
        
        // Get the rgba values of the second color
        var rgbaSecond = [CGFloat](count: 4, repeatedValue: 0.0)
        secondColor?.getRed(&rgbaSecond[0], green: &rgbaSecond[1], blue: &rgbaSecond[2], alpha: &rgbaSecond[3])
        
        // Compute the weighted average
        let r = rgbaFirst[0] * (1.0 - weight) + rgbaSecond[0]*weight
        let g = rgbaFirst[1] * (1.0 - weight) + rgbaSecond[1]*weight
        let b = rgbaFirst[2] * (1.0 - weight) + rgbaSecond[2]*weight
        let a = rgbaFirst[3] * (1.0 - weight) + rgbaSecond[3]*weight
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /**
     Returns a hexadecimal string value representing the input color.
     */
    func hexString() -> String {
        var rgba = [CGFloat](count: 4, repeatedValue: 0.0)
        self.getRed(&rgba[0], green: &rgba[1], blue: &rgba[2], alpha: &rgba[3])
        var rgba255 = rgba.map() { Int($0 * 255) }
        return NSString(format: "%02X%02X%02X", rgba255[0], rgba255[1], rgba255[2]) as String
    }
    
    /**
     Returns a color complimentary to the input color.
     */
    func complimentaryColor() -> UIColor? {
        var hsba = [CGFloat](count: 4, repeatedValue: 0.0)
        self.getHue(&hsba[0], saturation: &hsba[1], brightness: &hsba[2], alpha: &hsba[3])
        let diff = hsba[2] < 0.5 ? 1.0 - hsba[2] : -hsba[2]
        hsba[2] += diff/2
        return UIColor(hue: hsba[0], saturation: hsba[1], brightness: hsba[2], alpha: hsba[3])
    }
    
    /**
     Returns a color similar in hue and saturation but slightly lower in brightness than the input color.
     */
    func darkerColor() -> UIColor? {
        var hsba = [CGFloat](count: 4, repeatedValue: 0.0)
        self.getHue(&hsba[0], saturation: &hsba[1], brightness: &hsba[2], alpha: &hsba[3])
        hsba[2] = hsba[2]/2
        hsba[1] = hsba[1]/2
        return UIColor(hue: hsba[0], saturation: hsba[1], brightness: hsba[2], alpha: hsba[3])
    }
    
    /**
     Returns a color similar in hue and saturation but much lower in brightness than the input color.
     */
    func muchDarkerColor() -> UIColor? {
        var hsba = [CGFloat](count: 4, repeatedValue: 0.0)
        self.getHue(&hsba[0], saturation: &hsba[1], brightness: &hsba[2], alpha: &hsba[3])
        hsba[2] = hsba[2]/4
        hsba[1] = hsba[1]/4
        return UIColor(hue: hsba[0], saturation: hsba[1], brightness: hsba[2], alpha: hsba[3])
    }
    
    /**
     Returns a color similar in hue and saturation but slightly higher in brightness than the input color.
     */
    func lighterColor() -> UIColor? {
        var hsba = [CGFloat](count: 4, repeatedValue: 0.0)
        self.getHue(&hsba[0], saturation: &hsba[1], brightness: &hsba[2], alpha: &hsba[3])
        hsba[2] += (1.0 - hsba[2]) * 1/4
        hsba[1] += hsba[1]/2
        return UIColor(hue: hsba[0], saturation: hsba[1], brightness: hsba[2], alpha: hsba[3])
    }
    
    /**
     Returns a color similar in hue and saturation but much higher in brightness than the input color.
     */
    func muchLighterColor() -> UIColor? {
        var hsba = [CGFloat](count: 4, repeatedValue: 0.0)
        self.getHue(&hsba[0], saturation: &hsba[1], brightness: &hsba[2], alpha: &hsba[3])
        hsba[2] += (1.0 - hsba[2]) * 3/4
        hsba[1] += hsba[1]/4
        return UIColor(hue: hsba[0], saturation: hsba[1], brightness: hsba[2], alpha: hsba[3])
    }
}
