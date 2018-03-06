//
//  SKUIKIt.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-02-19.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SKFoundation


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
