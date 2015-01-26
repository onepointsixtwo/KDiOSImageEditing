//
//  CropEditViewController.swift
//  ImageEditingFramework
//
//  Created by John Kartupelis on 21/01/2015.
//  Copyright (c) 2015 John Kartupelis. All rights reserved.
//

import UIKit

public class CropEditViewController: EditViewController {

    //MARK: Properties
    private var button : UIButton?
    public override var title : String?
        {
        get
        {
            return "Crop Photo"
        }
        set
        {
            //Don't bother setting...
        }
    }
    private var cropOverlayView : CropOverlayView?
    
    
    //MARK: View Delegate
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addInOverlayView()
        self.animateInOverlayView()
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: Overriden transition handling
    override public func prepareToAnimateInBottomViews()
    {
        button = UIButton()
        button?.alpha = 0.0
        button?.setTitle("Reset", forState: UIControlState.Normal)
        button?.addTarget(self, action: Selector("reset:"), forControlEvents: UIControlEvents.TouchUpInside)
        button?.setTitleColor(UIColor(white: 0.2, alpha: 1.0), forState: UIControlState.Normal)
        button?.setTitleColor(UIColor(white: 0.5, alpha: 1.0), forState: UIControlState.Highlighted)
        button?.setTranslatesAutoresizingMaskIntoConstraints(false)
        button?.addConstraint(NSLayoutConstraint(item: button!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 45.0))
        button?.addConstraint(NSLayoutConstraint(item: button!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 90.0))
        self.lowerView?.addSubview(button!)
        
        self.lowerView?.addConstraint(NSLayoutConstraint(item: button!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.lowerView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        self.lowerView?.addConstraint(NSLayoutConstraint(item: button!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.lowerView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
    }
    
    override public func animateInBottomViews()
    {
        button?.alpha = 1.0
    }
    
    override public func animateOutBottomViews()
    {
        button?.alpha = 0.0
    }
    
    
    //MARK: Actions
    func reset(buttonPressed : UIButton)
    {
        self.cropOverlayView?.reset()
    }
    
    
    //MARK: Overridden save method
    override func save()
    {
        //Get original values, and the crop size from the overlay view
        var cropView : CropOverlayView = self.cropOverlayView!
        var rect : CGRect = cropView.getCropSize()
        var size : CGSize = cropView.getViewSize()
        var imageSize : CGSize? = image?.size
        
        //Scale up the crop rect to be the rect from the original image
        var ratio = imageSize!.width / size.width
        var rectFromImage : CGRect = CGRectMake(rect.origin.x * ratio, rect.origin.y * ratio, rect.size.width * ratio, rect.size.height * ratio)
        
        //perform the crop
        var cgImage = CGImageCreateWithImageInRect(self.image?.CGImage, rectFromImage)
        self.image = UIImage(CGImage: cgImage)
        
        //call super.save after!
        super.save()
    }
    
    
    //MARK: Overlay View Handling
    private func addInOverlayView()
    {
        cropOverlayView = CropOverlayView(frame: self.overlayViewFrame())
        cropOverlayView?.backgroundColor = UIColor.clearColor()
        cropOverlayView?.alpha = 0.0
        self.view.addSubview(cropOverlayView!)
    }
    
    private func animateInOverlayView()
    {
        var interval : NSTimeInterval = NSTimeInterval(0.5)
        UIView.animateWithDuration(interval, animations: { () -> Void in
            
            var cropOverlay = self.cropOverlayView!
            cropOverlay.alpha = 1.0
        })
    }
}
