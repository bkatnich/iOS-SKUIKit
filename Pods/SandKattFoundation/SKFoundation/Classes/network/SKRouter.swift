//
//  SKRouter.swift
//  SKFoundation
//
//  Created by Britton Katnich on 2017-04-19.
//  Copyright © 2017 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import Alamofire


/**
 * The HTTP router engine wraper that manages all external network calls.
 */
public class SKRouter: NSObject
{
    // MARK: Lifecycle
    
    /**
     * Private init method to enforce inability to instantiate.
     */
    private override init()
    {
        // do nothing
    }
    
 
    // MARK: Public
    
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
        log.debug("called with url path: \(url) and base url is: \(String(describing: SKNetwork.shared().baseUrl()))")
        
        //
        // Create full url
        //
        guard let baseUrl = SKNetwork.shared().baseUrl()?.absoluteString
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
        log.debug("full url: \(fullUrl)")
        
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
