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
    @NSManaged var topLevel:Bool
    @NSManaged var imageUrl:String
    @NSManaged var imageWithPlayIconUrl:String
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Category", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = dictionary["reference_keys"] as! String
        name = dictionary["name"] as! String
        uri = dictionary["uri"] as! String
        link = dictionary["link"] as! String
        topLevel = dictionary["top_level"] as! Bool
        
        // we dont need all the sizes here, we'll pick a default of 960x540
        if let pictures = dictionary["pictures"] as? [[String:AnyObject]] {
            
            for picture in pictures {
                
                let width = picture["width"] as! Int
                
                if width == 960 {
                    imageUrl = picture["link"] as! String
                    imageWithPlayIconUrl = picture["link_with_play_button"] as! String
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