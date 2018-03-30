//
//  SKNetwork.swift
//  SKFoundation
//
//  Created by Britton Katnich on 2017-11-28.
//  Copyright © 2017 SandKatt Solutions Inc. All rights reserved.
//

import Foundation


/**
 * SKNetwork contains necessary network related configuration values the
 * application needs to configure itself locally and make remote calls.
 *
 * The remote, base URL and it's components parts can be retrieved for example.
 */
public struct SKNetwork : Codable, CustomDebugStringConvertible
{
    // MARK: -- Properties --
    
    public var debug: SKDebugConfiguration?
    public var network: SKNetworkConfiguration?
    public var paths: [String : String] = [String : String]()
    
    /**
     * CustomDebugStringConvertible
     */
    public var debugDescription : String
    {
        var desc: String = network.debugDescription
            + "\n" + debug.debugDescription
            + "\n\n*** Url Paths ***\n\n"
        
        if self.paths.isEmpty
        {
            desc.append("<none>")
        }
        
        else
        {
            for path in self.paths
            {
                desc.append(String(describing: path) + "\n\n")
            }
        }
        
        return desc
    }
    
    
    // MARK: -- Lifecycle --
 
    /**
     * SKNetwork shared static initializer that retrieves the data from file, if present.
     *
     * If the file is not present, or is not json formatted, error will be thrown which will be
     * logged.  The returned Configuration will also be in a default state with no dummy values.
     *
     * @returns SKNetwork
     */
    private static var sharedNetwork: SKNetwork =
    {
        do
        {
            //
            // Use the correct bundle.  If the configurable root content bundle is not present,
            // use the default main bundle
            //
            let bundle = Bundle.main
            
            //
            // Retrieve the file path of the Theme.json file.  There is a chance there is a
            // root content bundle, but no Theme in it.  In that case, default to the 'should
            // always be there' default Theme.json resident in the main bundle
            //
            if let filePath = bundle.url(forResource: "Network", withExtension: "json") ??
                Bundle.main.url(forResource: "Network", withExtension: "json")
            {
                //
                // Read the data
                //
                let data = try Data(contentsOf: filePath)
            
                //
                // Decode to model
                //
                let jsonDecoder = JSONDecoder()
                let network = try jsonDecoder.decode(SKNetwork.self, from: data)

                return network
            }
        }
        catch(let error)
        {
            log.error("Network configuration file not found: " + String(describing:error))
        }
        
        return SKNetwork()
    }()

    
    /**
     * Default initializer which should never be used.  It will be called only in the case
     * of failure to file and decode the appropriate.
     */
    private init()
    {
        self.debug = SKDebugConfiguration()
        self.network = SKNetworkConfiguration()
    }


    // MARK: -- Public

    /**
     * Retrieve the shared instance.
     *
     * @returns SKNetwork.
     */
    public static func shared() -> SKNetwork
    {
        return sharedNetwork
    }
    
    
    /**
     * Retrieve the base url with the contained URL components in the format: <scheme>://<host>:<port>.
     *
     * @returns URL
     */
    public func baseUrl() -> URL?
    {
        //
        // Create initial path with scheme, host and port.  Note that scheme and port are option in the configuration file
        // and internally default to 'https' and '443' respectively if not set
        //
        let path = String(self.network!.scheme + "://" + self.network!.host + ":" + self.network!.port)
        let url = URL(string: path)
        
        return url
    }
}


/**
 * Debug configuration settings.
 */
public struct SKDebugConfiguration : Codable, CustomDebugStringConvertible
{
    // MARK: -- Properties

    public var offlineMode: Bool = false
    
    /**
     * CustomDebugStringConvertible
     */
    public var debugDescription : String
    {
        let desc: String = "debug in offlineMode: \(offlineMode)"
        
        return desc
    }
    
    
    // MARK: -- Lifecycle --
    
    init(offlineMode: Bool? = true)
    {
        self.offlineMode = offlineMode!
    }
}


/**
 * Network configuration settings.
 */
public struct SKNetworkConfiguration : Codable, CustomDebugStringConvertible
{
    // MARK: -- Properties

    public var host: String
    public var port: String
    public var scheme: String
    public var timeoutIntervalForRequest: Double
    public var timeoutIntervalForResource: Double
    
    
    /**
     * CustomDebugStringConvertible
     */
    public var debugDescription : String
    {
        let desc: String = "host: \(host)\n" +
            "port: \(port)\n" +
            "scheme: \(scheme)\n" +
            "timeoutIntervalForRequest: \(timeoutIntervalForRequest)\n" +
            "timeoutIntervalForResource: \(timeoutIntervalForResource)"
        
        return desc
    }
    
    
    // MARK: -- Lifecycle --
    
    init(host: String? = "www.SKFoundation.com",
        port: String? = "443",
        scheme: String? = "https",
        timeoutIntervalForRequest: Double? = 10.0,
        timeoutIntervalForResource: Double? = 10.0)
    {
        self.host = host!
        self.port = port!
        self.scheme = scheme!
        self.timeoutIntervalForRequest = timeoutIntervalForRequest!
        self.timeoutIntervalForResource = timeoutIntervalForResource!
    }
}
