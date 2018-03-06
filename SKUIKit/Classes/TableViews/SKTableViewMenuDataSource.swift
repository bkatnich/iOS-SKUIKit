//
//  SKTableViewMenuDataSource.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-02-19.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SKFoundation


/**
 *
 */
@objc public protocol SKTableViewMenuDataSource: UITableViewDataSource, UITableViewDelegate
{
    /**
     *
     */
    func reloadData()
}


/**
 *
 */
open class SKAbstractTableViewMenuDataSource: NSObject, SKTableViewMenuDataSource
{
    // MARK: -- Properties --
    
    var tableView: UITableView
    
    
    // MARK: -- Lifecycle --
    
    public init(tableView: UITableView)
    {
        log.debug("called with tableView: \(tableView)")
        
        self.tableView = tableView
        
        super.init()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    
    // MARK: -- SKTableDataSource --
    
    public func reloadData()
    {
        log.debug("called")
        
        self.tableView.reloadData()
    }
    
    
    // MARK: -- UITableViewDataSource --
    
    open func numberOfSections(in tableView: UITableView) -> Int
    {
        let sectionCount = 1
        
        log.debug("called and returning section count: \(sectionCount)")
        
        return sectionCount
    }


    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let rowCount = SKContentManager.shared().contentHolders.count
        
        log.debug("called for section: \(section) and returning row count: \(rowCount)")
        
        return rowCount
    }


    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        log.debug("called with indexPath: \(indexPath)")

        //
        // Retrieve cell
        //
        let cell: SKTableViewMenuCell = tableView.dequeueReusableCell(
            withIdentifier: String(describing:SKTableViewMenuCell.self),
            for: indexPath) as! SKTableViewMenuCell
        
        //
        // Update cell contents
        //
        let holder = SKContentManager.shared().contentHolders[indexPath.item]
        cell.contentHolder = holder
        
        return cell
    }
    
    
    // MARK: -- UITableViewDelegate --
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        log.debug("called with indexPath: \(indexPath)")
        
        let holder = SKContentManager.shared().contentHolders[indexPath.item]
        
        //
        // Automagically set the current holder context in the root system
        //
        let contentManager = SKContentManager.shared()
        contentManager.currentHolder = holder
    }
    
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        log.debug("called with indexPath: \(indexPath)")
    }
}
