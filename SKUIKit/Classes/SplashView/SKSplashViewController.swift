//
//  SKSplashViewController.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-02-05.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SKFoundation


/**
 * The SandKatt base version of a custom ViewController for initial splash screens.
 */
@IBDesignable
@objc open class SKSplashViewController: UIViewController
{
    // MARK: -- Properties --
    
    @IBInspectable public var segueName: String = "SplashSegue"
    @IBInspectable public var timeoutDelay: Int = 0

    
    // MARK: -- IBOutlets --
    
    @IBOutlet open weak var imageView: UIImageView?
    @IBOutlet open var loadAction: SKAction?
    

    // MARK: -- Lifecycle --

    open override func viewDidLoad()
    {
        super.viewDidLoad()
        log.debug("called and segueName: \(segueName), timeoutDelay: \(timeoutDelay) and has loadAction: \(String(describing: loadAction))")
    }


    open override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        //
        // If there is a loading action execute that before segue
        //
        if let action = self.loadAction
        {
            action.execute(completion: {(completed, error) in
            
                if error != nil
                {
                    log.error(error as Any)
                    return
                }
                
                self.executeSegue()
            })
        }
        
        //
        // Else just execute the segue
        //
        else
        {
            self.executeSegue()
        }
    }


    open override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
        log.warning("called")
    }
    
    
    // MARK -- Private --
    
    private func executeSegue()
    {
        //
        // Trigger the segue at the appropriate time delay
        //
        DispatchQueue.main.asyncAfter(deadline: timeoutDelay.seconds.fromNow)
        {
            self.performSegue(withIdentifier: self.segueName, sender: self)
        }
    }
}

