//
//  BrightnessEditViewController.swift
//  ImageEditingFramework
//
//  Created by John Kartupelis on 26/01/2015.
//  Copyright (c) 2015 John Kartupelis. All rights reserved.
//

import UIKit

public class BrightnessEditViewController: EditViewController {
   
    //MARK: Properties
    var slider : UISlider? = nil
    var lowerValue : Float = -0.6
    var upperValue : Float = 0.6
    var ciImage : CIImage? = nil
    var ciContext : CIContext? = nil
    public override var title : String?
        {
        get
        {
            return "Brightness"
        }
        set
        {
            //Don't bother setting...
        }
    }
    
    
    
    //MARK: View Delegate
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Setup core image bits
        ciImage = CIImage(CGImage: self.image?.CGImage)
        ciContext = CIContext(options: nil)
    }
    
    
    //MARK: Overridden Transition Handling
    public override func prepareToAnimateInBottomViews()
    {
        var bundle : NSBundle = self.bundle!
        var view : UIView = bundle.loadNibNamed("SliderLowerView", owner: nil, options: nil)[0] as UIView
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.lowerView?.addSubview(view)
        self.lowerView?.alpha = 0.0
        self.lowerView?.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.lowerView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        self.lowerView?.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.lowerView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        self.lowerView?.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.lowerView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
        self.lowerView?.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.lowerView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        self.lowerView?.layoutIfNeeded()
        
        
        //get the inner views.
        var sld : UISlider = view.viewWithTag(1) as UISlider
        
        //setup the slider
        sld.minimumValue = lowerValue
        sld.maximumValue = upperValue
        sld.value = 0.0
        self.slider = sld
        sld.addTarget(self, action: Selector("sliderValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        sld.addTarget(self, action: Selector("sliderTouchUpInside:"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    public override func animateInBottomViews()
    {
        self.lowerView?.alpha = 1.0
    }
    
    public override func animateOutBottomViews()
    {
        self.lowerView?.alpha = 0.0
    }
    
    
    //MARK: Actions
    func sliderValueChanged(sld : UISlider)
    {
        var ci : CIImage = self.ciImage!
        var filter : CIFilter = CIFilter(name: "CIColorControls", withInputParameters: [kCIInputImageKey : ci, "inputBrightness": sld.value]);
        var cgImg = self.ciContext?.createCGImage(filter.outputImage, fromRect: ci.extent())
        var img = UIImage(CGImage: cgImg)
        self.image = img
        self.imageView?.image = img
    }
    
    func sliderTouchUpInside(sld : UISlider)
    {

    }
    
}
