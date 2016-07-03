//
//  Video.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 03/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import Foundation
import CoreData

class Video: NSManagedObject {
    
    @NSManaged var resourceKey:String
    @NSManaged var id:Int
    @NSManaged var name:String
    @NSManaged var videoDescription:String?
    @NSManaged var uri:String
    @NSManaged var link:String
    @NSManaged var duration:Int
    @NSManaged var width:Int
    @NSManaged var height:Int
    @NSManaged var createdTime:NSDate
    @NSManaged var embedCode:String
    @NSManaged var numberOfPlays:Int
    @NSManaged var username:String
    @NSManaged var imageUrl:String
    @NSManaged var imageWithPlayIconUrl:String
    @NSManaged var category:Category?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Video", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        let keys = VimeoClient.Keys.self
        
        resourceKey = dictionary[keys.ResourceKey] as! String
        name = dictionary[keys.Name] as! String
        videoDescription = dictionary[keys.Video.Description] as? String
        uri = dictionary[keys.Uri] as! String
        link = dictionary[keys.Link] as! String
        duration = dictionary[keys.Video.Duration] as! Int
        width = dictionary["width"] as! Int
        height = dictionary["height"] as! Int
        
        
        let url = NSURL(string: link)!
        id = Int(url.lastPathComponent!)!
        
        if let embed = dictionary[keys.Video.Embed] as? [String:AnyObject] {
            embedCode = embed[keys.Video.Html] as! String
        }
        
        if let stats = dictionary["stats"] as? [String:AnyObject] {
            if let plays = stats["plays"] as? Int {
                numberOfPlays = plays
            }
        }
        
        if let user = dictionary["user"] as? [String:AnyObject] {
            username = user["name"] as! String
        }
        
        if let dateString = dictionary["created_time"] as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = dateFormatter.dateFromString(dateString) {
                createdTime = date
            }
        }
        
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
            print("V save error: \(error)")
        }
        
    }
    
}