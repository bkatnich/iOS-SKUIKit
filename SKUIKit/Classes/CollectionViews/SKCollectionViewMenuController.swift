//
//  SKCollectionViewMenuController.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-02-19.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SKFoundation


/**
 * The SandKatt base version of a custom menu focused ViewController with
 * a collection view.  It is specifically concerned with ContentHolders
 * available within the application to show it's menu items.
 */
open class SKCollectionViewMenuController: UIViewController
{
    // MARK: -- Properties --
    
    open var dataSource: SKCollectionViewMenuDataSource?
    
    
    // MARK: -- IBOutlets --
    
    @IBOutlet open weak var collectionView: UICollectionView?


    // MARK: -- Lifecycle --

    open override func viewDidLoad()
    {
        super.viewDidLoad()
        
        log.debug("called")
        
        self.dataSource = (SKAbstractCollectionViewMenuDataSource(
            collectionView: self.collectionView!) as SKCollectionViewMenuDataSource)
    }


    open override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
        log.warning("called")
    }
}
