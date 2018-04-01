//
//  SKTableViewMenuCell.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-02-19.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SandKattFoundation


/**
 *
 */
open class SKTableViewMenuCell: UITableViewCell
{
    // MARK: -- Properties --
    
    open var contentHolder: SKContentHolder?
    {
        didSet
        {
            //
            // Inform the cell to update itself
            //
            self.refreshCell()
        }
    }
    
    
    // MARK: -- IBOutlets --
    
    @IBOutlet open weak var titleLabel: UILabel?
    @IBOutlet open weak var iconView: UIImageView?
    
    
    // MARK: -- Lifecycle --
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    open override func prepareForReuse()
    {
        super.prepareForReuse()
        
        self.contentHolder = nil
    }
    
    
    // MARK: -- Public --
    
    /**
     * Subclassable function that is triggered when the cell's Model
     * is update with a new value.  This should be subclasses to
     * update that subclasses specific view component states.
     */
    open func refreshCell()
    {
        self.titleLabel?.text = self.contentHolder?.title
        self.iconView?.image = self.contentHolder?.iconImage()
    }
}
