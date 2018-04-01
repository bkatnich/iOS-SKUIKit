//
//  SKBackgroundView.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-03-11.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SandKattFoundation


/**
 *
 */
open class SKBackgroundView: UIView
{
    // MARK: Lifecycle
    
    override public init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = SKThemeManager.shared().viewBackgroundColor
    }
    
    
    public required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        self.backgroundColor = SKThemeManager.shared().viewBackgroundColor
    }
}
