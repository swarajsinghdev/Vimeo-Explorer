//
//  Video.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 03/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import Foundation
import CoreData

import Foundation
import CoreData

class Video: NSManagedObject {
    
    @NSManaged var resourceKey: String
    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var videoDescription: String?
    @NSManaged var uri: String
    @NSManaged var link: String
    @NSManaged var duration: NSNumber
    @NSManaged var width: NSNumber
    @NSManaged var height: NSNumber
    @NSManaged var createdTime: Date
    @NSManaged var embedCode: String
    @NSManaged var numberOfPlays: NSNumber
    @NSManaged var username: String
    @NSManaged var imageUrl: String
    @NSManaged var imageWithPlayIconUrl: String
    @NSManaged var isFavourite: NSNumber
    @NSManaged var category: Category?

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    init(dictionary: [String:Any], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Video", in: context)!
        super.init(entity: entity, insertInto: context)

        resourceKey = dictionary[VimeoClient.Keys.ResourceKey] as! String
        name = dictionary[VimeoClient.Keys.Name] as! String
        videoDescription = dictionary[VimeoClient.Keys.Video.Description] as? String
        uri = dictionary[VimeoClient.Keys.Uri] as! String
        link = (dictionary[VimeoClient.Keys.Link] as! String).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        duration = dictionary[VimeoClient.Keys.Video.Duration] as! NSNumber
        width = dictionary["width"] as! NSNumber
        height = dictionary["height"] as! NSNumber
        isFavourite = false
        
        let url = URL(string: link)!
        id = url.lastPathComponent
        
        if let embed = dictionary[VimeoClient.Keys.Video.Embed] as? [String:Any] {
            embedCode = embed[VimeoClient.Keys.Video.Html] as! String
        }
        
        if let stats = dictionary["stats"] as? [String:Any] {
            if let plays = stats["plays"] as? NSNumber {
                numberOfPlays = plays
            }
        }
        
        if let user = dictionary["user"] as? [String:Any] {
            if let userName = user["name"] as? String {
                username = userName
            }
        }
        
        if let dateString = dictionary["created_time"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            if let date = dateFormatter.date(from: dateString) {
                createdTime = date
            }
        }
        
        if let pictures = dictionary[VimeoClient.Keys.Pictures] as? [String:Any] {
            if let sizes = pictures["sizes"] as? [[String:Any]] {
                for picture in sizes {
                    let width = picture[VimeoClient.Keys.PicturesWidth] as! Int
                    if width == VimeoClient.Constants.CategoryImageWidth {
                        imageUrl = picture[VimeoClient.Keys.PicturesLink] as! String
                        imageWithPlayIconUrl = picture[VimeoClient.Keys.PicturesLinkWithPlayIcon] as! String
                        break
                    }
                }
            }
        }
    }
}
