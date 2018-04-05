//
//  SKThemeManager.swift
//  SKUIKit
//
//  Created by Britton Katnich on 2018-03-18.
//  Copyright © 2018 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import SandKattFoundation
import Hue


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
        //
        // View-specific: if in an enclosing dictionary with 'View' element
        //
        if let subInfo: Dictionary<String, Any> = info["View"] as? Dictionary<String, Any>
        {
            if let colorHex: String = subInfo["backgroundColor"] as? String
            {
                //
                // Clear color
                //
                if SKThemeManager.isClear(colorName: colorHex)
                {
                    self.viewBackgroundColor = UIColor.clear
                }
            
                //
                // Else any other color
                //
                else
                {
                    //
                    // Convert from hex to UIColor
                    //
                    let backgroundColor = UIColor(hex: colorHex)
                    self.viewBackgroundColor = backgroundColor
                }
            }
        }
        
        //
        // Global: else if the top dictionary with 'backgroundColor' element
        //
        else if let colorHex: String = info["backgroundColor"] as? String
        {
            //
            // Clear color
            //
            if SKThemeManager.isClear(colorName: colorHex)
            {
                self.viewBackgroundColor = UIColor.clear
            }
        
            //
            // Else any other color
            //
            else
            {
                //
                // Convert from hex to UIColor
                //
                let backgroundColor = UIColor(hex: colorHex)
                self.viewBackgroundColor = backgroundColor
            }
        }
        
        //
        // Else none found
        //
        else { log.warning("No color value found, using storyboard defaults") }
    }
    
    
    /**
     * BarButtonItem component theme.
     */
    private func theme(barButtonItem info:Dictionary<String, Any>)
    {
        //
        // Find font for this component
        //
        if let font: UIFont = self.findComponentFont(
            info: info,
            component: SKComponent.barButtonItem)
        {
            //
            // Add font to attributes
            //
            var attributes: Dictionary<NSAttributedStringKey, Any> =
            [
                NSAttributedStringKey.font : font
            ]
            
            //
            // Add optional foreground color
            //
            if let foregroundColor = info["foregroundColor"] as? String
            {
                attributes[NSAttributedStringKey.foregroundColor] = foregroundColor
            }
            
            //
            // Set appearance
            //
            UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        }
    }
    
    
    /**
     * NavigationBar component theme.
     */
    private func theme(navBar info:Dictionary<String, Any>)
    {
        //
        // Find a background color for this component
        //
        if let colorHex: String = self.findComponentBackgroundColor(
            info: info,
            component: SKComponent.navigationBar)
        {
            //
            // Clear color
            //
            if SKThemeManager.isClear(colorName: colorHex)
            {
                UINavigationBar.clearTheme()
            }
            
            //
            // Any other color
            //
            else
            {
                //
                // Convert from hex to UIColor
                //
                let backgroundColor = UIColor(hex: colorHex)
                
                UINavigationBar.appearance().barTintColor = backgroundColor
                UINavigationBar.appearance().tintColor = backgroundColor.isDark ?
                    UIColor.white : UIColor.black
            }
        }
        
        //
        // None found
        //
        else { log.warning("No color value found, using storyboard defaults") }
        
        //
        // Find font for this component
        //
        if let font: UIFont = self.findComponentFont(
            info: info,
            component: SKComponent.navigationBar)
        {
            UINavigationBar.appearance().titleTextAttributes =
            [
                NSAttributedStringKey.font : font,
                NSAttributedStringKey.foregroundColor : UIColor.white
            ]
        }
    }
    
    
    /**
     * TabBar component theme.
     */
    private func theme(tabBar info:Dictionary<String, Any>)
    {
        //
        // Find a background color for this component
        //
        if let colorHex: String = self.findComponentBackgroundColor(
            info: info,
            component: SKComponent.tabBar)
        {
            //
            // Clear color
            //
            if SKThemeManager.isClear(colorName: colorHex)
            {
                UITabBar.clearTheme()
            }
            
            //
            // Any other color
            //
            else
            {
                //
                // Convert from hex to UIColor
                //
                let backgroundColor = UIColor(hex: colorHex)
                
                UITabBar.appearance().barTintColor = backgroundColor
                UITabBar.appearance().tintColor = backgroundColor.isDark ?
                    UIColor.white : UIColor.black
            }
        }
        
        //
        // None found
        //
        else { log.warning("No color value found, using storyboard defaults") }
        
        
        //
        // Find font for this component
        //
        if let font: UIFont = self.findComponentFont(
            info: info,
            component: SKComponent.tabBar)
        {
            UITabBarItem.appearance().setTitleTextAttributes(
                [
                    NSAttributedStringKey.font : font
                ],
                for: UIControlState.normal)
        }
    }
    
    
    /**
     * ToolBar component theme.
     */
    private func theme(toolBar info:Dictionary<String, Any>)
    {
        //
        // Find a background color for this component
        //
        if let colorHex: String = self.findComponentBackgroundColor(
            info: info,
            component: SKComponent.toolBar)
        {
            //
            // Clear color
            //
            if SKThemeManager.isClear(colorName: colorHex)
            {
                UIToolbar.clearTheme()
            }
            
            //
            // Any other color
            //
            else
            {
                //
                // Convert from hex to UIColor
                //
                let backgroundColor = UIColor(hex: colorHex)
                
                UIToolbar.appearance().barTintColor = backgroundColor
                UIToolbar.appearance().tintColor = backgroundColor.isDark ?
                    UIColor.white : UIColor.black
            }
        }
        
        //
        // None found
        //
        else { log.warning("No color value found, using storyboard defaults") }
        
        //
        // Find font for this component
        //
        if let font: UIFont = self.findComponentFont(
            info: info,
            component: SKComponent.toolBar)
        {
            UIBarButtonItem.appearance().setTitleTextAttributes(
                [
                    NSAttributedStringKey.font : font
                ],
                for: UIControlState.normal)
        }
    }
    
    
    // MARK: -- Private --
    
    /**
     * Determine if parameter 'colorName' indicates clear color.
     *
     * @param colorName String.
     * @returns True if clear, false if not.
     */
    public static func isClear(colorName: String?) -> Bool
    {
        return (colorName?.isEmpty)! || colorName == "clear"
    }
    
    
    /**
     * Retrieves the background color for a given SKComponent type defined in the system.
     *
     * @param info Dictionary<String, Any> containing the background color hex value, if any.
     * @param component SKComponent used to identify the key value in the info dictionary.
     * @returns String hex code for the background color, if any found.  Nil is returned, if not found.
     */
    private func findComponentBackgroundColor(info:Dictionary<String, Any>, component: SKComponent) -> String?
    {
        log.debug("called for component: \(component)")
        
        let componentName = component.rawValue

        //
        // Component-specific: if in an enclosing dictionary with key matching 'componentName'
        //
        if let subInfo: Dictionary<String, Any> = info[componentName] as? Dictionary<String, Any>
        {
            //
            // Specific background color
            //
            if let backgroundColor: String = subInfo["backgroundColor"] as? String
            {
                log.debug("found subInfo color: \(backgroundColor)")
                
                return backgroundColor
            }
            
            //
            // Global: else if the top dictionary with 'backgroundColor' element
            //
            else if let backgroundColor: String = info["backgroundColor"] as? String
            {
                log.debug("found info1 color: \(backgroundColor)")
                
                return backgroundColor
            }
        }
        
        //
        // Global: else if the top dictionary with 'backgroundColor' element
        //
        else if let backgroundColor: String = info["backgroundColor"] as? String
        {
            log.debug("found info2 color: \(backgroundColor)")
            return backgroundColor
        }
        
        log.debug("No set background Color")
        
        return nil
    }
    
    
    /**
     * Retrieves the Font for a given SKComponent type defined in the system.
     *
     * @param info Dictionary<String, Any> containing the font values, if any.
     * @param component SKComponent used to identify the key value in the info dictionary.
     * @returns UIFont, if any values found.  Nil is returned, if not found.
     */
    private func findComponentFont(info:Dictionary<String, Any>, component: SKComponent) -> UIFont?
    {
        log.debug("called for component: \(component)")
        
        let componentName = component.rawValue

        //
        // Component-specific: if in an enclosing dictionary with key matching 'componentName'
        //
        if let subInfo: Dictionary<String, Any> = info[componentName] as? Dictionary<String, Any>
        {
            //
            // Specific font
            //
            if let fontInfo: Dictionary<String, Any> = subInfo["font"] as? Dictionary<String, Any>
            {
                log.debug("found subInfo font: \(fontInfo)")
                
                if let fontName = fontInfo["name"] as! String?
                {
                    if let fontSize = fontInfo["size"] as! CGFloat?
                    {
                        return UIFont(name: fontName, size: fontSize)
                    }
                }
            }
            
            //
            // Global: else if the top dictionary with 'backgroundColor' element
            //
            else if let fontInfo: Dictionary<String, Any> = info["font"] as? Dictionary<String, Any>
            {
                log.debug("found info1 font: \(fontInfo)")
                
                if let fontName = fontInfo["name"] as! String?
                {
                    if let fontSize = fontInfo["size"] as! CGFloat?
                    {
                        return UIFont(name: fontName, size: fontSize)
                    }
                }
            }
        }
        
        //
        // Global: else if the top dictionary with 'backgroundColor' element
        //
        else if let fontInfo: Dictionary<String, Any> = info["font"] as? Dictionary<String, Any>
        {
            log.debug("found info1 font: \(fontInfo)")
            
                if let fontName = fontInfo["name"] as! String?
                {
                    if let fontSize = fontInfo["size"] as! CGFloat?
                    {
                        return UIFont(name: fontName, size: fontSize)
                    }
                }
        }
        
        log.debug("No set font values found")
        
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
}


extension UINavigationBar
{
    /**
     * The clear theme for a UINavigationBar.
     */
    public static func clearTheme()
    {
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
    case barButtonItem = "BarButtonItem"
    case global = "Global"
    case navigationBar = "NavigationBar"
    case tabBar = "TabBar"
    case toolBar = "ToolBar"
}
