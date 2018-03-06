//
//  SKTableViewDataSource.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-02-10.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SKFoundation


/**
 *
 */
@objc public protocol SKTableViewDataSource: UITableViewDataSource, UITableViewDelegate
{
    /**
     *
     */
    func reloadData()
}


/**
 *
 */
open class SKAbstractTableViewDataSource<T: SKModel>: NSObject, SKTableViewDataSource
{
    // MARK: -- Properties --
    
    var tableView: UITableView
    var items: Array<T> = Array<T>()
    
    
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
        
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -16, to: Date())
        
        var parameters = Dictionary<String, Any>()
        parameters["from"] = startDate
        parameters["to"] = Date()
        
        log.debug("The generic type is: \(T.self)")
        
        //
        // Initiate call for new data from the specific 
        //
        T.self.refreshData(parameters: parameters) { (models, error) in
    
            log.debug("Generic.refreshData called")
            
            if error != nil
            {
                log.error(error as Any)
                return
            }
            
            guard let models = models
            else
            {
                log.error("No models returns in refresh")
                return
            }
            
            self.items.removeAll()
            for model in models
            {
                self.items.append(model as! T)
            }
            
            self.tableView.reloadData()
        }
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
        let rowCount = items.count
        
        log.debug("called for section: \(section) and returning row count: \(rowCount)")
        
        return rowCount
    }


    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        log.debug("called with indexPath: \(indexPath)")

        //
        // Retrieve cell
        //
        let cell: SKTableViewCell<T> = tableView.dequeueReusableCell(
            withIdentifier: String(describing:T.self),
            for: indexPath) as! SKTableViewCell<T>
        
        //
        // Update cell contents
        //
        let model = self.items[indexPath.row]
        cell.model = model
        
        return cell
    }
    
    
    // MARK: -- UITableViewDelegate --
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        log.debug("called with indexPath: \(indexPath)")
    }
    
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        log.debug("called with indexPath: \(indexPath)")
    }
}
