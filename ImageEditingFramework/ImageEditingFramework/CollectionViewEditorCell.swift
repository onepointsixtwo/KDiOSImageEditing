//
//  CollectionViewEditorCell.swift
//  ImageEditingFramework
//
//  Created by John Kartupelis on 21/01/2015.
//  Copyright (c) 2015 John Kartupelis. All rights reserved.
//

import UIKit

class CollectionViewEditorCell: UICollectionViewCell {

    required init(coder aDecoder: NSCoder) {
        _highlighted = false
        super.init(coder: aDecoder)
    }
    
    private var _highlighted : Bool
    override var highlighted : Bool
    {
        set
        {
            _highlighted = newValue
            
            if(_highlighted)
            {
                self.alpha = 0.4
            }
            else
            {
                self.alpha = 1.0
            }
        }
        get
        {
            return _highlighted
        }
    }
    
}
