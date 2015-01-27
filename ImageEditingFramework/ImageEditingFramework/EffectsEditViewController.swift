//
//  EffectsEditViewController.swift
//  ImageEditingFramework
//
//  Created by John Kartupelis on 22/01/2015.
//  Copyright (c) 2015 John Kartupelis. All rights reserved.
//

import UIKit

/*
Need to set up an object which contains an array of filters to be used on each effect type - these can then be run on the ciimage - an array of these objects can be used as the data source for the collection view, and can hold an image cached for the effect type...
*/

public class EffectsEditViewController: EditViewController, UICollectionViewDataSource, UICollectionViewDelegate {
   
    //MARK: Properties
    let cellIdentifier : NSString = "cell"
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
    var ciImage : CIImage? = nil
    var ciContext : CIContext? = nil
    var collectionView : UICollectionView? = nil
    var activityIndicatorView : UIActivityIndicatorView? = nil
    var settingMainImage : Bool = false
    var selectedImageIndex : Int = 0
    var _collectionViewData : [EffectInfo]?
    var collectionViewData : [EffectInfo]
    {
        //Create getter for collection view data.
        if(_collectionViewData == nil)
        {
            //Create the array
            var array : [EffectInfo] = []
            
            //Add the effects
            array.append(self.instantEffect())
            array.append(self.vintageEffect())
            array.append(self.vintageBlackAndWhiteEffect())
            array.append(self.lushEffect())
            array.append(self.coolEffect())
            array.append(self.redBlueEffect())
            array.append(self.cartoonEffect())
            array.append(self.sepiaEffect());
            array.append(self.blackAndWhiteEffect())
            array.append(self.invertedEffect())
            
            _collectionViewData = array
        }
        return _collectionViewData!
    }
    
    
    
    //MARK: Effects
    func instantEffect() -> EffectInfo
    {
        var filters : [CIFilter] = [ CIFilter(name: "CIPhotoEffectInstant", withInputParameters: nil) ]
        var info = EffectInfo(nameIn: "Instant", withFilters: filters)
        return info
    }
    
    func vintageEffect() -> EffectInfo
    {
        var filters : [CIFilter] = [ CIFilter(name: "CIPhotoEffectTransfer", withInputParameters: nil) ]
        var info = EffectInfo(nameIn: "Vintage", withFilters: filters)
        return info
    }
    
    func vintageBlackAndWhiteEffect() -> EffectInfo
    {
        var filters : [CIFilter] = [ CIFilter(name: "CIPhotoEffectMono", withInputParameters: nil) ]
        var info = EffectInfo(nameIn: "Vintage B&W", withFilters: filters)
        return info
    }
    
    func vignetteEffect() -> EffectInfo
    {
        var filters : [CIFilter] = [ CIFilter(name: "CIVignette", withInputParameters: nil) ]
        var info = EffectInfo(nameIn: "Vignette", withFilters: filters)
        return info
    }
    
    func lushEffect() -> EffectInfo
    {
        var filters : [CIFilter] = [ CIFilter(name: "CIPhotoEffectChrome", withInputParameters: nil) ]
        var info = EffectInfo(nameIn: "Vintage", withFilters: filters)
        return info
    }
    
    func bleakEffect() -> EffectInfo
    {
        var filters : [CIFilter] = [ CIFilter(name: "CIPhotoEffectFade", withInputParameters: nil) ]
        var info = EffectInfo(nameIn: "Bleak", withFilters: filters)
        return info
    }
    
    func coolEffect() -> EffectInfo
    {
        var filters : [CIFilter] = [ CIFilter(name: "CIPhotoEffectProcess", withInputParameters: nil) ]
        var info = EffectInfo(nameIn: "Cool", withFilters: filters)
        return info
    }
    
    func redBlueEffect() -> EffectInfo
    {
        var filters : [CIFilter] = [ CIFilter(name: "CIColorMonochrome", withInputParameters: ["inputColor": CIColor(CGColor: UIColor.redColor().CGColor), "inputIntensity": 0.1]),  CIFilter(name: "CIColorMonochrome", withInputParameters: ["inputColor": CIColor(CGColor: UIColor.blueColor().CGColor), "inputIntensity": 0.2]) ]
        var info = EffectInfo(nameIn: "Darkness", withFilters: filters)
        return info
    }
    
    func cartoonEffect() -> EffectInfo
    {
        var filters : [CIFilter] = [ CIFilter(name: "CIColorPosterize", withInputParameters: nil) ]
        var info = EffectInfo(nameIn: "Cartoon", withFilters: filters)
        return info
    }
    
    func sepiaEffect() -> EffectInfo
    {
        var filters : [CIFilter] = [ CIFilter(name: "CISepiaTone", withInputParameters: ["inputIntensity": 1.2]) ]
        var info = EffectInfo(nameIn: "Sepia", withFilters: filters)
        return info
    }
    
    func blackAndWhiteEffect() -> EffectInfo
    {
        var filters : [CIFilter] = [ CIFilter(name: "CIPhotoEffectTonal", withInputParameters: nil) ]
        var info = EffectInfo(nameIn: "B&W", withFilters: filters)
        return info
    }
    
    func invertedEffect() -> EffectInfo
    {
        var filters : [CIFilter] = [ CIFilter(name: "CIColorInvert", withInputParameters: nil) ]
        var info = EffectInfo(nameIn: "Inverted", withFilters: filters)
        return info
    }
    
    
    
    
    //MARK: Internal Types
    class EffectInfo : NSObject
    {
        var filters : [CIFilter]
        var name : String
        var storedImage : UIImage?
        
        init(nameIn : String, withFilters filtersIn : [CIFilter])
        {
            name = nameIn
            filters = filtersIn
            super.init()
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
    
    
    
    
    //MARK: Helpers
    //node the closure used for finish syntax - closure rather than block in swift!
    func applyFilters(filters : [CIFilter], toImage ciImg : CIImage, finished: ((image : UIImage?) -> Void)?)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
          
            var startingExtent = ciImg.extent()
            var ci = ciImg
            
            for filter : CIFilter in filters
            {
                filter.setValue(ci, forKey: kCIInputImageKey)
                ci = filter.outputImage
            }
            
            var cgimg =  self.ciContext?.createCGImage(ci, fromRect: startingExtent)
            var img = UIImage(CGImage: cgimg)
            
            if(finished != nil)
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    finished!(image: img)
                })
            }
        })
    }
    
    
    
    //MARK: Overridden transition handling
    public override func prepareToAnimateInBottomViews()
    {
        //get reference to lower view
        var lowerV : UIView = self.lowerView!
        
        //create collection view flow layout
        var collectionViewFlowLayout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        collectionViewFlowLayout.itemSize = CGSizeMake(79, 79)
        collectionViewFlowLayout.minimumInteritemSpacing = 4.0
        collectionViewFlowLayout.minimumLineSpacing = 4.0
        
        //create collection view
        var frame : CGRect = lowerV.bounds
        frame.origin.y = lowerV.frame.size.height
        var collView : UICollectionView = UICollectionView(frame: frame, collectionViewLayout: collectionViewFlowLayout)
        collView.alwaysBounceHorizontal = false
        collView.bounces = false
        collView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        collView.delegate = self
        collView.dataSource = self
        collView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5)
        collView.showsHorizontalScrollIndicator = false
        collView.backgroundColor = UIColor.clearColor()
        var bundle = NSBundle(identifier: "kartdev.ImageEditingFramework")!
        collView.registerNib(UINib(nibName: "CollectionViewEffectCell", bundle: bundle), forCellWithReuseIdentifier: cellIdentifier)
        lowerV.addSubview(collView)
        lowerV.userInteractionEnabled = true
        
        //set collection view instance property
        self.collectionView = collView
    }
    
    public override func animateInBottomViews()
    {
        //set collection view height constraint to 0.0
        var collView = self.collectionView!
        var frame = collView.frame
        frame.origin.y = 0.0
        collView.frame = frame
    }
    
    public override func animateOutBottomViews()
    {
        //set collection view height constraint to -height again
        var collView = self.collectionView!
        var frame = collView.frame
        frame.origin.y = frame.size.height
        collView.frame = frame
    }
    
    
    //MARK: UICollectionView Delegate / Data Source
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewData.count + 1
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell : UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as UICollectionViewCell;
        
        //Get the cell's inner views
        var cellImageView : UIImageView = cell.viewWithTag(1) as UIImageView
        cellImageView.contentMode = UIViewContentMode.ScaleAspectFill
        cellImageView.clipsToBounds = true
        var cellLabel : UILabel = cell.viewWithTag(2) as UILabel
        var cellActivityIndicator : UIActivityIndicatorView = cell.viewWithTag(3) as UIActivityIndicatorView
        
        var index = indexPath.row
        
        //Set cell selected state
        if(index == self.selectedImageIndex)
        {
            cell.backgroundColor = UIColor(white: 0.75, alpha: 0.8);
        }
        else
        {
            cell.backgroundColor = UIColor(white: 1.0, alpha: 1.0);
        }
        
        //Setup cell contents
        if(index > 0)
        {
            //get the object for the row
            var info : EffectInfo = collectionViewData[index - 1]
            
            //set label text
            cellLabel.text = info.name
            
            //set image
            if(info.storedImage == nil)
            {
                cellActivityIndicator.startAnimating()
                self.applyFilters(info.filters, toImage: self.ciImage!, finished: { (image : UIImage?) -> Void in
                    cellActivityIndicator.stopAnimating()
                    info.storedImage = image
                    cellImageView.image = image
                })
            }
            else
            {
                cellImageView.image = info.storedImage
            }
        }
        else
        {
            var unchangedImg = ciContext?.createCGImage(self.ciImage!, fromRect: self.ciImage!.extent())
            var unchangedUiImg = UIImage(CGImage: unchangedImg)
            cellImageView.image = unchangedUiImg
            cellLabel.text = "Original"
        }
        
        return cell;
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        var index = indexPath.row
        
        if(index > 0)
        {
            //get the object for the row
            var info : EffectInfo = collectionViewData[index - 1]
            
            //set image
            if(info.storedImage == nil)
            {
                self.applyFilters(info.filters, toImage: self.ciImage!, finished: { (image : UIImage?) -> Void in
                    self.imageView?.image = info.storedImage
                    self.image = info.storedImage
                })
            }
            else
            {
                self.imageView?.image = info.storedImage
                self.image = info.storedImage
            }
        }
        else
        {
            var unchangedImg = ciContext?.createCGImage(self.ciImage!, fromRect: self.ciImage!.extent())
            var unchangedUiImg = UIImage(CGImage: unchangedImg)
            self.image = unchangedUiImg
            self.imageView?.image = unchangedUiImg
        }
        
        selectedImageIndex = indexPath.row
        collectionView.reloadData()
    }
}
