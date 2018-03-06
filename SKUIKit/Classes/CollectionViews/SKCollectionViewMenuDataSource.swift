//
//  SKCollectionViewMenuDataSource.swift
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
@objc public protocol SKCollectionViewMenuDataSource: UICollectionViewDataSource, UICollectionViewDelegate
{
    /**
     *
     */
    func reloadData()
}


/**
 *
 */
open class SKAbstractCollectionViewMenuDataSource: NSObject, SKCollectionViewMenuDataSource
{
    // MARK: -- Properties --
    
    var collectionView: UICollectionView
    
    
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
        
        // todo:
        
        self.collectionView.reloadData()
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
        let itemCount = SKContentManager.shared().contentHolders.count
        
        log.debug("called for section: \(section) and returning item count: \(itemCount)")
        
        return itemCount
    }

    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        log.debug("called with indexPath: \(indexPath)")

        //
        // Retrieve cell
        //
        let cell: SKCollectionViewMenuCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing:SKCollectionViewMenuCell.self),
            for: indexPath) as! SKCollectionViewMenuCell
        
        //
        // Update cell contents
        //
        let holder = SKContentManager.shared().contentHolders[indexPath.item]
        cell.contentHolder = holder
        
        return cell
    }
    
    
    // MARK: -- UICollectionViewDelegate --
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        log.debug("called with indexPath: \(indexPath)")
        
        let holder = SKContentManager.shared().contentHolders[indexPath.item]
        
        //
        // Automagically set the current holder context in the root system
        //
        let contentManager = SKContentManager.shared()
        contentManager.currentHolder = holder
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        log.debug("called with indexPath: \(indexPath)")
    }
}
