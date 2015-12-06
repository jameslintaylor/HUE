//
//  ColorTypes.swift
//  HUE
//
//  Created by James Lin Taylor on 2015-12-06.
//  Copyright © 2015 James Lin Taylor. All rights reserved.
//

import UIKit

enum ColorFormat {
    case RGB, HSB, HEX
    
    /**
     Returns a human readable description of the input color.
     */
    func descriptionForColor(color: UIColor?) -> String {
        var description: String = "UNKNOWN"
        
        switch self {
        case RGB:
            // RGB color description. Output should be of format "rgb(0, 0, 0)"
            var rgba = [CGFloat](count: 4, repeatedValue: 0.0)
            color?.getRed(&rgba[0], green: &rgba[1], blue: &rgba[2], alpha: &rgba[3])
            var rgba255 = rgba.map() { Int($0 * 255) }
            description = "rgb(\(rgba255[0]), \(rgba255[1]), \(rgba255[2]))"
        case HSB:
            // HSB color description. Output should be of format "hsb(0, 0, 0)"
            var hsba = [CGFloat](count: 4, repeatedValue: 0.0)
            color?.getHue(&hsba[0], saturation: &hsba[1], brightness: &hsba[2], alpha: &hsba[3])
            let h = Int(hsba[0] * 360)
            let s = Int(hsba[1] * 100)
            let b = Int(hsba[2] * 100)
            description = "hsb(\(h), \(s), \(b))"
        default:
            // Hexadecimal color description. Output should be of the format "#000000"
            if let hexDescription = color?.hexString() {
                description = "#\(hexDescription)"
            }
        }
        
        return description
    }
}
