//
//  SKContentHolder.swift
//  SKFoundation
//
//  Created by Britton Katnich on 2017-12-28.
//  Copyright © 2017 SandKatt Solutions Inc. All rights reserved.
//

import UIKit
import FontAwesome_swift


/**
 * A content holder is an instance of all information that is within a given
 * holders application json file, which is located by it's SKContentDataSource.
 */
public protocol SKContentHolder: CustomDebugStringConvertible
{
    // MARK: -- Properties --
    
    var bundleName: String { get }
    var storyboardName: String { get }
    var identifier: String { get }
    
    var title: String { get }
    var icon: String { get }
    var iconType: IconType { get }
    var isInternal: Bool { get }
    var priority: Int { get }
    var subHolders: [SKContentDataHolder] { get }
    
    static func holder(from: SKContentDataSource) -> SKContentHolder
    func iconImage() -> UIImage?
}


/**
 * A concrete instance of the SKContentHolder protocol.
 */
public struct SKContentDataHolder: SKContentHolder, Codable
{
    // MARK: -- Properties --
    
    private var dataSource: SKContentDataSource? = nil
    private enum CodingKeys: String, CodingKey
    {
        case bundleName
        case storyboardName
        case identifier
        case title
        case icon
        case iconType
        case isInternal
        case priority
        case subHolders
    }
    
    public var bundleName: String
    public var storyboardName: String
    public var identifier: String
    public var title: String
    public var icon: String
    public var iconType: IconType
    public var isInternal: Bool
    public var priority: Int
    public var subHolders: [SKContentDataHolder]
    
    /**
     * CustomDebugStringConvertible
     */
    public var debugDescription : String
    {
        var desc: String = "title: \(title)" +
            "\nbundleName: \(bundleName)" +
            "\nstoryboardName: \(storyboardName)" +
            "\nidentifier: \(identifier)" +
            "\nicon: \(icon)" +
            "\niconType: \(iconType)" +
            "\nisInternal: \(isInternal)" +
            "\npriority: \(priority)" +
            "\n\n*** subHolders ***\n\n"
        
        if self.subHolders.isEmpty
        {
            desc.append("<none>")
        }
        
        else
        {
            for holder in self.subHolders
            {
                desc.append(String(describing: holder) + "\n\n")
            }
        }
        
        return desc
    }
    
    
    // MARK: -- Lifecycle --

    /**
     * Default initializer which should never be used.  It will be called only in the case
     * of failure to file and decode the appropriate.
     */
    private init()
    {
        self.bundleName = "<not set>"
        self.storyboardName = "<not set>"
        self.identifier = "<not set>"
        self.title = "<not set>"
        self.icon = "<not set>"
        self.iconType = IconType.asset
        self.isInternal = true
        self.priority = -1
        self.subHolders = [SKContentDataHolder]()
    }
    
    
    /**
     * Retrieve a concrete instance of the SKContentHolder
     *
     * @returns SKContentHolder
     */
    public static func holder(from dataSource: SKContentDataSource) -> SKContentHolder
    {
        do
        {
            //
            // Retrieve the file path of the Theme.json file.  There is a chance there is a
            // root content bundle, but no Theme in it.  In that case, default to the 'should
            // always be there' default Theme.json resident in the main bundle
            //
            let bundle = Bundle.bundle(named: dataSource.filename) ?? Bundle.main
            if let filePath = bundle.url(forResource: dataSource.filename, withExtension: dataSource.fileExtension)
            {

                // Read the data
                //
                let data = try Data(contentsOf: filePath)
            
                //
                // Decode to model
                //
                let jsonDecoder = JSONDecoder()
                let holder = try jsonDecoder.decode(SKContentDataHolder.self, from: data)

                return holder
            }
        }
        catch(let error)
        {
            log.error(error)
        }
        
        return SKContentDataHolder()
    }
    
    
    // MARK: Public
    
    /**
     * Obtain the actual UIImage from the set image information.
     *
     * @returns UIImage, if applicable.
     */
    public func iconImage() -> UIImage?
    {
        switch(self.iconType)
        {
            //
            // Asset
            //
            case IconType.asset:
            
                //
                // Specific bundle
                //
                if let bundle = Bundle.bundle(forContentHolder: self)
                {
                    return UIImage(named: self.icon, in: bundle, compatibleWith: nil)
                }
            
                //
                // Default to main bundle
                //
                return UIImage(named: self.icon)
            
            //
            // PNG, JPG, JPEG
            //
            case IconType.png, IconType.jpg, IconType.jpeg:
            
                let iconName = self.icon + self.iconType.rawValue
                
                //
                // Specific bundle
                //
                if let bundle = Bundle.bundle(forContentHolder: self)
                {
                    return UIImage(named: iconName, in: bundle, compatibleWith: nil)
                }
            
                //
                // Default to main bundle
                //
                return UIImage(named: iconName)
            
            //
            // Font Awesome
            //
            case IconType.FontAwesome:
                
                return UIImage.fontAwesomeIcon(code: self.icon,
                    textColor: UIColor.white,
                    size: CGSize(width: 20, height: 20))
        }
    }
}


/**
 * Extension of the SKContentDataHolder to add some additional Decodable/Encodable initializations.
 */
public extension SKContentDataHolder
{
    /**
     * Decodable
     */
    init(from decoder: Decoder) throws
    {
        // Get our container for this subclass' coding keys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.bundleName = (try? container.decode(String.self, forKey: .bundleName)) ?? "<not set>"
        self.storyboardName = (try? container.decode(String.self, forKey: .storyboardName)) ?? "<not set>"
        self.identifier = (try? container.decode(String.self, forKey: .identifier)) ?? "<not set>"
        self.icon = (try? container.decode(String.self, forKey: .icon)) ?? "<not set>"
        self.iconType = (try? container.decode(IconType.self, forKey: .iconType)) ?? IconType.asset
        self.title = (try? container.decode(String.self, forKey: .title)) ?? "<not set>"
        self.isInternal = (try? container.decode(Bool.self, forKey: .isInternal)) ?? true
        self.priority = (try? container.decode(Int.self, forKey: .priority)) ?? 0
        self.subHolders = (try? container.decode([SKContentDataHolder].self, forKey: .subHolders)) ?? [SKContentDataHolder]()
    }
    
    
    /**
     * Encodable
     */
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
       
        try container.encode(self.bundleName, forKey: .bundleName)
        try container.encode(self.storyboardName, forKey: .storyboardName)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.icon, forKey: .icon)
        try container.encode(self.iconType, forKey: .iconType)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.isInternal, forKey: .isInternal)
        try container.encode(self.priority, forKey: .priority)
        try container.encode(self.subHolders, forKey: .subHolders)
    }
}


/**
 * IconTypes indicate which type of image
 */
public enum IconType: String, Codable
{
    /**
     * Indicates it is within the asset library.
     */
    case asset = "asset"
    
    /**
     * Indicates it is a .png image type.
     */
    case png = ".png"
    
    /**
     * Indicates it is a .jpg image type.
     */
    case jpg = ".jpg"
    
    /**
     * Indicates it is a .jpeg image type.
     */
    case jpeg = ".jpeg"
    
    /**
     * Indicates it is a FontAwesome type.
     */
    case FontAwesome = "FontAwesome"
}
