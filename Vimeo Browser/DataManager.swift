//
//  DataManager.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 03/07/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    
    // MARK: Convenience Properties
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    class func sharedInstance() -> DataManager {
        struct Singleton {
            static var sharedInstance = DataManager()
        }
        
        return Singleton.sharedInstance
    }
    
    func loadData(completionHanlder: (success:Bool) -> Void) {
        
        VimeoClient.sharedInstance().authenticate() { success in
            self.loadCategoryData() { success in
                self.loadVideosForCategories() { done in
                    completionHanlder(success: true)
                    return
                }
            }
        }
        
        completionHanlder(success: false)
    }
    
    func loadCategoryData(completionHanlder: (success:Bool) -> Void) {
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        
        do {
            let result = try self.sharedContext.executeFetchRequest(fetchRequest)
            
            print("Number of categories: \(result.count)")
            
            if result.count == 0 {
                
                VimeoClient.sharedInstance().getCategories() { result in
                    
                    switch result {
                    case .Success(let res):
                        
                        if let categories = res as? [[String:AnyObject]] {
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                let _ = categories.map() { (dictionary:[String:AnyObject]) -> Category in
                                    let category = Category(dictionary: dictionary, context: self.sharedContext)
                                    return category
                                }
                            }
                        }
                        
                    case .Failure(let error):
                        print(error)
                        completionHanlder(success: false)
                    }
                }
                
            }
            
            completionHanlder(success: true)
            
        } catch let error {
            print(error)
            completionHanlder(success: false)
        }
    }
    
    func loadVideosForCategories(completionHandlder: (success:Bool) -> Void) {
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        
        do {
            let categories = try self.sharedContext.executeFetchRequest(fetchRequest) as! [Category]
            
            for category in categories {
                
                VimeoClient.sharedInstance().getVideosForCategory(category) { result in
                    
                    switch result {
                    case .Success(let res):
                        
                        guard let videos = res as? [[String:AnyObject]] else {
                            print("load videos for category error: No videos found)")
                            completionHandlder(success: false)
                            return
                        }
                        
                        let _ = videos.map() { (dictionary:[String:AnyObject]) -> Video in
                            
                            if let resourceKey = dictionary[VimeoClient.Keys.ResourceKey] as? String {
                                if let video = self.findVideoByResourceKey(resourceKey) {
                                    return video
                                }
                            }
                            
                            let video = Video(dictionary: dictionary, context: self.sharedContext)
                            video.category = category
                            return video
                        }
                        
                        do {
                            try self.sharedContext.save()
                            
                            completionHandlder(success: true)
                        } catch let error {
                            print("load videos for category error: \(error))")
                            completionHandlder(success: false)
                        }
                    case .Failure(let error):
                        print("load videos for category error: \(error))")
                        completionHandlder(success: false)
                    }
                }
            }
            
        } catch let error {
            print("loading videos by category error: \(error)")
        }
    }
    
    
    func findVideoByResourceKey(resourceKey: String) -> Video? {
        
        let fetchRequest = NSFetchRequest(entityName: "Video")
        fetchRequest.predicate = NSPredicate(format: "resourceKey = %@", resourceKey)
        
        do {
            let results = try self.sharedContext.executeFetchRequest(fetchRequest)
            
            if results.count == 1 {
                return results.first! as? Video
            } else {
                return nil
            }
        } catch let error {
            print("error in find video by id: \(error)")
            return nil
        }
    }
    
    func findCategoryByResourceKey(resourceKey:String) -> Category? {
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.predicate = NSPredicate(format: "resourceKey = %@", resourceKey)
        
        do {
            let results = try self.sharedContext.executeFetchRequest(fetchRequest)
            
            if results.count == 1 {
                return results.first! as? Category
            } else {
                return nil
            }
        } catch let error {
            print("error in find video by id: \(error)")
            return nil
        }
    }
}