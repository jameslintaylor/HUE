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
