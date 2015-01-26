//
//  EditViewController.swift
//  ImageEditingFramework
//
//  Created by John Kartupelis on 20/01/2015.
//  Copyright (c) 2015 John Kartupelis. All rights reserved.
//

import UIKit

//MARK: The delegate protocol definition
public protocol EditViewControllerDelegate
{
     func applyEditControllerChanges(controller : EditViewController, image : UIImage?)
}

//MARK: The class definition / implementation
public class EditViewController: UIViewController {

    //MARK: Properties
    internal var bundle : NSBundle?
    public var image : UIImage?
    public var delegate : EditViewControllerDelegate?
    @IBOutlet weak var imageView : UIImageView?
    @IBOutlet weak var lowerView : UIView?
    public override var title : String?
    {
        get
        {
            return "Edit"
        }
        set
        {
            //Don't bother setting...
        }
    }
    
    
    //MARK: Initialisation and View Delegate
    public override init() {
        bundle = NSBundle(identifier: "kartdev.ImageEditingFramework")!
        super.init(nibName: "EditViewController", bundle:bundle)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad(){
        super.viewDidLoad()

        //Setup basic view
        self.edgesForExtendedLayout = UIRectEdge.None
        self.imageView?.image = image
        
        //Setup navigation bar
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.Done, target: self, action: Selector("apply:")), animated: false)
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancel:")), animated: false)
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Actions
    internal func apply(barButtonItem : UIBarButtonItem)
    {
        self.save()
        self.close()
    }
    
    internal func cancel(barButtonItem : UIBarButtonItem)
    {
        self.close()
    }
    
    internal func close()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    internal func save()
    {
        if var delegate : EditViewControllerDelegate = self.delegate
        {
            delegate.applyEditControllerChanges(self, image: self.image)
        }
    }
    
    //MARK: Transition Handling
    public func prepareToAnimateInBottomViews()
    {
        
    }
    
    public func animateInBottomViews()
    {
        
    }

    public func animateOutBottomViews()
    {
        
    }
    
    
    //MARK: Size Of Overlays
    internal func overlayViewFrame() -> CGRect
    {
        //Calculate the frame for the crop overlay view.
        var imageViewFrame = imageView?.frame
        var imageSize = image?.size
        var finalFrame : CGRect?
        
        var imageViewRatio = imageViewFrame!.size.width / imageViewFrame!.size.height
        var imageRatio = imageSize!.width / imageSize!.height
        
        if(imageViewRatio == imageRatio)
        {
            finalFrame = imageViewFrame
        }
        else if(imageViewRatio < imageRatio)
        {
            var widthRatio = imageViewFrame!.width / imageSize!.width
            var newHeight = imageSize!.height * widthRatio
            var yPos = (imageViewFrame!.height - newHeight) * 0.5
            finalFrame = CGRectMake(imageViewFrame!.origin.x, imageViewFrame!.origin.y + yPos, imageViewFrame!.size.width, newHeight)
        }
        else
        {
            var heightRatio = imageViewFrame!.height / imageSize!.height
            var newWidth = imageSize!.width * heightRatio
            var xPos = (imageViewFrame!.width - newWidth) * 0.5
            finalFrame = CGRectMake(imageViewFrame!.origin.x + xPos, imageViewFrame!.origin.y, newWidth, imageViewFrame!.size.height)
        }
        
        return finalFrame!
    }
}
