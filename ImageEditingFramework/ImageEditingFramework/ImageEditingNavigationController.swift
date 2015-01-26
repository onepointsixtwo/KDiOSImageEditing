//
//  ImageEditingNavigationController.swift
//  ImageEditingFramework
//
//  Created by John Kartupelis on 20/01/2015.
//  Copyright (c) 2015 John Kartupelis. All rights reserved.
//

import UIKit

class ImageEditingNavigationController: UINavigationController {

    //MARK: Overridden status bar style
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
}
