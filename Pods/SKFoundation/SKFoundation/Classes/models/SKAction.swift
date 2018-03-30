//
//  SKAction.swift
//  SKFoundation
//
//  Created by Britton Katnich on 2018-03-04.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import Foundation


/**
 * SKAction protocol defines a 'command' in the Command Pattern.
 */
@objc public protocol SKAction
{
    /**
     * All SKActions must implement this function to execute
     * desired functionality.
     *
     * @completion (completed: Bool, error: Error?) -> Void callback closure.
     */
    func execute(completion: @escaping (Bool, Error?) -> Void)
}
