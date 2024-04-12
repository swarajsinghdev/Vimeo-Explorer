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
    
    // MARK: - Convenience Properties
    
    let sharedContext = CoreDataStackManager.shared.managedObjectContext
    
    // MARK: - Singleton
    
    static let shared = DataManager()
    
    private init() {} // Prevent external instantiation
    
    // MARK: - Data Loading
    
    func loadData(completionHandler: @escaping (Bool) -> Void) {
        VimeoClient.sharedInstance().authenticate { success, error in
            guard success else {
                print("Authentication failed with error: \(error?.localizedDescription ?? "Unknown error")")
                completionHandler(false)
                return
            }
            
            self.loadCategoryData(completionHandler: completionHandler)
        }
    }
    
    func loadCategoryData(completionHandler: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let categories = try sharedContext.fetch(fetchRequest)
            print("Number of categories: \(categories.count)")
            
            if categories.isEmpty {
                VimeoClient.sharedInstance().getCategories { result in
                    switch result {
                    case .success(let res):
                        guard let categoriesData = res as? [[String:Any]] else {
                            print("Error: No categories data found")
                            completionHandler(false)
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.saveCategories(from: categoriesData, completionHandler: completionHandler)
                        }
                        
                    case .failure(let error):
                        print("Failed to fetch categories: \(error.localizedDescription)")
                        completionHandler(false)
                    }
                }
            } else {
                self.loadVideosForCategories(completionHandler: completionHandler)
            }
        } catch {
            print("Error fetching categories: \(error)")
            completionHandler(false)
        }
    }
    
    func saveCategories(from categoriesData: [[String:Any]], completionHandler: @escaping (Bool) -> Void) {
        categoriesData.forEach { categoryData in
            guard let categoryDataAsObject = categoryData as? [String: AnyObject] else {
                // Handle the case where conversion fails
                return
            }
            _ = Category(dictionary: categoryDataAsObject, context: sharedContext)
        }
        
        self.loadVideosForCategories(completionHandler: completionHandler)
    }

    
    func loadVideosForCategories(completionHandler: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            let categories = try sharedContext.fetch(fetchRequest)
            var success = true
            
            for category in categories {
                VimeoClient.sharedInstance().getVideosForCategory(category: category) { result in
                    switch result {
                    case .success(let res):
                        guard let videosData = res as? [[String:Any]] else {
                            print("Error: No videos data found")
                            success = false
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.saveVideos(from: videosData, for: category, completionHandler: completionHandler)
                        }
                        
                    case .failure(let error):
                        print("Failed to fetch videos for category \(category.name ?? ""): \(error.localizedDescription)")
                        success = false
                    }
                    
                    if !success {
                        completionHandler(false)
                        return
                    }
                }
            }
            
            completionHandler(success)
        } catch {
            print("Error fetching categories: \(error)")
            completionHandler(false)
        }
    }
    
    func saveVideos(from videosData: [[String:Any]], for category: Category, completionHandler: @escaping (Bool) -> Void) {
        videosData.forEach { videoData in
            _ = Video(dictionary: videoData, context: sharedContext)
        }
        
        do {
            try sharedContext.save()
            completionHandler(true)
        } catch {
            print("Error saving context: \(error)")
            completionHandler(false)
        }
    }
}
