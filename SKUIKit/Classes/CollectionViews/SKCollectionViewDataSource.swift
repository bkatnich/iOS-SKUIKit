//
//  SKCollectionViewDataSource.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-02-18.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SandKattFoundation


/**
 *
 */
@objc public protocol SKCollectionViewDataSource: UICollectionViewDataSource, UICollectionViewDelegate
{
    /**
     *
     */
    func reloadData()
}


/**
 *
 */
open class SKAbstractCollectionViewDataSource<T: SKModel>: NSObject, SKCollectionViewDataSource
{
    // MARK: -- Properties --
    
    var collectionView: UICollectionView
    var items: Array<T> = Array<T>()
    
    
    // MARK: -- Lifecycle --
    
    public init(collectionView: UICollectionView)
    {
        log.debug("called with collectionView: \(collectionView)")
        
        self.collectionView = collectionView
        
        super.init()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    
    // MARK: -- SKCollectionViewDataSource --
    
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
            
            self.collectionView.reloadData()
        }
    }
    
    
    // MARK: -- UICollecionViewDataSource --
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        let sectionCount = 1
        
        log.debug("called and returning section count: \(sectionCount)")
        
        return sectionCount
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let itemCount = items.count
        
        log.debug("called for section: \(section) and returning item count: \(itemCount)")
        
        return itemCount
    }

    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        log.debug("called with indexPath: \(indexPath)")

        //
        // Retrieve cell
        //
        let cell: SKCollectionViewCell<T> = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing:T.self),
            for: indexPath) as! SKCollectionViewCell<T>
        
        //
        // Update cell contents
        //
        let model = self.items[indexPath.row]
        cell.model = model
        
        return cell
    }
    
    
    // MARK: -- UICollectionViewDelegate --
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        log.debug("called with indexPath: \(indexPath)")
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {

    }
}

