//
//  Helper.swift
//  GreenImageDetectorTrials
//
//  Created by Bliss Chapman on 4/1/15.
//  Copyright (c) 2015 Bliss Chapman. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    init() {}
    
    func analyzeImageForGreenness(image: UIImage) -> CGFloat {
        var imageAlpha = CGFloat()
        var imageRed = CGFloat()
        var imageGreen = CGFloat()
        var imageBlue = CGFloat()
        
        var totalGreenness: CGFloat = 0.0
        
        for xCoordinate in 0...Int(image.size.width - 1) {
            for yCoordinate in 0...Int(image.size.height - 1) {
                var color = image.getPixelColor(CGPoint(x: xCoordinate, y: yCoordinate), imageWidth: image.size.width)
                
                if color.getRed(&imageRed, green: &imageGreen, blue: &imageBlue, alpha: &imageAlpha) {
                    var averagedRGB = (imageRed + imageBlue + imageGreen)/3
                    var pixelGreenness: CGFloat
                    if averagedRGB != 0 {
                        pixelGreenness = imageGreen/averagedRGB - 1
                    } else {
                        pixelGreenness = 1
                    }
                    
                    totalGreenness += pixelGreenness
                }
            }
        }
        return totalGreenness
    }
}

extension UIImage {
    func getPixelColor(position: CGPoint, imageWidth: CGFloat) -> UIColor {
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        var bytesPerPixel = CGFloat(CGImageGetBytesPerRow(self.CGImage))/imageWidth
        
        var pixelInfo: Int = ((Int(self.size.width) * Int(position.y)) + Int(position.x)) * Int(bytesPerPixel)
        let rgbConversionConstant: CGFloat = 255
        
        var r = CGFloat(data[pixelInfo]) / rgbConversionConstant
        var g = CGFloat(data[pixelInfo+1]) / rgbConversionConstant
        var b = CGFloat(data[pixelInfo+2]) / rgbConversionConstant
        var a = CGFloat(data[pixelInfo+3]) / rgbConversionConstant
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}