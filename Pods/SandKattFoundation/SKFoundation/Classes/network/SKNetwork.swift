//
//  SKNetwork.swift
//  SKFoundation
//
//  Created by Britton Katnich on 2017-11-28.
//  Copyright © 2017 SandKatt Solutions Inc. All rights reserved.
//

import Foundation
import Alamofire


/**
 * SKNetwork contains necessary network related configuration values the
 * application needs to configure itself locally and make remote calls.
 *
 * The remote, base URL and it's components parts can be retrieved for example.
 */
public struct SKNetwork : Codable, CustomDebugStringConvertible
{
    private enum CodingKeys: String, CodingKey
    {
        case debug
        case network
        case paths
    }
    
    // MARK: -- Properties --
    
    public var debug: SKDebugConfiguration?
    public var network: SKNetworkConfiguration?
    public var paths: [String : String] = [String : String]()
    
    private var networkManager: NetworkReachabilityManager?
    
    
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
    
    
    /**
     * Retrieve if the network connection to the baseURL is reachable, or not.
     *
     * @return True if so, false if not.
     */
    public func isReachable() -> Bool
    {
        //
        // If a manager based on the base url was established
        //
        if let manager = self.networkManager
        {
            //
            // Ask the manager for the current network state
            //
            return manager.isReachable
        
        //
        // Else no valid manager was instantiated
        //
        } else { return false }
    }
}

public extension SKNetwork
{
    /**
     * Decodable
     */
    init(from decoder: Decoder) throws
    {
        // Get our container for this subclass' coding keys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.debug = (try? container.decode(SKDebugConfiguration.self, forKey: .debug)) ?? SKDebugConfiguration()
        self.network = (try? container.decode(SKNetworkConfiguration.self, forKey: .network)) ?? SKNetworkConfiguration()
        self.paths = (try? container.decode(Dictionary<String, String>.self, forKey: .debug)) ?? Dictionary<String, String>()
    
        //
        // Setup the network reachability
        //
        if let url = self.baseUrl()?.description
        {
            self.networkManager = NetworkReachabilityManager(host: url)
            self.networkManager?.listener = { status in
        
                //log.debug("Network: \(url) status change heard: \(status)")
                
                //
                // Notify interested observers
                //
                NotificationCenter.default.post(name: .NetworkStatusChanged, object: nil)
            }
            self.networkManager?.startListening()
        
        } else { log.warning("network base url not found!!") }
    }
    
    
    /**
     * Encodable
     */
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
       
        try container.encode(self.debug, forKey: .debug)
        try container.encode(self.network, forKey: .network)
        try container.encode(self.paths, forKey: .paths)
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
