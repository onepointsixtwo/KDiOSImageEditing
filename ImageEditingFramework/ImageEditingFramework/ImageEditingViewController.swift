//
//  ImageEditingViewController.swift
//  ImageEditingFramework
//
//  Created by John Kartupelis on 19/01/2015.
//  Copyright (c) 2015 John Kartupelis. All rights reserved.
//


//AVAILABLE FUNCTIONS FOR EDITING: crop, adjust, effects, focus, frames, orientation, stickers, enhance, splash (of color), brightness, contrast

import UIKit
import CoreImage


public class ImageEditingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning, EditViewControllerDelegate {
    
    
    //MARK: Properties
    @IBOutlet weak var imageView : UIImageView?
    @IBOutlet weak var collectionView : UICollectionView?
    @IBOutlet weak var collectionViewTopConstraint : NSLayoutConstraint?
    let cellIdentifier : NSString = "cell"
    private var image : UIImage
    private var bundle : NSBundle
    private var movingToInternalView : Bool = false
    private var movingForward : Bool = false
    private var cachedStatusBarStyle : UIStatusBarStyle
    private var _editingTypes : NSArray?
    private var editingTypes : NSArray
    {
        get
        {
            if(_editingTypes == nil)
            {
                var path : NSString? = self.bundle.pathForResource("editing-types", ofType: "plist")
                _editingTypes = NSArray(contentsOfFile: path!)
            }
            return _editingTypes!
        }
    }
    public override var title : String?
    {
        get
        {
            return "Photo Editor"
        }
        set
        {
            //Don't bother setting...
        }
    }
    
    
    //MARK: External initialisation.
    public class func getImageEditingViewControllerWithImage(image : UIImage) -> UINavigationController
    {        
        let vc : ImageEditingViewController = ImageEditingViewController(image: image)
        let nav : ImageEditingNavigationController = ImageEditingNavigationController(rootViewController: vc)
        return nav
    }
    
    
    //MARK: Overrides
    internal init(image : UIImage) {
        self.image = image
        self.cachedStatusBarStyle = UIApplication.sharedApplication().statusBarStyle
        bundle = NSBundle(identifier: "kartdev.ImageEditingFramework")!
        super.init(nibName: "ImageEditingViewController", bundle:bundle)
        self.navigationController?.delegate = self
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("Image Editing View Controller cannot be initialised with initWithCoder:")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        //Setup basic view
        self.edgesForExtendedLayout = UIRectEdge.None
        
        //Set image
        self.imageView?.image = self.image
        
        //Set up navigation bar
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("done:")), animated: false)
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancel:")), animated: false)
        
        //Setup collection view
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.contentInset = UIEdgeInsetsMake(0, 5, 0, 5)
        self.collectionView?.registerNib(UINib(nibName: "CollectionViewEditorCell", bundle: bundle), forCellWithReuseIdentifier: cellIdentifier)
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !movingToInternalView
        {
            UIApplication.sharedApplication().setStatusBarStyle(cachedStatusBarStyle, animated: false)
        }
    }
    
    
    //MARK: Actions
    internal func done(barButtonItem : UIBarButtonItem)
    {
        self.close()
    }
    
    internal func cancel(barButtonItem : UIBarButtonItem)
    {
        self.close()
    }
    
    internal func close()
    {
        self.navigationController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    //MARK: UICollectionView
    
    //UICollectionViewDataSource
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.editingTypes.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell : UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as UICollectionViewCell;
        cell.backgroundColor = UIColor(white: 0.85, alpha: 1.0);
        
        //Get the cell's inner views
        var cellImageView : UIImageView = cell.viewWithTag(1) as UIImageView
        var cellLabel : UILabel = cell.viewWithTag(2) as UILabel
        
        //Get the dictionary for the cell
        var dict : NSDictionary? = self.editingTypes.objectAtIndex(indexPath.row) as? NSDictionary
        
        if var dictionary : NSDictionary = dict
        {
            cellLabel.text = dictionary.objectForKey("Name") as NSString
        }
        
        //TEST
        var img : UIImage? = UIImage.getImageWithNameInBundle("crop-icon", fileExtension: "png", bundle: self.bundle)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cellImageView.image = img
        cellImageView.tintColor = UIColor(white: 0.25, alpha: 1.0)
        cellLabel.textColor = cellImageView.tintColor
        
        return cell;
    }
    
    //UICollectionViewDelegate
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //Get the dictionary for the cell
        var dict : NSDictionary? = self.editingTypes.objectAtIndex(indexPath.row) as? NSDictionary
        
        if var dictionary : NSDictionary = dict
        {
            var controllerName : NSString = dictionary.objectForKey("Controller") as NSString
            
            if controllerName.length  > 0
            {
                var controller : EditViewController = self.getEditControllerForName(controllerName)
                self.animateToEditingController(controller)
            }
        }
    }
    
    private func getEditControllerForName(name : String) -> EditViewController
    {
        var cls = NSClassFromString(NSString(format: "ImageEditingFramework.%@", name)) as NSObject.Type
        return cls() as EditViewController
    }
    
    
    //MARK: Edit View Controller Delegate
    public func applyEditControllerChanges(controller: EditViewController, image: UIImage?) {
        self.image = image!
        self.imageView?.image = image
    }
    
    
    //MARK: Animate to editing controller
    private func animateToEditingController(editingController : EditViewController)
    {
        self.movingToInternalView = true
        editingController.image = self.image
        editingController.delegate = self
        self.navigationController?.delegate = self
        self.navigationController?.pushViewController(editingController, animated: true)
    }
    
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if fromVC == self
        {
            movingForward = true
        }
        else
        {
            movingForward = false
        }
        
        return self
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        //Get the required views etc.
        var containerView : UIView = transitionContext.containerView()
        var duration : NSTimeInterval = self.transitionDuration(transitionContext)
        var halfDuration : NSTimeInterval = duration * 0.5
        
        if movingForward
        {
            var editVc : EditViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as EditViewController
            
            UIView.animateWithDuration(halfDuration, animations: { () -> Void in
                
                    //Animate out bottom view of Image Editing Controller
                    var frame : CGRect? = self.collectionView?.frame
                    self.collectionViewTopConstraint?.constant = frame!.size.height
                    self.view.layoutIfNeeded()
                
                }, completion: { (completedStepOne : Bool) -> Void in
                
                    //change views shown in the container view
                    containerView.addSubview(editVc.view)
                    self.view.removeFromSuperview()
                    
                    //prepare to animate in bottom views
                    editVc.prepareToAnimateInBottomViews()
                
                    UIView.animateWithDuration(halfDuration, animations: { () -> Void in
                        
                        //Animate in bottom views of Edit View Controller
                        editVc.animateInBottomViews()
                        
                        }, completion: { (completedStepTwo : Bool) -> Void in
                        
                            self.movingToInternalView = false
                            transitionContext.completeTransition(true)
                    })
            })
        }
        else
        {
            var editVc : EditViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as EditViewController
            
            UIView.animateWithDuration(halfDuration, animations: { () -> Void in
                
                //Animate out bottom views of Edit View Controller
                editVc.animateOutBottomViews()
                
                }, completion: { (completedStepOne : Bool) -> Void in
                
                    
                    //change over the views in the container view
                    editVc.view.removeFromSuperview()
                    containerView.addSubview(self.view)
                    
                    
                    UIView.animateWithDuration(halfDuration, animations: { () -> Void in
                        
                        //Animate in bottom views of Image Editing Controller
                        var frame : CGRect? = self.collectionView?.frame
                        self.collectionViewTopConstraint?.constant = 0.0
                        self.view.layoutIfNeeded()
                        
                        }, completion: { (completedStepTwo : Bool) -> Void in
                        
                            transitionContext.completeTransition(true)
                    })
            })
        }
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
    
}
