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
    
    static let network = SKNetwork.shared()
    static let content = SKContentManager.shared()
    
    
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
        
        //
        // Locate any further SKFrameworks and start them.
        //
        self.findSiblingFrameworks()
        
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
            "-- Application --" +
            "\n\nname: " + Bundle.main.appName() +
            "\nversion: " + Bundle.main.versionAndBuildNumber() +
            "\nbuild date: " + Bundle.main.buildDate() +
            "\norganization: " + Bundle.main.organization() +
            
            "\n\n-- Network --\n\n" + network.debugDescription +
            
            "\n\n\n-- Content --\n\n" + content.debugDescription
        
        return debugStatus
    }
    
    
    // MARK: -- Private --
    
    /**
     *
     */
    private static func findSiblingFrameworks()
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
                if class_conformsToProtocol(currentClass, SKFramework.self)
                {
                    //log.debug("found conforming class: \(currentClass)")
                    
                    //
                    // Start the framework
                    //
                    let framework: SKFramework.Type = currentClass as! SKFramework.Type
                    framework.start()
                }
            }
        }

        allClasses.deallocate(capacity: Int(expectedClassCount))
        
        //
        // Notify interested observers
        //
        //NotificationCenter.default.post(name: .ContentHoldersLoaded, object: nil)
    }
}


// MARK: -- Enumerations --

/**
 * SKFoundatiion general error types.
 */
public enum SKError: Error
{
    case apiCallFailed(title: String, detail: String)
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
        return Bundle(identifier: Bundle.main.prefix(append: named))
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
     * Retrieve the Root dictionary info from the main bundle plist.
     *
     * By default, if no "Root" entry is found it will return an empty dictionary.
     *
     * @returns [String, Any]
     */
    func rootInfo() -> [String : Any]
    {
        if let info = Bundle.main.object(forInfoDictionaryKey: "Root") as? [String : Any]
        {
            return info
        }
        
        return [String: Any]()
    }


    /**
     * Retrieve the app name.
     *
     * @returns String
     */
    func appName() -> String
    {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    }
    
    
    /**
     * Retrieve the build date.
     *
     * @returns String
     */
    func buildDate() -> String
    {
        if let value = self.rootInfo()["BuildDate"] as? String
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
    func buildNumber() -> String
    {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
    
    
    /**
     * Retrieve the organization's name.
     *
     * @returns String
     */
    func organization() -> String
    {
        if let value = self.rootInfo()["Organization"] as? String
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
    func prefix() -> String
    {
        if let value = self.rootInfo()["Prefix"] as? String
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
    func prefix(append fragment: String) -> String
    {
        return self.prefix() + "." + fragment
    }
    
    
    /**
     * Retrieve the version String.
     *
     * @returns String.
     */
    func version() -> String
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
    func versionAndBuildNumber() -> String
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
}
