//
//  SKTableViewController.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-02-05.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SandKattFoundation


/**
 * The SandKatt base version of a custom ViewController with a table view.
 * It is specifically concerned with ContentHolders available within the
 * application to show it's menu items.
 */
open class SKTableViewController: UIViewController
{
    // MARK: -- Properties --
    
    open var dataSource: SKTableViewDataSource?
    
    
    // MARK: -- IBOutlets --
    
    @IBOutlet open weak var tableView: UITableView?


    // MARK: -- Lifecycle --

    open override func viewDidLoad()
    {
        super.viewDidLoad()
    }


    open override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
        log.warning("called")
    }
}
