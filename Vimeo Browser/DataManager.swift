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
                    completionHanlder(success: done)
                }
            }
        }
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
                                
                                self.loadVideosForCategories() { success in
                                    completionHanlder(success: true)
                                }
                            }
                        }
                        
                    case .Failure(let error):
                        print(error)
                        completionHanlder(success: false)
                    }
                }
                
            } else {
                
                self.loadVideosForCategories() { success in
                    completionHanlder(success: success)
                }
            }
            
        } catch let error {
            print(error)
            completionHanlder(success: false)
        }
    }
    
    func loadVideosForCategories(completionHandlder: (success:Bool) -> Void) {
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        // fetchRequest.fetchLimit = 1 // TODO: Remove this, stops me hitting limits too quickly while dev.
        
        do {
    
            let categories = try self.sharedContext.executeFetchRequest(fetchRequest) as! [Category]
            let categoryCount = categories.count
            var counter = 0
            var success = true
            
            for category in categories {
                
                VimeoClient.sharedInstance().getVideosForCategory(category) { result in
                    
                    counter += 1
                    
                    switch result {
                        
                    case .Success(let res):
                        
                        guard let videos = res as? [[String:AnyObject]] else {
                            
                            print("load videos for category error: No videos found)")
                            success = false
                            return
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            
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
                            } catch let error {
                                
                                print("load videos for category error: \(error))")
                                success = false
                            }
                        }
                    case .Failure(let error):
                        
                        print("load videos for category error: \(error))")
                        success = false
                    }
                    
                    if counter == categoryCount {
                        completionHandlder(success: success)
                    }
                }
            }
            
        } catch let error {
            print("loading videos by category error: \(error)")
            completionHandlder(success: false)
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