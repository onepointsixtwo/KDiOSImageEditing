//
//  CropOverlayView.swift
//  ImageEditingFramework
//
//  Created by John Kartupelis on 21/01/2015.
//  Copyright (c) 2015 John Kartupelis. All rights reserved.
//

import UIKit

public class CropOverlayView: UIView {

    //MARK: Properties
    var fillView : UIView?
    let miniViewSize : CGFloat = 29.0
    let borderColor : UIColor = UIColor(white: 0.2, alpha: 1.0)
    let minimumCropSize : CGSize = CGSizeMake(120.0, 120.0)
    private var panInfo : CurrentPanInfo?
    
    
    //MARK: Public Getters / Methods
    public func getViewSize() -> CGSize
    {
        return self.frame.size
    }
    
    public func getCropSize() -> CGRect
    {
        var frame : CGRect? = fillView?.frame
        return frame!
    }
    
    public func reset()
    {
        var fillV : UIView = fillView!
        UIView.animateWithDuration(0.2) { () -> Void in
            
            fillV.frame = self.bounds
            self.setNeedsDisplay()
        }
    }
    
    //MARK: Internal Types
    private enum CropOverlayPanArea
    {
        case TopLeftCorner, TopRightCorner, BottomLeftCorner, BottomRightCorner, MiddleArea
    }
    private class CurrentPanInfo: NSObject
    {
        var panArea : CropOverlayPanArea?
        var fillViewStartingRect : CGRect?
    }

    //MARK: Initialisation and overrides
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToSuperview() {
        self.setupView()
        
        //Add pan gesture recogniser.
        var panGr : UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("pan:"))
        self.superview?.addGestureRecognizer(panGr)
    }
    
    
    //MARK: Custom Drawing
    public override func drawRect(rect: CGRect) {
        
        UIColor(white: 0.2, alpha: 0.6).setFill()
        UIRectFill(self.bounds)
        
        UIColor.clearColor().setFill()
        var frm = fillView?.frame
        UIRectFill(frm!)
    }

    
    //MARK: View Setup
    private func setupView()
    {
        //create fill view
        fillView = UIView(frame: self.bounds)
        fillView?.clipsToBounds = true
        fillView?.backgroundColor = UIColor.clearColor()
        fillView?.layer.borderColor = borderColor.CGColor
        fillView?.layer.borderWidth = 3.0
        self.addSubview(fillView!)
        
        //add squares to the corners
        var topLeft = getMiniSquareView()
        fillView?.addSubview(topLeft)
        var topCon = NSLayoutConstraint(item: topLeft, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: fillView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -4.0)
        var leftCon = NSLayoutConstraint(item: topLeft, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: fillView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: -4.0)
        fillView?.addConstraint(topCon)
        fillView?.addConstraint(leftCon)
        
        var topRight = getMiniSquareView()
        fillView?.addSubview(topRight)
        topCon = NSLayoutConstraint(item: topRight, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: fillView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -4.0)
        var rightCon = NSLayoutConstraint(item: topRight, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: fillView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 4.0)
        fillView?.addConstraint(topCon)
        fillView?.addConstraint(rightCon)
        
        var bottomLeft = getMiniSquareView()
        fillView?.addSubview(bottomLeft)
        var bottomCon = NSLayoutConstraint(item: bottomLeft, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: fillView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 4.0)
        leftCon = NSLayoutConstraint(item: bottomLeft, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: fillView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: -4.0)
        fillView?.addConstraint(bottomCon)
        fillView?.addConstraint(leftCon)
        
        var bottomRight = getMiniSquareView()
        fillView?.addSubview(bottomRight)
        bottomCon = NSLayoutConstraint(item: bottomRight, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: fillView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 4.0)
        rightCon = NSLayoutConstraint(item: bottomRight, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: fillView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 4.0)
        fillView?.addConstraint(bottomCon)
        fillView?.addConstraint(rightCon)
        
        self.layoutIfNeeded()
        fillView?.layoutIfNeeded()
    }
    
    private func getMiniSquareView() -> UIView
    {
        var miniSquare : UIView = UIView()
        miniSquare.setTranslatesAutoresizingMaskIntoConstraints(false)
        miniSquare.frame = CGRectMake(0, 0, 30, 30)
        miniSquare.layer.cornerRadius = 4.0
        miniSquare.clipsToBounds = true
        miniSquare.backgroundColor = borderColor
        
        var heightConstraint : NSLayoutConstraint = NSLayoutConstraint(item: miniSquare, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: miniViewSize)
        var widthConstraint : NSLayoutConstraint = NSLayoutConstraint(item: miniSquare, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: miniViewSize)
        miniSquare.addConstraint(heightConstraint)
        miniSquare.addConstraint(widthConstraint)
        return miniSquare
    }
    
    
    //MARK: Pan Handling
    func pan(panGr : UIPanGestureRecognizer)
    {
        switch(panGr.state)
        {
        case UIGestureRecognizerState.Began:
                self.handlePanBegan(panGr)
            
        case UIGestureRecognizerState.Changed:
                self.handlePanMoved(panGr)
            
        case UIGestureRecognizerState.Ended:
                self.handlePanEnded(panGr)
        default:
            NSLog("Pan gesture recogniser unknown state")
        }
    }
    
    func handlePanBegan(panGr : UIPanGestureRecognizer)
    {
        var area : CropOverlayPanArea? = self.panAreaForCurrentPan(panGr.locationInView(self))
        if(area != nil)
        {
            panInfo = CurrentPanInfo()
            panInfo?.fillViewStartingRect = fillView?.frame
            panInfo?.panArea = area
        }
    }
    
    func handlePanMoved(panGr : UIPanGestureRecognizer)
    {
        if(panInfo != nil)
        {
            var translation : CGPoint = panGr.translationInView(self)
            var areaPoss : CropOverlayPanArea? = panInfo?.panArea
            if var area : CropOverlayPanArea = areaPoss
            {
                //set fillview frame and call setNeedsDisplay()
                switch area
                {
                case CropOverlayPanArea.TopLeftCorner:
                    self.handleTopLeftCornerPan(translation)
                    
                case CropOverlayPanArea.TopRightCorner:
                    self.handleTopRightCornerPan(translation)
                    
                case CropOverlayPanArea.BottomLeftCorner:
                    self.handleBottomLeftCornerPan(translation)
                    
                case CropOverlayPanArea.BottomRightCorner:
                    self.handleBottomRightCornerPan(translation)
                    
                case CropOverlayPanArea.MiddleArea:
                    self.handleMiddleAreaCornerPan(translation)
                }
                
                self.setNeedsDisplay()
            }
        }
    }
    
    func handleTopLeftCornerPan(translation : CGPoint)
    {
        var newFrame : CGRect? = nil
        var panInfoFinal : CurrentPanInfo = panInfo!
        var oldFrame : CGRect = panInfoFinal.fillViewStartingRect!
        
        var newX : CGFloat = oldFrame.origin.x + translation.x
        var newY : CGFloat = oldFrame.origin.y + translation.y
        var newWidth : CGFloat = oldFrame.size.width - translation.x
        var newHeight : CGFloat = oldFrame.size.height - translation.y
        
        if(newWidth < minimumCropSize.width)
        {
            newWidth = minimumCropSize.width
            newX = (oldFrame.origin.x + oldFrame.size.width) - minimumCropSize.width
        }
        if(newHeight < minimumCropSize.height)
        {
            newHeight = minimumCropSize.height
            newY = (oldFrame.origin.y + oldFrame.size.height) - minimumCropSize.height
        }
        if(newX < 0)
        {
            newX = 0
            newWidth = self.bounds.width
        }
        if(newY < 0)
        {
            newY = 0
            newHeight = self.bounds.height
        }
        newFrame = CGRectMake(newX, newY, newWidth, newHeight)
        
        if (newFrame != nil)
        {
            fillView?.frame = newFrame!
        }
    }
    
    func handleTopRightCornerPan(translation : CGPoint)
    {
        var newFrame : CGRect? = nil
        var panInfoFinal : CurrentPanInfo = panInfo!
        var oldFrame : CGRect = panInfoFinal.fillViewStartingRect!
        
        var newX : CGFloat = oldFrame.origin.x
        var newY : CGFloat = oldFrame.origin.y + translation.y
        var newWidth : CGFloat = oldFrame.size.width + translation.x
        var newHeight : CGFloat = oldFrame.size.height - translation.y
        
        if(newWidth < minimumCropSize.width)
        {
            newWidth = minimumCropSize.width
        }
        if(newHeight < minimumCropSize.height)
        {
            newHeight = minimumCropSize.height
            newY = (oldFrame.origin.y + oldFrame.size.height) - minimumCropSize.height
        }
        if(newY < 0)
        {
            newY = 0
            newHeight = self.bounds.height
        }
        if(newWidth + newX > self.bounds.size.width)
        {
            newWidth = self.bounds.size.width - newX
        }
        newFrame = CGRectMake(newX, newY, newWidth, newHeight)
        
        if (newFrame != nil)
        {
            fillView?.frame = newFrame!
        }
    }
    
    func handleBottomLeftCornerPan(translation : CGPoint)
    {
        var newFrame : CGRect? = nil
        var panInfoFinal : CurrentPanInfo = panInfo!
        var oldFrame : CGRect = panInfoFinal.fillViewStartingRect!
        
        var newX : CGFloat = oldFrame.origin.x + translation.x
        var newY : CGFloat = oldFrame.origin.y
        var newWidth : CGFloat = oldFrame.size.width - translation.x
        var newHeight : CGFloat = oldFrame.size.height + translation.y
        
        if(newWidth < minimumCropSize.width)
        {
            newWidth = minimumCropSize.width
            newX = (oldFrame.origin.x + oldFrame.size.width) - minimumCropSize.width
        }
        if(newHeight < minimumCropSize.height)
        {
            newHeight = minimumCropSize.height
        }
        if(newX < 0)
        {
            newX = 0
            newWidth = (oldFrame.origin.x + oldFrame.size.width)
        }
        if(newHeight + newY > self.bounds.size.height)
        {
            newHeight = self.bounds.size.height - newY
        }
        newFrame = CGRectMake(newX, newY, newWidth, newHeight)
        
        if (newFrame != nil)
        {
            fillView?.frame = newFrame!
        }
    }
    
    func handleBottomRightCornerPan(translation : CGPoint)
    {
        var newFrame : CGRect? = nil
        var panInfoFinal : CurrentPanInfo = panInfo!
        var oldFrame : CGRect = panInfoFinal.fillViewStartingRect!
        
        var newX : CGFloat = oldFrame.origin.x
        var newY : CGFloat = oldFrame.origin.y
        var newWidth : CGFloat = oldFrame.size.width + translation.x
        var newHeight : CGFloat = oldFrame.size.height + translation.y
        
        if(newWidth < minimumCropSize.width)
        {
            newWidth = minimumCropSize.width
        }
        if(newHeight < minimumCropSize.height)
        {
            newHeight = minimumCropSize.height
        }
        if(newWidth + newX > self.bounds.size.width)
        {
            newWidth = self.bounds.size.width - newX
        }
        if(newHeight + newY > self.bounds.size.height)
        {
            newHeight = self.bounds.size.height - newY
        }
        newFrame = CGRectMake(newX, newY, newWidth, newHeight)
        
        if (newFrame != nil)
        {
            fillView?.frame = newFrame!
        }
    }
    
    func handleMiddleAreaCornerPan(translation : CGPoint)
    {
        var newFrame : CGRect? = nil
        var panInfoFinal : CurrentPanInfo = panInfo!
        var oldFrame : CGRect = panInfoFinal.fillViewStartingRect!
        
        var newX : CGFloat = oldFrame.origin.x + translation.x
        var newY : CGFloat = oldFrame.origin.y + translation.y
        var newWidth : CGFloat = oldFrame.size.width
        var newHeight : CGFloat = oldFrame.size.height
        
        if(newX < 0.0)
        {
            newX = 0.0
        }
        if(newY < 0.0)
        {
            newY = 0.0
        }
        if(newX + newWidth > self.bounds.size.width)
        {
            newX = self.bounds.size.width - newWidth
        }
        if(newY + newHeight > self.bounds.size.height)
        {
            newY = self.bounds.size.height - newHeight
        }
        newFrame = CGRectMake(newX, newY, newWidth, newHeight)
        
        if (newFrame != nil)
        {
            fillView?.frame = newFrame!
        }
    }
    
    func handlePanEnded(panGr : UIPanGestureRecognizer)
    {
        panInfo = nil
    }
    
    
    //MARK: Helpers
    private func panAreaForCurrentPan(point : CGPoint) -> CropOverlayPanArea?
    {
        var area : CropOverlayPanArea? = nil
        
        var dict : Dictionary<CropOverlayPanArea, CGPoint> = self.cornersArrayForFillView()
        for (areaIter : CropOverlayPanArea, pt : CGPoint) in dict
        {
            if(self.distanceBetweenCGPoints(point, p2: pt) < 40)
            {
                area = areaIter
            }
        }
        
        var frm = fillView?.frame
        if(area == nil && CGRectContainsPoint(frm!, point))
        {
            area = CropOverlayPanArea.MiddleArea
        }
        
        return area
    }
    
    private func cornersArrayForFillView() -> Dictionary<CropOverlayPanArea, CGPoint>
    {
        var dictionary = Dictionary<CropOverlayPanArea, CGPoint>()
        
        var frame = fillView?.frame
        
        //top-left
        dictionary[CropOverlayPanArea.TopLeftCorner] = frame!.origin
        
        //top-right
        dictionary[CropOverlayPanArea.TopRightCorner] = CGPointMake(frame!.origin.x + frame!.size.width, frame!.origin.y)
        
        //bottom-left
        dictionary[CropOverlayPanArea.BottomLeftCorner] = CGPointMake(frame!.origin.x, frame!.origin.y + frame!.size.height)
        
        //bottom right
        dictionary[CropOverlayPanArea.BottomRightCorner] = CGPointMake(frame!.origin.x + frame!.size.width, frame!.origin.y + frame!.size.height)
        
        return dictionary
    }
    
    func distanceBetweenCGPoints(p1 : CGPoint, p2 : CGPoint) -> CGFloat
    {
        var xDist : CGFloat = (p2.x - p1.x)
        var yDist : CGFloat = (p2.y - p1.y)
        var distance : CGFloat = sqrt((xDist * xDist) + (yDist * yDist))
        return distance
    }
    
}
