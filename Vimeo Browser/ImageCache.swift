//
//  ImageCache.swift
//  Vimeo Browser
//
//  Created by Martin Kelly on 30/06/2016.
//  Copyright © 2016 Martin Kelly. All rights reserved.
//

import UIKit

class ImageCache {
    
    private var inMemoryCache = NSCache<AnyObject, AnyObject>()
    
    // MARK: - Retreiving images
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        guard let identifier = identifier, !identifier.isEmpty else {
            return nil
        }
        
        let path = pathForIdentifier(identifier: identifier)
        
        // First try the memory cache
        if let image = inMemoryCache.object(forKey: identifier as NSString) as? UIImage {
            return image
        }
        
        // Next Try the hard drive
        if let data = FileManager.default.contents(atPath: path) {
            return UIImage(data: data)
        }
        
        return nil
    }

    
    // MARK: - Saving images
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        guard let image = image else {
            // If the image is nil, remove images from the cache
            inMemoryCache.removeObject(forKey: identifier as NSString)
            
            do {
                try FileManager.default.removeItem(atPath: identifier)
            } catch {
                print("Error removing image from cache: \(error)")
            }
            
            return
        }
        
        // Otherwise, keep the image in memory
        inMemoryCache.setObject(image, forKey: identifier as NSString)
        
        // And in documents directory
        if let data = image.pngData() {
            do {
                try data.write(to: URL(fileURLWithPath: identifier))
            } catch {
                print("Error writing image to disk: \(error)")
            }
        }
    }

    
    // MARK: - Helper
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURL = documentsDirectoryURL.appendingPathComponent(identifier)
        
        return fullURL.path
    }
}
