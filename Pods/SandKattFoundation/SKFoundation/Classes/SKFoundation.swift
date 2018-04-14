//
//  SKFoundation.swift
//  SKFoundation
//
//  Created by Britton Katnich on 2018-01-04.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SwiftyBeaver

public let log = SwiftyBeaver.self


/**
 * SKFoundation is the core framework of the SandKatt iOS Platform.
 */
public class SKFoundation
{
    // MARK: Properties
    
    public static var configurationInfo = SKFoundation.findConfiguration()
    static var siblingFrameworks = SKFoundation.findSiblingFrameworks()
    
    
    // MARK: Lifecycle
    
    /**
     * Start the initialization processes of the framework to provide common,
     * shared services both inside and outside the framework.
     */
    public static func start()
    {
        //
        // Logging
        //
        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss$d $N.$F():$l $L: $M"
        log.addDestination(console)
        
        SKNetworkManager.shared.startListening()
        
        //
        // Log startup state
        //
        log.debug("\n\n" + self.debugStatus() + "\n\n")
    }
    
    
    /**
     * Retrieve the current debug values in a formatted String.
     *
     * @returns String.
     */
    public static func debugStatus() -> String
    {
        let configurationData = try! JSONSerialization.data(withJSONObject: self.configurationInfo, options: [.prettyPrinted])
        let configurationDecoded = String(data: configurationData, encoding: .utf8)!
        
        //
        // Log startup state
        //
        let debugStatus =
            "-- Application --" +
            "\n\nname: " + Bundle.appName() +
            "\nversion: " + Bundle.versionAndBuildNumber() +
            "\nbuild date: " + Bundle.buildDate() +
            "\norganization: " + Bundle.organization() +

            "\n\n\n-- Sibling Frameworks --\n\n" + String(describing: self.siblingFrameworks) +
            
            "\n\n\n-- Content Holder --\n\n" + String(describing: SKContentManager.shared().debugDescription) +

            "\n\n\n-- Configuration --\n\n" + configurationDecoded
        
        return debugStatus
    }
    
    
    // MARK: -- Private --
    
    /**
     * Retrieve the master configuration.
     */
    private static func findConfiguration() -> Dictionary<String, Any>
    {
        //
        // Find the SandKatt configuration values, if they exist
        //
        if let info = Bundle.main.object(forInfoDictionaryKey: "SandKatt") as? [String : Any]
        {
            return info
        
        } else { log.warning("no SandKatt entry found") }
        
        return Dictionary<String, Any>()
    }
    
    
    /**
     * Retrieve any sibiling SandKatt frameworks in the application runtime.
     */
    private static func findSiblingFrameworks() -> Array<SKFramework.Type>
    {
        var frameworks = Array<SKFramework.Type>()
        
        //
        // Obtain all class information
        //
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount:Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)

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
                //
                // Detect if the class comforms to the protocol
                //
                if class_conformsToProtocol(currentClass, SKFramework.self)
                {
                    //
                    // Start the framework
                    //
                    let framework: SKFramework.Type = currentClass as! SKFramework.Type
                    framework.start()
                    
                    frameworks.append(framework)
                }
            }
        }

        allClasses.deallocate()
        
        return frameworks
    }
}


// MARK: -- Enumerations --

/**
 * SKFoundatiion general error types.
 */
public enum SKError: Error
{
    case apiCallFailed(title: String, detail: String)
    case networkUrlNotConstructed(String)
    case serializationFailed(String)
}


// MARK: -- CompletionHandlers --

public typealias ArrayCompletionHandler = (Array<AnyObject>?, SKError?) -> Void
public typealias ContentHolderCompletionHandler = (SKContentHolder?, SKError?) -> Void
public typealias DictionaryCompletionHandler = (Dictionary<String, AnyObject>?, SKError?) -> Void
public typealias ErrorCompletionHandler = (Bool, SKError?) -> Void
public typealias JsonCompletionHandler = (String?, SKError?) -> Void


// MARK: -- Extensions --

/**
 * Bundle Extensions
 */
public extension Bundle
{
    // MARK: -- Properties --
    
    /**
     * Retrieve a bundle by it's name identifier.  It's prefix is
     * appended internally.
     *
     * For example, if the prefix is "com.foo" and the bundle name
     * is "Fighter".  It will search for the Bundle "com.foo.Fighter".
     *
     * @param named String
     * @returns Bundle?
     */
    public class func bundle(named: String) -> Bundle?
    {
        return Bundle(identifier: Bundle.prefix(append: named))
    }
    
    
    /**
     * Retrieve a bundle by it's identifier information which is contained
     * within a ContentHolder.  It's prefix is appended internally.
     *
     * For example, if the prefix is "com.foo" and the bundle name
     * is "Fighter".  It will search for the Bundle "com.foo.Fighter".
     *
     * However, if the ContentHolder.isInternal property is 'true' it defaults
     * to returning the main bundle.
     *
     * @param contentHolder SKContentHolder
     * @returns Bundle?
     */
    public class func bundle(forContentHolder contentHolder: SKContentHolder) -> Bundle?
    {
        return (contentHolder.isInternal ? Bundle.main : bundle(named:contentHolder.identifier))
    }
    
    
    // MARK: -- Main Bundle Additions --
    
    /**
     * Retrieve the app name.
     *
     * @returns String
     */
    static func appName() -> String
    {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    }
    
    
    /**
     * Retrieve the build date.
     *
     * @returns String
     */
    static func buildDate() -> String
    {
        if let value = SKFoundation.configurationInfo["BuildDate"] as? String
        {
            return value
        }
        
        return "<not set>"
    }
    
    
    /**
     * Return the build number.
     *
     * @returns String
     */
    static func buildNumber() -> String
    {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
    
    
    /**
     * Retrieve the organization's name.
     *
     * @returns String
     */
    static func organization() -> String
    {
        if let value = SKFoundation.configurationInfo["Organization"] as? String
        {
            return value
        }
        
        return "<not set>"
    }
    
    
    /**
     * Retrieve the app's prefix identifier.
     *
     * @returns String
     */
    static func prefix() -> String
    {
        if let value = SKFoundation.configurationInfo["Prefix"] as? String
        {
            return value
        }
        
        return "<not set>"
    }
    
    
    /**
     * Append the fragment String to the current prefix identifier.
     *
     * For example, if the given fragment is "Fighter" and the prefix
     * is "com.foo" the returned value will be: "com.foo.Fighter".
     *
     * @returns String
     */
    static func prefix(append fragment: String) -> String
    {
        return self.prefix() + "." + fragment
    }
    
    
    /**
     * Retrieve the version String.
     *
     * @returns String.
     */
    static func version() -> String
    {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    
    /**
     * Retrieve the combined version and builder number.
     *
     * For example, if the version is "1.5.11" and the builder number is "4" the
     * returned value will be in the format "1.5.11 (4)"
     *
     * @returns String
     */
    static func versionAndBuildNumber() -> String
    {
        return self.version() + " (" + self.buildNumber() + ")"
    }
}


/**
 * Notification extensions.
 */
public extension Notification.Name
{
    /**
     * Static Notification.Name representing a Notification triggered when ContentHolders
     * are loaded.
     */
    static let ContentHoldersLoaded = Notification.Name("ContentHoldersLoaded")
    
    /**
     * Static Notification.Name representing a Notification triggered when there is a change
     * to the currently selected ContentHolder.
     */
    static let CurrentContentHolderSelectedChange = Notification.Name("CurrentContentHolderSelectedChange")

    /**
     * Static Notification.Name representing a Notification triggered when the network status changed.
     */
    static let NetworkStatusChanged = Notification.Name("NetworkStatusChanged")
}
