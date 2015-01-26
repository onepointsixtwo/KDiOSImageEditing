//
//  ext.swift
//  ImageEditingFramework
//
//  Created by John Kartupelis on 21/01/2015.
//  Copyright (c) 2015 John Kartupelis. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func getImageWithNameInBundle(name : String, fileExtension : String, bundle : NSBundle) -> UIImage?
    {
        var path = bundle.pathForResource(name, ofType: fileExtension)
        return UIImage(contentsOfFile: path!)
    }
    
    private func flippedImage(horizontal : Bool) -> UIImage
    {
        UIGraphicsBeginImageContext(self.size)
        var context = UIGraphicsGetCurrentContext()
        
        if(horizontal)
        {
            CGContextTranslateCTM(context, 0, self.size.height)
            CGContextScaleCTM(context, 1.0, -1.0)
            CGContextTranslateCTM(context, self.size.width, 0)
            CGContextScaleCTM(context, -1.0, 1.0)
        }
        else
        {
            CGContextTranslateCTM(context, self.size.width, 0)
            CGContextScaleCTM(context, -1.0, 1.0)
        }
        
        CGContextDrawImage(context, CGRectMake(0.0, 0.0, self.size.width, self.size.height), self.CGImage)
        
        var flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return flippedImage!
    }
    
    public func verticallyFlippedImage() -> UIImage
    {
        return self.flippedImage(false)
    }
    
    public func horizontallyFlippedImage() -> UIImage
    {
        return self.flippedImage(true)
    }
    
    public func imageRotatedByDegrees(degrees : CGFloat) -> UIImage
    {
        var rotatedViewBox = UIView(frame: CGRectMake(0, 0, self.size.width, self.size.height))
        var t = CGAffineTransformMakeTranslation(self.size.width * 0.5, self.size.height * 0.5)
        t = CGAffineTransformRotate(t, degrees.degreesToRadians())
        rotatedViewBox.transform = t
        var rotatedSize : CGSize = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        var bitmap : CGContextRef = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(bitmap, rotatedSize.width * 0.5, rotatedSize.height * 0.5)
        CGContextRotateCTM(bitmap, degrees.degreesToRadians())
        CGContextScaleCTM(bitmap, 1.0, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-self.size.width * 0.5, -self.size.height * 0.5, self.size.width, self.size.height), self.CGImage)
        
        var newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    public func imageAdjustedByDegrees(degrees : CGFloat) -> UIImage
    {
        var rotatedViewBox = UIView(frame: CGRectMake(0, 0, self.size.width, self.size.height))
        var t = CGAffineTransformMakeTranslation(self.size.width * 0.5, self.size.height * 0.5)
        t = CGAffineTransformRotate(t, degrees.degreesToRadians())
        rotatedViewBox.transform = t
        var rotatedSize : CGSize = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        var bitmap : CGContextRef = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(bitmap, rotatedSize.width * 0.5, rotatedSize.height * 0.5)
        CGContextRotateCTM(bitmap, degrees.degreesToRadians())
        CGContextScaleCTM(bitmap, 1.0, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-self.size.width * 0.5, -self.size.height * 0.5, self.size.width, self.size.height), self.CGImage)
        
        var newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var positiveDegrees = degrees > 0.0 ? degrees : degrees * -1.0
        var amnt = positiveDegrees / 15.0
        var scl = 1 - (amnt * 0.34)
        
        var newImageSize : CGSize = newImage.size
        var currentImageSize : CGSize = self.size
        var newImageCentre : CGPoint = CGPointMake(newImageSize.width * 0.5, newImageSize.height * 0.5)
        var sz : CGSize = CGSizeMake(currentImageSize.width * scl, currentImageSize.height * scl)
        var pt : CGPoint = CGPointMake(newImageCentre.x - (sz.width * 0.5), newImageCentre.y - (sz.height * 0.5))
        var frm : CGRect = CGRectZero
        frm.size = sz
        frm.origin = pt
        var cg = CGImageCreateWithImageInRect(newImage.CGImage, frm)
        
        return UIImage(CGImage: cg)!
    }
}

extension CGFloat
{
    func degreesToRadians() -> CGFloat
    {
        return CGFloat(M_PI) * self / 180.0
    }
    
    func radiansToDegrees() -> CGFloat
    {
        return self * (180.0 / CGFloat(M_PI))
    }
}
