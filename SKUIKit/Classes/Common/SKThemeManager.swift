//
//  SKThemeManager.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-03-18.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SKFoundation


/**
 * SKThemeManager handles the themeing of all UI elements of the application.
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
                if let navigationBarInfo: Dictionary<String, Any> = globalInfo[SKComponent.navigationBar.rawValue] as? Dictionary<String, Any>
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
                if let toolBarInfo: Dictionary<String, Any> = globalInfo[SKComponent.toolBar.rawValue] as? Dictionary<String, Any>
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
                if let tabBarInfo: Dictionary<String, Any> = globalInfo[SKComponent.tabBar.rawValue] as? Dictionary<String, Any>
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
            if let navigationBarInfo: Dictionary<String, Any> = detailInfo[SKComponent.navigationBar.rawValue] as? Dictionary<String, Any>
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
            if let toolBarInfo: Dictionary<String, Any> = detailInfo[SKComponent.toolBar.rawValue] as? Dictionary<String, Any>
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
    
    
    // MARK: -- Component Themes --
    
    /**
     * Background view component theme.
     */
    private func theme(backgroundView info:Dictionary<String, Any>)
    {
        log.debug("called for background view")
        
        //
        // View-specific: if in an enclosing dictionary with 'View' element
        //
        if let subInfo: Dictionary<String, Any> = info["View"] as? Dictionary<String, Any>
        {
            if let backgroundColor: String = subInfo["backgroundColor"] as? String
            {
                log.debug("View backgroundColor: \(backgroundColor)")
                
                self.viewBackgroundColor = UIColor.darkGray//self.color(from: backgroundColor)
            }
        }
        
        //
        // Global: else if the top dictionary with 'backgroundColor' element
        //
        else if let backgroundColor: String = info["backgroundColor"] as? String
        {
            log.debug("Global backgroundColor: \(backgroundColor)")
            
            self.viewBackgroundColor = UIColor.darkGray//self.color(from: backgroundColor)
        }
    }
    
    
    /**
     * NavigationBar component theme.
     */
    private func theme(navBar info:Dictionary<String, Any>)
    {
        log.debug("called for navBar")
        
        //
        // Find a background color for this component
        //
        if let backgroundColor: String = self.findComponentBackgroundColor(
            info: info,
            component: SKComponent.navigationBar)
        {
            //
            // Clear color
            //
            if SKColor.isClear(colorName: backgroundColor)
            {
                UINavigationBar.clearTheme()
            }
            
            //
            // Any other color
            //
            else
            {
                UINavigationBar.appearance().barTintColor = UIColor.blue
                UINavigationBar.appearance().tintColor = UIColor.white
            }
        }
        
        //
        // None found
        //
        else
        {
            UINavigationBar.appearance().barTintColor = UIColor.red
            UINavigationBar.appearance().tintColor = UIColor.green
        }
    }
    
    
    /**
     * TabBar component theme.
     */
    private func theme(tabBar info:Dictionary<String, Any>)
    {
        log.debug("called for tabBar")
        
        //
        // Find a background color for this component
        //
        if let backgroundColor: String = self.findComponentBackgroundColor(
            info: info,
            component: SKComponent.tabBar)
        {
            log.debug("TabBar backgroundColor is: \(backgroundColor)")
            
            //
            // Clear color
            //
            if SKColor.isClear(colorName: backgroundColor)
            {
                UITabBar.clearTheme()
            }
            
            //
            // Any other color
            //
            else
            {
                UITabBar.appearance().barTintColor = UIColor.blue
                UITabBar.appearance().tintColor = UIColor.white
            }
        }
        
        //
        // None found
        //
        else
        {
            UITabBar.appearance().barTintColor = UIColor.red
            UITabBar.appearance().tintColor = UIColor.green
        }
    }
    
    
    /**
     * ToolBar component theme.
     */
    private func theme(toolBar info:Dictionary<String, Any>)
    {
        log.debug("called for toolbar")
        
        //
        // Find a background color for this component
        //
        if let backgroundColor: String = self.findComponentBackgroundColor(
            info: info,
            component: SKComponent.toolBar)
        {
            //
            // Clear color
            //
            if SKColor.isClear(colorName: backgroundColor)
            {
                UIToolbar.clearTheme()
            }
            
            //
            // Any other color
            //
            else
            {
                UIToolbar.appearance().barTintColor = UIColor.blue
                UIToolbar.appearance().tintColor = UIColor.white
            }
        }
        
        //
        // None found
        //
        else
        {
            UIToolbar.appearance().barTintColor = UIColor.red
            UIToolbar.appearance().tintColor = UIColor.green
        }
    }
    
    
    // MARK: -- Private --
    
    /**
     *
     */
    private func findComponentBackgroundColor(info:Dictionary<String, Any>, component: SKComponent) -> String?
    {
        let componentName = component.rawValue
        
        log.debug("called for \(componentName)")
        
        //
        // Component-specific: if in an enclosing dictionary with key matching 'componentName'
        //
        if let subInfo: Dictionary<String, Any> = info[componentName] as? Dictionary<String, Any>
        {
            log.debug("found subInfo for \(componentName)")
            
            //
            // Specific background color
            //
            if let backgroundColor: String = subInfo["backgroundColor"] as? String
            {
                log.debug("\(componentName) backgroundColor: \(backgroundColor)")
                
                return backgroundColor
            }
            
            //
            // Global: else if the top dictionary with 'backgroundColor' element
            //
            else if let backgroundColor: String = info["backgroundColor"] as? String
            {
                log.debug("Global backgroundColor: \(backgroundColor)")
        
                return backgroundColor
            }
        }
        
        //
        // Global: else if the top dictionary with 'backgroundColor' element
        //
        else if let backgroundColor: String = info["backgroundColor"] as? String
        {
            log.debug("Global backgroundColor: \(backgroundColor)")
            
            return backgroundColor
        }
        
        log.debug("No set background Color")
        
        return nil
    }
    
    
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
        return self.themeInfo[SKComponent.global.rawValue] as? Dictionary<String, Any>
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
        if let globalInfo: Dictionary<String, Any> = self.themeInfo[SKComponent.global.rawValue] as? Dictionary<String, Any>
        {
            // Main view
            self.theme(backgroundView: globalInfo)
            
            // NavigationBar
            self.theme(navBar: globalInfo)
            
            // TabBar
            self.theme(tabBar: globalInfo)
        
            // ToolBar
            self.theme(toolBar: globalInfo)
        }
    }
    
    
    /**
     * Retrieve a UIColor based on the 'colorName' parameter.
     *
     * @param colorName String.
     * @returns UIColor if valid text, nil if not.
     */
    private func color(colorName: String) -> UIColor?
    {
        //
        // If valid colorValue found
        //
        if let colorValue: SKColor = SKColor(rawValue: colorName)
        {
            switch colorValue
            {
                case SKColor.Clear: return UIColor.clear
            }
        }
        
        //
        // Else no valid color value found
        //
        else { return nil }
    }
}


extension UINavigationBar
{
    /**
     * The clear theme for a UINavigationBar.
     */
    public static func clearTheme()
    {
        log.debug("NavigationBar called")
        
        UINavigationBar.appearance().backgroundColor = UIColor.clear
        UINavigationBar.appearance().setBackgroundImage(
            UIImage(),
            for: .default)
        UINavigationBar.appearance().barTintColor = UIColor.clear
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
 
        UINavigationBar.appearance().titleTextAttributes =
        [
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
    }
}


extension UITabBar
{
    /**
     * The clear theme for a UITabBar.
     */
    public static func clearTheme()
    {
        log.debug("TabBar called")
        
        UITabBar.appearance().backgroundColor = UIColor.clear
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().barTintColor = UIColor.clear
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().isTranslucent = true
        
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedStringKey.foregroundColor:UIColor.white],
            for: UIControlState.normal)
    }
}


extension UIToolbar
{
    /**
     * The clear theme for a UIToolbar.
     */
    public static func clearTheme()
    {
        log.debug("Toolbar called")
        
        UIToolbar.appearance().backgroundColor = UIColor.clear
        UIToolbar.appearance().barTintColor = UIColor.clear
        UIToolbar.appearance().tintColor = UIColor.white
        UIToolbar.appearance().isTranslucent = true
        UIToolbar.appearance().clipsToBounds = true
        UIToolbar.appearance().setBackgroundImage(
            UIImage(),
            forToolbarPosition: UIBarPosition.any,
            barMetrics:  UIBarMetrics.default)
        UIToolbar.appearance().setShadowImage(
            UIImage(),
            forToolbarPosition: UIBarPosition.any)
    }
}


/**
 * SKUIKit component enumeration.
 */
public enum SKComponent: String
{
    case backgroundView = "BackgroundView"
    case global = "Global"
    case navigationBar = "NavigationBar"
    case tabBar = "TabBar"
    case toolBar = "ToolBar"
}


/**
 * SKUIKit color enumeration.
 */
public enum SKColor: String
{
    case Clear = "Clear"
    
    /**
     * Determine if parameter 'colorName' indicates clear color.
     *
     * @param colorName String.
     * @returns True if clear, false if not.
     */
    public static func isClear(colorName: String) -> Bool
    {
        return colorName == SKColor.Clear.rawValue
    }
}
