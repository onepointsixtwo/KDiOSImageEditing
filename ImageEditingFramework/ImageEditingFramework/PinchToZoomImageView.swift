//
//  PinchToZoomImageView.swift
//  ImageEditingFramework
//
//  Created by John Kartupelis on 20/01/2015.
//  Copyright (c) 2015 John Kartupelis. All rights reserved.
//

import UIKit

internal class PinchToZoomImageView: UIView, UIScrollViewDelegate {

    
    //MARK: Properties
    internal var image : UIImage?
    {
        get
        {
            return self.imageView?.image;
        }
        set
        {
            self.imageView?.image = newValue;
        }
    }
    private var imageView : UIImageView?;
    private var scrollView : UIScrollView?;
    
    
    //MARK: Initialisers
    required internal init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialise()
    }
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialise()
    }
    
    internal override init() {
        super.init()
        self.initialise()
    }
    
    private func initialise()
    {
        //clip to bounds.
        self.clipsToBounds = true
        self.backgroundColor = UIColor.redColor()
        self.multipleTouchEnabled = true
        
        //create the views.
        scrollView = UIScrollView(frame: CGRectZero)
        scrollView?.backgroundColor = UIColor.greenColor()
        scrollView?.delegate = self
        
        imageView = UIImageView(frame: CGRectZero)
        imageView?.userInteractionEnabled = true
        imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        scrollView?.addSubview(imageView!)

        //add the views.
        self.addSubview(scrollView!)

        //add pinch gesture recogniser.
        scrollView?.minimumZoomScale = 1.0
        scrollView?.maximumZoomScale = 3.0
        scrollView?.zoomScale = 1.0
        scrollView?.bounces = false
        scrollView?.bouncesZoom = false
        
        var pinch : UIPinchGestureRecognizer? = nil
    }
    
    
    
    //MARK: Overrides
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView?.frame = self.bounds
        imageView?.frame = self.bounds
    }
    
    //MARK: Scroll View Delegate
    func scrollViewDidZoom(scrollView: UIScrollView) {
        NSLog("Scroll view did zoom!")
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}
