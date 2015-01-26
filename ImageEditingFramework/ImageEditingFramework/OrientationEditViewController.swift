//
//  OrientationEditViewController.swift
//  ImageEditingFramework
//
//  Created by John Kartupelis on 23/01/2015.
//  Copyright (c) 2015 John Kartupelis. All rights reserved.
//

import UIKit

public class OrientationEditViewController: EditViewController {
   
    //MARK: Properties
    var slider : UISlider? = nil
    var sliderSnapLevel : Float = 2.0
    var sliderCentred : Bool = true
    var dontChangeOrientation : Bool = false
    var lastValue : Float = 0.0
    let microAdjustionAmount : Float = 8.0
    public override var title : String?
        {
        get
        {
            return "Orientation"
        }
        set
        {
            //Don't bother setting...
        }
    }
    
    
    //MARK: Overridden Transition Handling
    public override func prepareToAnimateInBottomViews()
    {
        var bundle : NSBundle = self.bundle!
        var view : UIView = bundle.loadNibNamed("OrientationLowerView", owner: nil, options: nil)[0] as UIView
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
        var rotationSegmentedControl : UISegmentedControl = view.viewWithTag(2) as UISegmentedControl
        var flipSegmentedControl : UISegmentedControl = view.viewWithTag(3) as UISegmentedControl
        
        //setup the slider
        sld.minimumValue = -(microAdjustionAmount)
        sld.maximumValue = microAdjustionAmount
        sld.value = 0.0
        self.slider = sld
        sld.addTarget(self, action: Selector("sliderValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        sld.addTarget(self, action: Selector("sliderTouchUpInside:"), forControlEvents: UIControlEvents.TouchUpInside)

        //setup the rotation segmented control
        rotationSegmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.grayColor()], forState: UIControlState.Highlighted)
        rotationSegmentedControl.addTarget(self, action: Selector("rotationSegmentPressed:"), forControlEvents: UIControlEvents.ValueChanged)
        
        //setup the flip segmented control
        flipSegmentedControl.addTarget(self, action: Selector("flipSegmentPressed:"), forControlEvents: UIControlEvents.ValueChanged)
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
    func rotationSegmentPressed(rotationSegmentedControl : UISegmentedControl)
    {
        var selectedIndex = rotationSegmentedControl.selectedSegmentIndex
        
        if(selectedIndex == 0)
        {
            var image = self.imageView?.image
            image = image?.imageRotatedByDegrees(-90.0)
            self.image = image
            self.imageView?.image = image
        }
        else if(selectedIndex == 1)
        {
            var image = self.imageView?.image
            image = image?.imageRotatedByDegrees(90.0)
            self.image = image
            self.imageView?.image = image
        }
        
        lastValue = 0.0
        slider?.value = 0.0
        dontChangeOrientation = true
        rotationSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    func flipSegmentPressed(flipSegmentedControl : UISegmentedControl)
    {
        var selectedIndex = flipSegmentedControl.selectedSegmentIndex
        
        if(selectedIndex == 0)
        {
            var image = self.imageView?.image
            image = image?.verticallyFlippedImage()
            self.image = image
            self.imageView?.image = image
        }
        else if(selectedIndex == 1)
        {
            var image = self.imageView?.image
            image = image?.horizontallyFlippedImage()
            self.image = image
            self.imageView?.image = image
        }
        
        lastValue = 0.0
        slider?.value = 0.0
        dontChangeOrientation = true
        flipSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    func sliderValueChanged(sld : UISlider)
    {
        if(dontChangeOrientation)
        {
            dontChangeOrientation = false
            return
        }
        
        if(sliderCentred && (sld.value > sliderSnapLevel || sld.value < -(sliderSnapLevel)))
        {
            sliderCentred = false
        }
        
        //round to the nearest 0.5
        var degrees = round((sld.value * 2)) / 2.0
        if(degrees != lastValue)
        {
            lastValue = degrees
            var img = self.image?.imageAdjustedByDegrees(CGFloat(degrees))
            self.imageView?.image = img
        }
    }
    
    func sliderTouchUpInside(sld : UISlider)
    {
        if(!sliderCentred && sld.value < sliderSnapLevel && sld.value > -sliderSnapLevel)
        {
            sld.setValue(0.0, animated: true)
            sliderCentred = true
        }
    }
    
    
    //MARK: Overridden Save Method
    override func save() {
        self.image = self.imageView?.image
        super.save()
    }
}
