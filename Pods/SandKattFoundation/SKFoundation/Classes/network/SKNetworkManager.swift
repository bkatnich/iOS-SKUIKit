//
//  SKNetworkManager.swift
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
public class SKNetworkManager : CustomDebugStringConvertible
{
    // MARK: -- Properties

    /**
     *
     */
    static let shared =  SKNetworkManager()
    
    /**
     *
     */
    private var networkManager: NetworkReachabilityManager?
    
    /**
     * Retrieve if the network connection to the baseURL is reachable, or not.
     *
     * @return True if so, false if not.
     */
    public var isReachable: Bool
    {
        get
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
    
    /**
     * Retrieve the base url with the contained URL components in the format: <scheme>://<host>:<port>.
     *
     * @returns URL
     */
    public var baseUrl: URL?
    {
        get
        {
            if self.host.isEmpty || self.port.isEmpty
            {
                return nil
            }
        
            let path = String(self.host + ":" + self.port)
            let url = URL(string: path)
        
            return url
        }
    }
    
    /**
     *
     */
    public var host: String
    {
        get
        {
            if let networkInfo = SKFoundation.configurationInfo["Network"] as? Dictionary<String, Any>
            {
                if let value = networkInfo["host"] as? String
                {
                    return value
                }
            }
            
            return ""
        }
    }
    
    /**
     *
     */
    public var port: String
    {
        get
        {
            if let networkInfo = SKFoundation.configurationInfo["Network"] as? Dictionary<String, Any>
            {
                if let value = networkInfo["port"] as? String
                {
                    return value
                }
            }
            
            return ""
        }
    }
    
    /**
     *
     */
    public var timeoutIntervalForRequest: Double
    {
        get
        {
            if let networkInfo = SKFoundation.configurationInfo["Network"] as? Dictionary<String, Any>
            {
                if let value = networkInfo["timeoutIntervalForRequest"] as? Double
                {
                    return value
                }
            }
            
            return 10
        }
    }
    
    /**
     *
     */
    public var timeoutIntervalForResource: Double
    {
        get
        {
            if let networkInfo = SKFoundation.configurationInfo["Network"] as? Dictionary<String, Any>
            {
                if let value = networkInfo["timeoutIntervalForResource"] as? Double
                {
                    return value
                }
            }
            
            return 10
        }
    }
    
    /**
     * The debug string.
     */
    public var debugDescription : String
    {
        let desc: String = "host: \(host)\n" +
            "port: \(port)\n" +
            "timeoutIntervalForRequest: \(timeoutIntervalForRequest)\n" +
            "timeoutIntervalForResource: \(timeoutIntervalForResource)"
        
        return desc
    }
    
    
    // MARK: -- Lifecycle --
    
    /**
     * Private initializer to enforce singleton behaviour.
     */
    private init()
    {
       log.debug("called")
    }


    // MARK: -- Public
    
    /**
     *
     */
    public func startListening()
    {
        log.debug("called")
        
        guard let baseUrl = SKNetworkManager.shared.baseUrl?.absoluteString
        else
        {
            log.warning("no base URL found")
            
            return
        }
        
        log.debug("found base url: \(baseUrl)")
        
        self.networkManager = NetworkReachabilityManager(host: baseUrl)
        self.networkManager?.listener = { status in
        
            log.debug("Network: \(baseUrl) status change heard: \(status)")
            
            //
            // Notify interested observers
            //
            NotificationCenter.default.post(name: .NetworkStatusChanged, object: nil)
        }
        self.networkManager?.startListening()
    }
    
    /**
     *
     */
    public func stopListening()
    {
        self.networkManager?.stopListening()
        self.networkManager = nil
    }
    
 
    // MARK: HTTP Requests
    
    /**
     *  HTTP DELETE network calls.
     *
     *  @completion (Bool, ApiError?) -> Void closure.
     */
    public class func deleteFrom(url: String, completion: @escaping (Bool, SKError?) -> Void)
    {
        log.debug("called with url: \(url)")
        
        //
        // Execute DELETE request with default validation (HTTP Codes 200-299)
        //
        Alamofire.request(url, method: .delete).response { response in
    
            log.debug("response heard")
            
            //
            // Handle error
            //
            if(response.error != nil)
            {
                let error: SKError = SKError.apiCallFailed(
                    title: response.error!.localizedDescription,
                    detail: String(data: (response.data)!, encoding: .utf8)!)
                
                completion(false, error)
                return;
            }
            
            //
            // Success
            //
            completion(true, nil)
        }
    }


    /**
     *  Executes an HTTP GET call when expected response is an Array in JSON format.
     *
     *  @param url String.
     *  @param completion (Array<AnyObject>?, ApiError?) -> Void.
     */
    public class func getAsArray(url: String, completion: @escaping ArrayCompletionHandler)
    {
        log.debug("called with url: " + url)
        
        //
        // Execute GET request with default validation (HTTP Codes 200-299)
        //
        Alamofire.request(url).validate().responseJSON { response in

            //
            // Detect result code and respond accordingly
            //
            switch response.result
            {
                //
                // Success (200-299)
                //
                case .success:
                
                    if let array: Array<AnyObject> = response.result.value as? Array<AnyObject>
                    {
                        completion(array, nil)
                        return
                    }
                    
                    break
        
                //
                // Failure (everything else)
                //
                case .failure(let error):
                
                    let error: SKError = SKError.apiCallFailed(
                        title: error.localizedDescription,
                        detail: String(data: (response.data)!, encoding: .utf8)!)
                    
                    //
                    // Execute completion block
                    //
                    completion(nil, error)
                    
                    break
            }
        }
    }
    
    
    /**
     *  Executes an HTTP GET call when expected response is a Dictionary in JSON format.
     *
     *  @param url String.
     *  @param completion (Dictionary<String, AnyObject>?, ApiError?) -> Void.
     */
    public class func getAsDictionary(url: String, completion: @escaping DictionaryCompletionHandler)
    {
        //log.debug("called with url path: \(url) and base url is: \(String(describing: SKNetwork.shared().baseUrl))")
        
        //
        // Create full url
        //
        guard let baseUrl = SKNetworkManager.shared.baseUrl?.absoluteString
        else
        {
            let error: SKError = SKError.networkUrlNotConstructed(url)
         
            //
            // Execute completion block
            //
            completion(nil, error)
         
            return
        }
        
        let fullUrl = baseUrl + url
        
        //
        // Execute GET request with default validation (HTTP Codes 200-299)
        //
        Alamofire.request(fullUrl).validate().responseJSON { response in

            //
            // Detect result code and respond accordingly
            //
            switch response.result
            {
                //
                // Success (200-299)
                //
                case .success:
         
                    //log.debug("Success heard: " + String(describing:response.result))
         
                    //
                    // Dictionary case
                    //
                    if let info: Dictionary<String, AnyObject> = response.result.value as? Dictionary<String, AnyObject>
                    {
                        completion(info, nil)
                        return
                    }
         
                    break
        
                //
                // Failure (everything else)
                //
                case .failure(let error):
         
                    let error: SKError = SKError.apiCallFailed(
                        title: error.localizedDescription,
                        detail: String(data: (response.data)!, encoding: .utf8)!)
         
                    //
                    // Execute completion block
                    //
                    completion(nil, error)
         
                    break
            }
        }
    }
    
    
    /**
     *  HTTP POST network calls.
     *
     *  @completion (Dictionary<String, AnyObject>?, ApiError?) -> Void closure.
     */
    public class func postTo(url: String, parameters: Dictionary<String, Any>, completion: @escaping DictionaryCompletionHandler)
    {
        //
        // Execute POST request with default validation (HTTP Codes 200-299)
        //
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
    
            //
            // Detect result code and respond accordingly
            //
            switch response.result
            {
                //
                // Success (200-299)
                //
                case .success:
                
                    //
                    // Ensure
                    //
                    let json = response.result.value ?? "{}"
                    
                    //
                    // Execute completion block
                    //
                    completion(json as? Dictionary<String, AnyObject>, nil)
                    
                    break
        
                //
                // Failure (everything else)
                //
                case .failure(let error):
                    
                    let error: SKError = SKError.apiCallFailed(
                        title: error.localizedDescription,
                        detail: String(data: (response.data)!, encoding: .utf8)!)
                    
                    //
                    // Execute completion block
                    //
                    completion(Dictionary<String, AnyObject>(), error)
                    
                    break
            }
        }
    }
    
    
    /**
     *  HTTP PUT network calls.
     *
     *  @completion (Dictionary<String, AnyObject>?, ApiError?) -> Void closure.
     */
    public class func putAt(url: String, parameters: Dictionary<String, Any>, completion: @escaping DictionaryCompletionHandler)
    {
        log.debug("called with url: " + url)
        
        //
        // Execute POST request with default validation (HTTP Codes 200-299)
        //
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
    
            //
            // Detect result code and respond accordingly
            //
            switch response.result
            {
                //
                // Success (200-299)
                //
                case .success:
                
                    //
                    // Ensure
                    //
                    let json = response.result.value ?? "{}"
                    
                    //
                    // Execute completion block
                    //
                    completion(json as? Dictionary<String, AnyObject>, nil)
                    
                    break
        
                //
                // Failure (everything else)
                //
                case .failure(let error):
                
                    let error: SKError = SKError.apiCallFailed(
                        title: error.localizedDescription,
                        detail: String(data: (response.data)!, encoding: .utf8)!)
                    
                    //
                    // Execute completion block
                    //
                    completion(Dictionary<String, AnyObject>(), error)
                    
                    break
            }
        }
    }
    
    
    /**
     * HTTP GET network calls.
     *
     * @completion (Dictionary<String, AnyObject>, Error?) -> Void closure.
     */
    public class func requestGet(url: String, completion: @escaping DictionaryCompletionHandler)
    {
        log.debug("called with url: " + url)
        
        //
        // Execute GET request with default validation (HTTP Codes 200-299)
        //
        Alamofire.request(url).validate().responseJSON { response in
    
            //
            // Detect result code and respond accordingly
            //
            switch response.result
            {
                //
                // Success (200-299)
                //
                case .success:
                
                    //
                    // Ensure
                    //
                    let json = response.result.value ?? "{}"
                    
                    //
                    // Array case
                    //
                    if let array: Array<AnyObject> = json as? Array<AnyObject>
                    {
                        completion(["something": array[0]], nil)
                        return
                    }
                    
                    //
                    // Dictionary case
                    //
                    if let info: Dictionary<String, AnyObject> = json as? Dictionary<String, AnyObject>
                    {
                        completion(info, nil)
                        return
                    }
                    
                    log.warning("Detected unsupported result object type")
                    
                    break
        
                //
                // Failure (everything else)
                //
                case .failure(let error):
                
                    let error: SKError = SKError.apiCallFailed(
                        title: error.localizedDescription,
                        detail: String(data: (response.data)!, encoding: .utf8)!)
                    
                    //
                    // Execute completion block
                    //
                    completion(Dictionary(), error)
                    
                    break
            }
        }
    }
}

