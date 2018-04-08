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
    // MARK: -- Properties

    /**
     * Singleton SKThemeManager instance.
     */
    static let shared = SKThemeManager()
    
    
    /**
     * The background color of the various types of bar components:
     *
     *    UINavigationBar
     *    UITabBar
     *    UIToolbar
     *
     * @returns UIColor, or nil if none set in the configuration.
     */
    public var barColor: UIColor?
    {
        get
        {
            if let themeInfo = SKFoundation.configurationInfo[SKThemeKey.theme.rawValue] as? Dictionary<String, Any>
            {
                if let value = themeInfo[SKThemeKey.barColor.rawValue] as? String
                {
                    if value == SKThemeKey.clear.rawValue
                    {
                        return UIColor.clear
                    }
                    
                    return UIColor(hex: value)
                }
            }
            
            return nil
        }
    }
    
    
    /**
     * The color of the text or system icons in the button items of the various bar components:
     *
     *    UINavigationBar (UIBarButtonItem)
     *    UITabBar (UITabBarButtonItem)
     *    UIToolbar (UIBarButtonItem)
     *
     * @returns UIColor, or nil if none set in the configuration.
     */
    public var barTintColor: UIColor?
    {
        get
        {
            if let themeInfo = SKFoundation.configurationInfo[SKThemeKey.theme.rawValue] as? Dictionary<String, Any>
            {
                if let value = themeInfo[SKThemeKey.barTintColor.rawValue] as? String
                {
                    if value == SKThemeKey.clear.rawValue
                    {
                        return UIColor.clear
                    }
                    
                    return UIColor(hex: value)
                }
            }
            
            return nil
        }
    }
    
    
    /**
     * The background color of SKBackgroundViews. This could be used to auto-implement the same
     * background colors of multiple screens across an application.
     *
     * @returns UIColor, or nil if none set in the configuration.
     */
    public var viewColor: UIColor?
    {
        get
        {
            if let themeInfo = SKFoundation.configurationInfo[SKThemeKey.theme.rawValue] as? Dictionary<String, Any>
            {
                if let value = themeInfo[SKThemeKey.viewColor.rawValue] as? String
                {
                    if value == SKThemeKey.clear.rawValue
                    {
                        return UIColor.clear
                    }
                    
                    return UIColor(hex: value)
                }
            }
            
            return nil
        }
    }
    
    
    /**
     * The main UINavigationController that can traverse across all screen of an application.
     */
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
        }
    }
    
    
    /**
     * The main UITabBarController that can traverse across all screen of an application.
     */
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
        }
    }


    /**
     * List of secondary, per-screen UINavigationControllers.
     */
    private var detailNavigationControllers: [SKDetailNavigationViewController] = [SKDetailNavigationViewController]()
    public func add(detailNavigationController: SKDetailNavigationViewController)
    {
        //
        // Add to the list
        //
        self.detailNavigationControllers.append(detailNavigationController)
    }
    
    
    /**
     * CustomDebugStringConvertible
     */
    public var debugDescription : String
    {
        let desc: String =
            "barColor: \(String(describing: self.barColor?.hex()))" +
            "barTintColor: \(String(describing: self.barTintColor?.hex()))" +
            "viewColor: \(String(describing: self.viewColor?.hex()))"
        
        return desc
    }

    
    // MARK: -- Lifecycle --
    
    /**
     * Private initializer to enforce singleton behaviour.
     */
    private init()
    {
        log.debug("called")
       
        // NavigationBar
        self.themeNavBar()
        
        // TabBar
        self.themeTabBar()
        
        // ToolBar
        self.themeToolBar()
    }
    
    
    // MARK: Component Theme
    
    /**
     * NavigationBar component theme.
     */
    private func themeNavBar()
    {
        //
        // Bar color
        //
        if let color = self.barColor
        {
            //
            // Clear color
            //
            if color == UIColor.clear
            {
                UINavigationBar.clearTheme()
            }
            
            //
            // Any other color
            //
            else
            {
                UINavigationBar.appearance().barTintColor = color
                UINavigationBar.appearance().tintColor = color.isDark ?
                    UIColor.white : UIColor.black
            }
            
            //
            // Title Text Attributes
            //
            UINavigationBar.appearance().titleTextAttributes =
            [
                NSAttributedStringKey.foregroundColor : color.isDark ?
                    UIColor.white : UIColor.black
            ]
            
        } else { log.warning("No bar color theming found") }
    }
    
    
    /**
     * TabBar component theme.
     */
    private func themeTabBar()
    {
        if let color = self.barColor
        {
            //
            // Clear color
            //
            if color == UIColor.clear
            {
                UITabBar.clearTheme()
            }
            
            //
            // Any other color
            //
            else
            {
                UITabBar.appearance().barTintColor = color
                UITabBar.appearance().tintColor = color.isDark ?
                    UIColor.white : UIColor.black
            }
            
        } else { log.warning("No bar color theming found") }
    }


    /**
     * ToolBar component theme.
     */
    private func themeToolBar()
    {
        if let color = self.barColor
        {
            //
            // Clear color
            //
            if color == UIColor.clear
            {
                UIToolbar.clearTheme()
            }
            
            //
            // Any other color
            //
            else
            {
                UIToolbar.appearance().barTintColor = color
                UIToolbar.appearance().tintColor = color.isDark ?
                    UIColor.white : UIColor.black
            }
            
        } else { log.warning("No bar color theming found") }
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
 * SKUIKit theme key enumeration.
 */
public enum SKThemeKey: String
{
    case theme = "Theme"
    case barColor = "barColor"
    case barTintColor = "barTintColor"
    case viewColor = "viewColor"
    case clear = "clear"
}
