//
//  SKDetailNavigationViewController.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-03-21.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SandKattFoundation


/**
 *
 */
open class SKDetailNavigationViewController: UINavigationController
{
    // MARK: Lifecycle
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        
        //
        // Register with the ThemeManager
        //
        SKThemeManager.shared.add(detailNavigationController: self)
    }


    override open func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    
        log.warning("called")
    }
}
