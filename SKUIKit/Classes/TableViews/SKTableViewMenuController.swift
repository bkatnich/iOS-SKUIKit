//
//  SKTableViewMenuController.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-02-19.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SKFoundation


/**
 * The SandKatt base version of a custom menu focused ViewController with
 * a table view.  It is specifically concerned with ContentHolders available
 * within the application to show it's menu items.
 */
open class SKTableViewMenuController: UIViewController
{
    // MARK: -- Properties --
    
    open var dataSource: SKTableViewMenuDataSource?
    
    
    // MARK: -- IBOutlets --
    
    @IBOutlet open weak var tableView: UITableView?


    // MARK: -- Lifecycle --

    open override func viewDidLoad()
    {
        super.viewDidLoad()
        
        log.debug("called")
        
        self.dataSource = (SKAbstractTableViewMenuDataSource(viewController: self)
            as SKTableViewMenuDataSource)
    }


    open override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
