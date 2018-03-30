//
//  SKContentDataSource.swift
//  SKFoundation
//
//  Created by Britton Katnich on 2017-12-29.
//  Copyright © 2017 SandKatt Solutions Inc. All rights reserved.
//

import Foundation


/**
 * A SKContentDataSource holds information about an entire feature in the SKFoundation platform.
 */
@objc public protocol SKContentDataSource
{
    // MARK: -- Properties --
    
    var filename: String { get }
    var fileExtension: String { get }
    
    static func dataSource() -> SKContentDataSource
}
