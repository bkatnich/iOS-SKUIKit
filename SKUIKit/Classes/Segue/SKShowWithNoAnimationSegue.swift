//
//  SKShowWithNoAnimationSegue.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-04-08.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit


/**
 *
 */
@objc class SKShowWithNoAnimationSegue: UIStoryboardSegue
{
    /**
     *
     */
    public override func perform()
    {
        self.source.present(self.destination, animated: false, completion: nil)
    }
}
