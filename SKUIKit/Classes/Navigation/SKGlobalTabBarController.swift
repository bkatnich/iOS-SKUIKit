//
//  SKGlobalTabBarController.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-03-25.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SKFoundation


/**
 *
 */
open class SKGlobalTabBarController: UITabBarController
{
    // MARK: Lifecycle
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
    
        //
        // Register with the ThemeManager
        //
        SKThemeManager.shared().globalTabBarController = self
    }


    override open func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    
        log.warning("called")
    }
}
