//
//  SKCollectionViewController.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-02-05.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SKFoundation


/**
 * The SandKatt base version of a custom ViewController with a collection view.  It utilizes generics
 * to enhance it's usability across the core platform.
 */
open class SKCollectionViewController: UIViewController
{
    // MARK: -- Properties --
    
    open var dataSource: SKCollectionViewDataSource?
    
    
    // MARK: -- IBOutlets --
    
    @IBOutlet open weak var collectionView: UICollectionView?


    // MARK: -- Lifecycle --

    open override func viewDidLoad()
    {
        super.viewDidLoad()
        
        log.debug("called")
    }


    open override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
        log.warning("called")
    }
}
