//
//  Category.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 01/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import Foundation
import CoreData

class Category: NSManagedObject {
    
    @NSManaged var id:String
    @NSManaged var name:String
    @NSManaged var uri:String
    @NSManaged var link:String
    @NSManaged var topLevel:NSNumber
    @NSManaged var imageUrl:String
    @NSManaged var imageWithPlayIconUrl:String
    @NSManaged var videos:[Video]?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Category", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        let keys = VimeoClient.Keys.self
        
        id = dictionary[keys.ResourceKey] as! String
        name = dictionary[keys.Name] as! String
        uri = dictionary[keys.Uri] as! String
        link = dictionary[keys.Link] as! String
        topLevel = dictionary[keys.Category.TopLevel] as! NSNumber
        
        // we dont need all the sizes here, we'll pick a default of 960x540
        if let pictures = dictionary[keys.Pictures] as? [[String:AnyObject]] {
            
            for picture in pictures {
                
                let width = picture[keys.PicturesWidth] as! Int
                
                if width == VimeoClient.Constants.CategoryImageWidth {
                    imageUrl = picture[keys.PicturesLink] as! String
                    imageWithPlayIconUrl = picture[keys.PicturesLinkWithPlayIcon] as! String
                }
            }
        }
        
        do {
            try context.save()
        } catch let error {
            print("Category save error: \(error)")
        }
        
        
    }
}