//
//  SKCollectionViewCell.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-02-05.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SKFoundation


/**
 * The base SandKatt version of the UICollectionViewCell.  It uses generics
 * to better enable reuse at the core layer.
 */
open class SKCollectionViewCell<T: SKModel>: UICollectionViewCell
{
    // MARK: -- Properties --
    
    open var model: T?
    {
        didSet
        {
            //
            // Inform the cell to update itself
            //
            self.refreshCell()
        }
    }
    
    
    // MARK: -- Lifecycle --
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    open override func prepareForReuse()
    {
        super.prepareForReuse()
        
        self.model = nil
    }
    
    
    // MARK: -- Public --
    
    /**
     * Subclassable function that is triggered when the cell's Model
     * is update with a new value.  This should be subclasses to
     * update that subclasses specific view component states.
     */
    open func refreshCell()
    {
        // should be overriden by subclasses to update view contents
    }
}
