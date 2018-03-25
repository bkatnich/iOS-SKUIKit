//
//  SKThemeManager.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-03-18.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SKFoundation
import ChameleonFramework


/**
 *
 */
public class SKThemeManager: CustomDebugStringConvertible
{
    // MARK: -- Properties --
    
    public var themeInfo:[String: AnyObject] = [String: AnyObject]()
    
    public var viewBackgroundColor = UIColor.white
    
    private var globalNavigationCtrller: SKGlobalNavigationViewController? = nil
    public var globalNavigationController: SKGlobalNavigationViewController?
    {
        get
        {
            return self.globalNavigationCtrller
        }
        
        
        set(newController)
        {
            self.globalNavigationCtrller = newController
            
            //
            // Global Theme
            //
            if let globalInfo: Dictionary<String, Any> = self.globalInfo()
            {
                //
                // UINavigationBar
                //
                if let navigationBarInfo: Dictionary<String, Any> = globalInfo["NavigationBar"] as? Dictionary<String, Any>
                {
                    //
                    // isHidden?
                    //
                    if let isHidden = navigationBarInfo["isHidden"] as? Bool
                    {
                        self.globalNavigationCtrller?.navigationBar.isHidden = isHidden
                    }
                }
                
                //
                // UIToolBar
                //
                if let toolBarInfo: Dictionary<String, Any> = globalInfo["ToolBar"] as? Dictionary<String, Any>
                {
                    //
                    // isHidden?
                    //
                    if let isHidden = toolBarInfo["isHidden"] as? Bool
                    {
                        self.globalNavigationCtrller?.isToolbarHidden = isHidden
                    }
                }
            }
        }
    }
    
    
    private var globalTabBarCtrller: SKGlobalTabBarController? = nil
    public var globalTabBarController: SKGlobalTabBarController?
    {
        get
        {
            return self.globalTabBarCtrller
        }
        
        
        set(newController)
        {
            self.globalTabBarCtrller = newController
            
            //
            // Global Theme
            //
            if let globalInfo: Dictionary<String, Any> = self.globalInfo()
            {
                //
                // UITabBar
                //
                if let tabBarInfo: Dictionary<String, Any> = globalInfo["TabBar"] as? Dictionary<String, Any>
                {
                    //
                    // isHidden?
                    //
                    if let isHidden = tabBarInfo["isHidden"] as? Bool
                    {
                        self.globalTabBarCtrller?.tabBar.isHidden = isHidden
                    }
                }
            }
        }
    }
    
    
    private var detailNavigationControllers: [SKDetailNavigationViewController] = [SKDetailNavigationViewController]()
    public func add(detailNavigationController: SKDetailNavigationViewController)
    {
        //
        // Detail Theme
        //
        if let detailInfo: Dictionary<String, Any> = self.detailInfo()
        {
            //
            // UINavigationBar
            //
            if let navigationBarInfo: Dictionary<String, Any> = detailInfo["NavigationBar"] as? Dictionary<String, Any>
            {
                //
                // isHidden?
                //
                if let isHidden = navigationBarInfo["isHidden"] as? Bool
                {
                    detailNavigationController.navigationBar.isHidden = isHidden
                }
            }
            
            //
            // UIToolBar
            //
            if let toolBarInfo: Dictionary<String, Any> = detailInfo["ToolBar"] as? Dictionary<String, Any>
            {
                //
                // isHidden?
                //
                if let isHidden = toolBarInfo["isHidden"] as? Bool
                {
                    detailNavigationController.isToolbarHidden = isHidden
                }
            }
        }
        
        //
        // Add to the list
        //
        self.detailNavigationControllers.append(detailNavigationController)
    }
    
    /**
     * The shared, singleton instance.
     */
    private static var sharedThemeManager: SKThemeManager =
    {
        let themeManager = SKThemeManager()

        return themeManager
    }()
    
    
    /**
     * CustomDebugStringConvertible
     */
    public var debugDescription : String
    {
        let desc: String = "\(self.themeInfo)"
        
        return desc
    }

    
    // MARK: -- Lifecycle --

    /**
     * Default initialzation which triggers finding any theme values.
     */
    private init()
    {
        //
        // Retrieve theme values
        //
        self.findTheme()
    }


    // MARK: -- Public --

    /**
     * Retrieves the shared, singleton instance of the SKThemeManager.
     *
     * @returns SKThemeManager
     */
    public class func shared() -> SKThemeManager
    {
        return sharedThemeManager
    }
    
    
    // MARK: -- Private --
    
    /**
     *
     */
    private func findTheme()
    {
        //
        // Find the Theme.plist if it exists
        //
        if let path = Bundle.main.path(forResource: "Theme", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject]
        {
            //
            // Set the information
            //
            self.themeInfo = dict
            
            //
            // Set global values
            //
            self.handleGlobal()
        }
        else
        {
            log.warning("no Theme.plist found")
        }
    }
    
    
    /**
     * Retrieve the global theme info, if any.
     */
    private func globalInfo() -> Dictionary<String, Any>?
    {
        //
        // Global Theme
        //
        return self.themeInfo["Global"] as? Dictionary<String, Any>
    }
    
    
    /**
     * Retrieve the global theme info, if any.
     */
    private func detailInfo() -> Dictionary<String, Any>?
    {
        //
        // Detail Theme
        //
        return self.themeInfo["Detail"] as? Dictionary<String, Any>
    }
    
    
    /**
     *
     */
    private func handleGlobal()
    {
        //
        // Global Theme
        //
        if let globalInfo: Dictionary<String, Any> = self.themeInfo["Global"] as? Dictionary<String, Any>
        {
            let globalColor: String = globalInfo["backgroundColor"] as! String
            let globalFont: String = globalInfo["font"] as! String
            
            //
            // Chameleon
            //
            Chameleon.setGlobalThemeUsingPrimaryColor(self.color(from: globalColor),
                withSecondaryColor: self.color(from: globalColor),
                usingFontName: globalFont,
                andContentStyle: UIContentStyle.contrast)

            //
            // UITabBar must be done separately
            //
            UITabBar.appearance().barTintColor = UINavigationBar.appearance().barTintColor
            UITabBarItem.appearance().setTitleTextAttributes(
                [NSAttributedStringKey.foregroundColor:UINavigationBar.appearance().tintColor],
                for: UIControlState.normal)
            
            //
            // Views
            //
            if let viewInfo: Dictionary<String, Any> = globalInfo["View"] as? Dictionary<String, Any>
            {
                if let viewBackgroundColor: String = viewInfo["backgroundColor"] as? String
                {
                    self.viewBackgroundColor = self.color(from: viewBackgroundColor)
                }
            }
        }
    }
    
    
    private func color(from: String) -> UIColor
    {
        let colorValue: SKColor = SKColor(rawValue: from)!
    
        switch colorValue
        {
            case SKColor.Clear: return UIColor.clear
            case SKColor.FlatBlack: return FlatBlack()
            case SKColor.FlatBlue: return FlatBlue()
            case SKColor.FlatBrown: return FlatBrown()
            case SKColor.FlatCoffee: return FlatCoffee()
            case SKColor.FlatForestGreen: return FlatForestGreen()
            case SKColor.FlatGray: return FlatGray()
            case SKColor.FlatGreen: return FlatGreen()
            case SKColor.FlatLime: return FlatLime()
            case SKColor.FlatMagenta: return FlatMagenta()
            case SKColor.FlatMaroon: return FlatMaroon()
            case SKColor.FlatMint: return FlatMint()
            case SKColor.FlatNavyBlue: return FlatNavyBlue()
            case SKColor.FlatOrange: return FlatOrange()
            case SKColor.FlatPink: return FlatPink()
            case SKColor.FlatPlum: return FlatPlum()
            case SKColor.FlatPowderBlue: return FlatPowderBlue()
            case SKColor.FlatPurple: return FlatPurple()
            case SKColor.FlatRed: return FlatRed()
            case SKColor.FlatSand: return FlatSand()
            case SKColor.FlatSkyBlue: return FlatSkyBlue()
            case SKColor.FlatTeal: return FlatTeal()
            case SKColor.FlatWatermelon: return FlatWatermelon()
            case SKColor.FlatWhite: return FlatWhite()
            case SKColor.FlatYellow: return FlatYellow()
        }
    }
}


/**
 * SKUIKit theme colors.
 */
public enum SKColor: String
{
    case Clear = "Clear"
    case FlatBlack = "FlatBlack"
    case FlatBlue = "FlatBlue"
    case FlatBrown = "FlatBrown"
    case FlatCoffee = "FlatCoffee"
    case FlatForestGreen = "FlatForestGreen"
    case FlatGray = "FlatGray"
    case FlatGreen = "FlatGreen"
    case FlatLime = "FlatLime"
    case FlatMagenta = "FlatMagenta"
    case FlatMaroon = "FlatMaroon"
    case FlatMint = "FlatMint"
    case FlatNavyBlue = "FlatNavyBlue"
    case FlatOrange = "FlatOrange"
    case FlatPink = "FlatPink"
    case FlatPlum = "FlatPlum"
    case FlatPowderBlue = "FlatPowderBlue"
    case FlatPurple = "FlatPurple"
    case FlatRed = "FlatRed"
    case FlatSand = "FlatSand"
    case FlatSkyBlue = "FlatSkyBlue"
    case FlatTeal = "FlatTeal"
    case FlatWatermelon = "FlatWatermelon"
    case FlatWhite = "FlatWhite"
    case FlatYellow = "FlatYellow"
}
