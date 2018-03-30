//
//  SKFramework.swift
//  SKFoundation
//
//  Created by Britton Katnich on 2018-03-11.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import Foundation


/**
 * The SKFramework protocol should be implemented on the self-named framework main struct.
 */
@objc public protocol SKFramework
{
    /**
     * Start the initialization processes of the framework to provide common,
     * shared services both inside and outside the framework.
     */
    static func start();


    /**
     * Retrieve the current runtime status of the framework.
     *
     * @return String
     */
    static func debugStatus() -> String
}
