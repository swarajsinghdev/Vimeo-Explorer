//
//  Category.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 01/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import Foundation
import CoreData

import Foundation
import CoreData

class Category: NSManagedObject {
    
    @NSManaged var resourceKey: String
    @NSManaged var name: String
    @NSManaged var uri: String
    @NSManaged var link: String
    @NSManaged var topLevel: NSNumber
    @NSManaged var imageUrl: String
    @NSManaged var imageWithPlayIconUrl: String
    @NSManaged var videos: [Video]?
    
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: context)!
        super.init(entity: entity, insertInto: context)
        
        let keys = VimeoClient.Keys.self
        
        resourceKey = dictionary[keys.ResourceKey] as! String
        name = dictionary[keys.Name] as! String
        uri = dictionary[keys.Uri] as! String
        link = dictionary[keys.Link] as! String
        topLevel = dictionary[keys.Category.TopLevel] as! NSNumber
        
        // we dont need all the sizes here, we'll pick a default of 960x540
        if let pictures = dictionary[keys.Pictures] as? [String:AnyObject] {
            
            if let sizes = pictures["sizes"] as? [[String:AnyObject]] {
                for picture in sizes {
                    
                    let width = picture[keys.PicturesWidth] as! Int
                    
                    if width == VimeoClient.Constants.CategoryImageWidth {
                        imageUrl = picture[keys.PicturesLink] as! String
                        imageWithPlayIconUrl = picture[keys.PicturesLinkWithPlayIcon] as! String
                    }
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
