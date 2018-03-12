//
//  SKUIKIt.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-02-19.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SKFoundation
import ChameleonFramework


/**
 * SKUIKit is the core UI framework of the SandKatt iOS Platform.
 */
public class SKUIKit: SKFramework
{
    // MARK: Properties
    
    
    // MARK: Lifecycle
    
    /**
     * Start the initialization processes of the framework to provide common,
     * shared services both inside and outside the framework.
     */
    public static func start()
    {
        //
        // Global Theme
        //
        Chameleon.setGlobalThemeUsingPrimaryColor(FlatSkyBlue(),
            withSecondaryColor: FlatSkyBlue(),
            usingFontName: "HelveticaNeue",
            andContentStyle: UIContentStyle.contrast)
        
        //
        // Log startup state
        //
        log.debug("\n\n" + self.debugStatus() + "\n\n")
    }
    
    
    // MARK: Lifecycle
    
    /**
     * Retrieve the current debug values in a formatted String.
     *
     * @returns String.
     */
    public static func debugStatus() -> String
    {
        //
        // Log startup state
        //
        let debugStatus =
            "-- Style --"
        
        return debugStatus
    }
}


// MARK: -- Extensions --

/**
 * todo
 */
public extension DispatchTimeInterval
{
    public var fromNow: DispatchTime
    {
        return DispatchTime.now() + self
    }
}


/**
 * todo
 */
public extension Int
{
    public var seconds: DispatchTimeInterval
    {
        return DispatchTimeInterval.seconds(self)
    }
    
    
    public var second: DispatchTimeInterval
    {
        return seconds
    }
    
    
    public var milliseconds: DispatchTimeInterval
    {
        return DispatchTimeInterval.milliseconds(self)
    }
    
    
    public var millisecond: DispatchTimeInterval
    {
        return milliseconds
    }
}


/**
 * Notification extensions.
 */
public extension UIViewController
{
    /**
     * The currently selected ContentHolder
     */
    public var currentContentHolder: SKContentHolder?
    {
        get
        {
            let contentManager = SKContentManager.shared().currentHolder
        
            return contentManager
        }
        
        set(newHolder)
        {
            let contentManager = SKContentManager.shared()
        
            contentManager.select(contentHolder: newHolder)
        }
    }
}
