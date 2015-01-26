//
//  ViewController.swift
//  ImageEditingFrameworkTest
//
//  Created by John Kartupelis on 19/01/2015.
//  Copyright (c) 2015 John Kartupelis. All rights reserved.
//

import UIKit
import ImageEditingFramework

class ViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        var img : UIImage = UIImage(named: "test-image")!;
        var imageEdit : UINavigationController = ImageEditingViewController.getImageEditingViewControllerWithImage(img);
        self.presentViewController(imageEdit, animated: true) { () -> Void in
            NSLog("%@", "Presented image editing view controller!");
        }
    }
    
    

}

