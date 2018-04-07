//
//  SKContentManager.swift
//  SKFoundation
//
//  Created by Britton Katnich on 2018-01-21.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit


/**
 * The SKContentManager handles all processes required to load and manage
 * SKContentDataSources and SKContentHolders within an application.
 */
public class SKContentManager: CustomDebugStringConvertible
{
    // MARK: -- Properties --
    
    /**
     * All known ContentHolders.
     */
    public var contentHolders: [SKContentHolder] = [SKContentHolder]()
    
    /**
     * The currently selected SKContentHolder
     */
    public var currentHolder: SKContentHolder?
    
    /**
     * The shared, singleton instance of the ContentManager.
     */
    private static var sharedContentManager: SKContentManager =
    {
        let contentManager = SKContentManager()

        return contentManager
    }()
    
    
    /**
     * CustomDebugStringConvertible
     */
    public var debugDescription : String
    {
        var desc: String = "Current content holder: " + (self.currentHolder == nil ? "<nothing selected>" : String(describing: self.currentHolder!))
            + "\n\n*** Content Holders ***\n\n"
        
        if self.contentHolders.isEmpty
        {
            desc.append("<none>")
        }
        
        else
        {
            for holder in self.contentHolders
            {
                desc.append(holder.debugDescription + "\n\n")
            }
        }
        
        return desc
    }

    
    // MARK: -- Lifecycle --

    /**
     * Default initialzation which triggers finding all ContentDataSources.
     */
    private init()
    {
        //
        // Locate all available ContentDataSources
        //
        self.findContent()
    }


    // MARK: -- Public --

    /**
     * Retrieves the shared, singleton instance of the SKContentManager.
     *
     * @returns SKContentManager
     */
    public class func shared() -> SKContentManager
    {
        return sharedContentManager
    }
    
    
    /**
     * Notify the SKContentManager of a new current holder selection.
     *
     * @returns SKContentHolder.
     */
    public func select(contentHolder current: SKContentHolder?) -> Void
    {
        self.currentHolder = current
    
        log.debug("\n\nCurrent content holder is now:\n\n" + String(describing: self.currentHolder))
        
        //
        // Notify interested observers
        //
        NotificationCenter.default.post(name: .CurrentContentHolderSelectedChange, object: nil)
    }
    
    
    // MARK: -- Private --
    
    /**
     * Locates any SKContentDataSources within an application.  It then will proceed to use
     * the information provided by each SKContentDataSource instance to instantiate a corresponding
     * SKContentDataSource.
     */
    private func findContent()
    {
        //log.debug("called")
        
        //
        // Obtain all class information
        //
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount:Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)

        //log.debug("actual class count: \(actualClassCount)")
    
        //
        // Iterate all discovered classes
        //
        for i in 0 ..< actualClassCount
        {
            //
            // Retrieve each class
            //
            if let currentClass: AnyClass = allClasses[Int(i)]
            {
                //log.debug("retrieved class: \(currentClass)")
                
                //
                // Detect if the class comforms to the protocol
                //
                if class_conformsToProtocol(currentClass, SKContentDataSource.self)
                {
                    //log.debug("found conforming class")
                    
                    //
                    // Instantiate the data source
                    //
                    let contentDataSource: SKContentDataSource.Type = currentClass as! SKContentDataSource.Type
                    let dataSource: SKContentDataSource = contentDataSource.dataSource()
                    
                    //
                    // Instantiate the content holder
                    //
                    let contentHolder = SKContentDataHolder.holder(from: dataSource)
                    self.contentHolders.append(contentHolder)
                    
                    //log.debug("\tappended content holder: \(contentHolder)")
                }
            }
        }

        //
        // Sort in priority order
        //
        self.contentHolders = self.contentHolders.sorted(by: { $0.priority < $1.priority })
        
        allClasses.deallocate()
        
        //
        // Notify interested observers
        //
        NotificationCenter.default.post(name: .ContentHoldersLoaded, object: nil)
    }
}
