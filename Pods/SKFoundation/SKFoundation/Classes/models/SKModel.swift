//
//  Model.swift
//  SKFoundation
//
//  Created by Britton Katnich on 2018-02-07.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import Foundation


public typealias SKModelCompletionHandler = (Array<SKModel>?, SKError?) -> Void


/**
 * The base protocol for all data models that need to participate at the platform level.
 */
public protocol SKModel: Codable, CustomDebugStringConvertible
{
    // MARK: -- Static --
    
    static func refreshData(parameters: Dictionary<String, Any>, completed: @escaping SKModelCompletionHandler) -> Void
}
